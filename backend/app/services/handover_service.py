"""Verifiable Handover Record, QR Cryptographic Signing, and EPR Traceability Service."""

from datetime import UTC, datetime
import hashlib
import hmac
import json
import secrets
from typing import Any

from geoalchemy2.elements import WKTElement
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.errors import BadRequestError, ConflictError, NotFoundError
from app.models.schema import (
    DownstreamStatus,
    LedgerEntry,
    LedgerEntryType,
    PaymentStatus,
    Traceability,
    Transaction,
    TransactionStatus,
)
from app.schemas.handover import (
    DownstreamStatusResponse,
    HandoverConfirmRequest,
    HandoverConfirmResponse,
    HandoverInitiateRequest,
    HandoverInitiateResponse,
    HandoverVerificationResponse,
)

GENESIS_HASH = "0" * 64
REF_CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"


class HandoverService:
    """Orchestrates verifiable handovers, HMAC-signed QR generation, and hash-chained EPR audit trails."""

    @staticmethod
    def generate_handover_ref_no() -> str:
        """Generates a unique 6-character uppercase alphanumeric reference code (omitting ambiguous characters)."""
        return "".join(secrets.choice(REF_CHARSET) for _ in range(6))

    @staticmethod
    def sign_payload(payload_dict: dict[str, Any]) -> str:
        """Computes deterministic HMAC-SHA256 signature over sorted JSON payload."""
        # Ensure signature field is not included in signed content
        clean_dict = {k: v for k, v in payload_dict.items() if k != "signature"}
        serialized = json.dumps(clean_dict, sort_keys=True, separators=(",", ":"))
        return hmac.new(
            settings.SECRET_KEY.encode("utf-8"),
            serialized.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()

    @staticmethod
    def verify_payload_signature(payload_dict: dict[str, Any], signature: str) -> bool:
        """Constant-time verification of HMAC-SHA256 signature."""
        expected = HandoverService.sign_payload(payload_dict)
        return hmac.compare_digest(expected, signature)

    @classmethod
    async def initiate_handover(
        cls,
        data: HandoverInitiateRequest,
        db: AsyncSession,
        collector_id: str | None = None,
    ) -> HandoverInitiateResponse:
        """Initiates handover for a lot, generates unique 6-char code, and creates HMAC-signed QR payload."""
        # 1. Verify transaction exists
        tx_res = await db.execute(
            select(Transaction).where(Transaction.lot_id == data.lot_id)
        )
        tx = tx_res.scalar_one_or_none()
        if not tx:
            raise NotFoundError("Transaction Lot", data.lot_id)

        actual_collector_id = str(collector_id or tx.collector_id)
        collector_hash = hashlib.sha256(actual_collector_id.encode("utf-8")).hexdigest()[:16]

        # 2. Generate unique 6-char ref number
        while True:
            ref_no = cls.generate_handover_ref_no()
            existing = await db.execute(
                select(Traceability).where(Traceability.handover_ref_no == ref_no)
            )
            if not existing.scalar_one_or_none():
                break

        now_utc = data.timestamp or datetime.now(UTC)

        # 3. Construct QR payload and HMAC signature
        payload = {
            "lot_id": data.lot_id,
            "handover_ref_no": ref_no,
            "weight_kg": round(float(data.weight_kg), 2),
            "photo_hashes": data.photo_hashes,
            "timestamp": now_utc.isoformat(),
            "gps_lat": round(float(data.gps_lat), 6),
            "gps_lng": round(float(data.gps_lng), 6),
            "collector_id_hash": collector_hash,
        }
        signature = cls.sign_payload(payload)
        payload["signature"] = signature
        qr_payload_str = json.dumps(payload, separators=(",", ":"))

        # 4. Fetch previous traceability record hash for hash-chaining
        last_rec_res = await db.execute(
            select(Traceability).order_by(desc(Traceability.created_at)).limit(1)
        )
        last_rec = last_rec_res.scalar_one_or_none()
        prev_hash = last_rec.record_hash if last_rec else GENESIS_HASH

        initial_record_hash = hashlib.sha256(
            f"{qr_payload_str}:{prev_hash}".encode("utf-8")
        ).hexdigest()

        # 5. Persist initial Traceability entry
        traceability_entry = Traceability(
            lot_id=data.lot_id,
            photo_hashes=data.photo_hashes,
            weight_kg=data.weight_kg,
            timestamp=now_utc,
            gps_lat=data.gps_lat,
            gps_lng=data.gps_lng,
            location=WKTElement(f"POINT({data.gps_lng} {data.gps_lat})", srid=4326),
            handover_ref_no=ref_no,
            qr_payload=qr_payload_str,
            recycler_confirmation=False,
            downstream_status=DownstreamStatus.RECEIVED,
            record_hash=initial_record_hash,
            prev_hash=prev_hash,
            created_at=datetime.now(UTC),
        )
        db.add(traceability_entry)

        # Update lot transaction status
        tx.transaction_status = TransactionStatus.HANDOVER_PENDING
        await db.commit()

        return HandoverInitiateResponse(
            lot_id=data.lot_id,
            handover_ref_no=ref_no,
            qr_payload=qr_payload_str,
            signature=signature,
            created_at=now_utc,
        )

    @classmethod
    async def confirm_handover(
        cls,
        data: HandoverConfirmRequest,
        db: AsyncSession,
        recycler_id: str | None = None,
    ) -> HandoverConfirmResponse:
        """Confirms physical handover, verifies HMAC signature, checks weight tolerance,

        updates immutable hash chain, and records financial ledger credit.
        """
        target_ref_no = data.handover_ref_no

        # 1. If scanned QR payload is provided, verify HMAC signature first
        if data.qr_payload:
            try:
                parsed_payload = json.loads(data.qr_payload)
            except Exception as err:
                raise BadRequestError("Malformed QR JSON payload.", code="INVALID_QR_JSON") from err

            sig = parsed_payload.get("signature")
            if not sig or not cls.verify_payload_signature(parsed_payload, sig):
                raise BadRequestError(
                    "Invalid or tampered QR HMAC signature.", code="TAMPERED_QR_SIGNATURE"
                )

            payload_ref = parsed_payload.get("handover_ref_no")
            if target_ref_no and payload_ref != target_ref_no:
                raise BadRequestError(
                    f"Ref number mismatch (payload: {payload_ref}, provided: {target_ref_no}).",
                    code="REF_MISMATCH",
                )
            target_ref_no = payload_ref

        if not target_ref_no:
            raise BadRequestError(
                "Either 'handover_ref_no' or 'qr_payload' must be provided.",
                code="MISSING_HANDOVER_IDENTIFIER",
            )

        # 2. Look up Traceability record
        trace_res = await db.execute(
            select(Traceability).where(Traceability.handover_ref_no == target_ref_no)
        )
        traceability = trace_res.scalar_one_or_none()
        if not traceability:
            raise NotFoundError("Handover Record", target_ref_no)

        # 3. Replay attack check: cannot confirm an already confirmed handover
        if traceability.recycler_confirmation:
            raise ConflictError(
                "Handover record has already been confirmed. Replay attack detected.",
                code="HANDOVER_ALREADY_CONFIRMED",
            )

        # 4. Fetch associated Transaction
        tx_res = await db.execute(
            select(Transaction).where(Transaction.lot_id == traceability.lot_id)
        )
        tx = tx_res.scalar_one_or_none()
        if not tx:
            raise NotFoundError("Transaction Lot", traceability.lot_id)

        if tx.transaction_status in (TransactionStatus.HANDED_OVER, TransactionStatus.CONFIRMED):
            raise ConflictError(
                "Transaction lot is already finalized.", code="TRANSACTION_ALREADY_FINALIZED"
            )

        # 5. Check weight tolerance (default 10%)
        orig_weight = float(traceability.weight_kg)
        meas_weight = float(data.measured_weight_kg)
        tolerance = settings.HANDOVER_WEIGHT_TOLERANCE_PERCENT / 100.0
        delta = abs(meas_weight - orig_weight) / orig_weight if orig_weight > 0 else 0.0

        is_disputed = delta > tolerance
        dispute_reason = None
        if is_disputed:
            dispute_reason = (
                f"Weight mismatch of {delta * 100:.1f}% exceeds tolerance of "
                f"{settings.HANDOVER_WEIGHT_TOLERANCE_PERCENT:.0f}% (collector: {orig_weight} kg, recycler: {meas_weight} kg)"
            )
            tx.transaction_status = TransactionStatus.DISPUTED
            tx.anomaly_flag = True
            tx.anomaly_reason = dispute_reason
        else:
            tx.transaction_status = TransactionStatus.HANDED_OVER
            tx.anomaly_flag = False
            tx.anomaly_reason = None

        now_utc = datetime.now(UTC)
        final_price = float(data.final_price)
        effective_recycler = str(recycler_id or data.recycler_id or tx.recycler_id or "REC-ANONYMOUS")

        # Update transaction details
        tx.final_price = final_price
        tx.handover_at = now_utc
        tx.recycler_id = effective_recycler
        tx.handover_location = WKTElement(
            f"POINT({traceability.gps_lng} {traceability.gps_lat})", srid=4326
        )

        # 6. Update Traceability record & compute hash-chain
        chain_input = (
            f"{traceability.qr_payload}:{traceability.prev_hash}:"
            f"{meas_weight}:{final_price}:{effective_recycler}:{now_utc.isoformat()}"
        )
        new_record_hash = hashlib.sha256(chain_input.encode("utf-8")).hexdigest()

        traceability.recycler_confirmation = True
        traceability.confirmed_at = now_utc
        traceability.confirmed_by = effective_recycler
        traceability.downstream_status = DownstreamStatus.RECEIVED
        traceability.record_hash = new_record_hash

        # 7. Create Financial Ledger Entry for Collector
        last_ledger_res = await db.execute(
            select(LedgerEntry)
            .where(LedgerEntry.collector_id == tx.collector_id)
            .order_by(desc(LedgerEntry.recorded_at))
            .limit(1)
        )
        last_ledger = last_ledger_res.scalar_one_or_none()
        current_balance = float(last_ledger.balance_after) if last_ledger else 0.0
        new_balance = current_balance + final_price

        ledger_entry = LedgerEntry(
            collector_id=tx.collector_id,
            lot_id=tx.lot_id,
            entry_type=LedgerEntryType.CREDIT,
            amount=final_price,
            payment_mode=PaymentStatus.CASH_RECEIVED,
            description=f"E-Waste Lot Handover Settlement: {tx.lot_id} ({meas_weight} kg {tx.category})",
            balance_after=new_balance,
            recorded_at=now_utc,
        )
        db.add(ledger_entry)

        await db.commit()

        return HandoverConfirmResponse(
            lot_id=tx.lot_id,
            handover_ref_no=target_ref_no,
            transaction_status=tx.transaction_status.value,
            is_disputed=is_disputed,
            dispute_reason=dispute_reason,
            measured_weight_kg=meas_weight,
            original_weight_kg=orig_weight,
            final_price=final_price,
            record_hash=new_record_hash,
            confirmed_at=now_utc,
        )

    @classmethod
    async def update_downstream_status(
        cls,
        lot_id: str,
        status_str: str,
        db: AsyncSession,
    ) -> DownstreamStatusResponse:
        """Updates EPR downstream processing status (received -> dismantled -> processed -> certificate_issued)."""
        trace_res = await db.execute(
            select(Traceability)
            .where(Traceability.lot_id == lot_id)
            .order_by(desc(Traceability.created_at))
            .limit(1)
        )
        traceability = trace_res.scalar_one_or_none()
        if not traceability:
            raise NotFoundError("Traceability for Lot", lot_id)

        traceability.downstream_status = DownstreamStatus(status_str)
        now_utc = datetime.now(UTC)
        await db.commit()

        return DownstreamStatusResponse(
            lot_id=lot_id,
            downstream_status=status_str,
            updated_at=now_utc,
        )

    @classmethod
    async def verify_handover_public(
        cls,
        handover_ref_no: str,
        db: AsyncSession,
    ) -> HandoverVerificationResponse:
        """Public endpoint allowing anyone to inspect cryptographic integrity of a handover."""
        trace_res = await db.execute(
            select(Traceability).where(Traceability.handover_ref_no == handover_ref_no)
        )
        traceability = trace_res.scalar_one_or_none()
        if not traceability:
            raise NotFoundError("Handover Reference", handover_ref_no)

        tx_res = await db.execute(
            select(Transaction).where(Transaction.lot_id == traceability.lot_id)
        )
        tx = tx_res.scalar_one_or_none()

        # Check HMAC validity of stored QR payload
        is_hmac_valid = False
        try:
            parsed = json.loads(traceability.qr_payload)
            sig = parsed.get("signature")
            if sig:
                is_hmac_valid = cls.verify_payload_signature(parsed, sig)
        except Exception:
            is_hmac_valid = False

        integrity_status = "tamper_free"
        if not is_hmac_valid:
            integrity_status = "compromised"
        elif tx and tx.anomaly_flag:
            integrity_status = "disputed"

        return HandoverVerificationResponse(
            handover_ref_no=handover_ref_no,
            is_valid=is_hmac_valid,
            lot_id=traceability.lot_id,
            category=tx.category if tx else "Unknown",
            collector_weight_kg=float(traceability.weight_kg),
            measured_weight_kg=float(tx.weight_kg) if tx else None,
            final_price=float(tx.final_price) if tx and tx.final_price is not None else None,
            timestamp=traceability.timestamp,
            recycler_confirmed=traceability.recycler_confirmation,
            confirmed_at=traceability.confirmed_at,
            confirmed_by=traceability.confirmed_by,
            downstream_status=traceability.downstream_status.value,
            record_hash=traceability.record_hash,
            integrity_status=integrity_status,
        )
