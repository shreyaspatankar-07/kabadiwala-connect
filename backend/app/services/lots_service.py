"""Lots (Transactions) management with offline idempotency service."""

import hashlib
from datetime import UTC, datetime

from geoalchemy2.elements import WKTElement
from geoalchemy2.shape import to_shape
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.models.schema import (
    PaymentStatus,
    SyncActionStatus,
    SyncQueue,
    Traceability,
    Transaction,
    TransactionStatus,
)
from app.schemas.lots import LotCreate, LotResponse, LotStatusUpdate


class LotsService:
    @staticmethod
    def _to_response(t: Transaction) -> LotResponse:
        try:
            pt = to_shape(t.collection_location)
            c_lat, c_lng = pt.y, pt.x
        except Exception:
            c_lat, c_lng = 0.0, 0.0

        h_lat, h_lng = None, None
        if t.handover_location is not None:
            try:
                h_pt = to_shape(t.handover_location)
                h_lat, h_lng = h_pt.y, h_pt.x
            except Exception:
                pass

        return LotResponse(
            lot_id=t.lot_id,
            collector_id=t.collector_id,
            category=t.category,
            weight_kg=float(t.weight_kg),
            quoted_price=float(t.quoted_price),
            final_price=float(t.final_price) if t.final_price is not None else None,
            recycler_id=t.recycler_id,
            collection_lat=c_lat,
            collection_lng=c_lng,
            handover_lat=h_lat,
            handover_lng=h_lng,
            created_at=t.created_at,
            handover_at=t.handover_at,
            payment_status=t.payment_status.value,
            transaction_status=t.transaction_status.value,
            anomaly_flag=t.anomaly_flag,
            anomaly_reason=t.anomaly_reason,
            updated_at=t.updated_at,
        )

    @classmethod
    async def create_or_get_lot(
        cls,
        collector_id: str,
        data: LotCreate,
        db: AsyncSession,
    ) -> LotResponse:
        """Idempotent lot creation: replayed requests return existing lot without duplication."""
        # 1. Check if client_lot_id was already processed in sync_queue
        res_sync = await db.execute(
            select(SyncQueue).where(
                SyncQueue.client_tx_id == data.client_lot_id,
                SyncQueue.collector_id == collector_id,
            )
        )
        existing_sync = res_sync.scalar_one_or_none()
        if existing_sync and "assigned_lot_id" in existing_sync.payload:
            existing_lot_id = existing_sync.payload["assigned_lot_id"]
            res_lot = await db.execute(
                select(Transaction).where(Transaction.lot_id == existing_lot_id)
            )
            lot = res_lot.scalar_one_or_none()
            if lot:
                return cls._to_response(lot)

        # 2. Generate deterministic human-friendly lot ID
        created_dt = data.created_at_utc or datetime.now(UTC)
        prefix = f"KC-MH-{created_dt.strftime('%y%m')}"
        digest = (
            hashlib.sha256(f"{collector_id}:{data.client_lot_id}".encode()).hexdigest()[:6].upper()
        )
        lot_id = f"{prefix}-{digest}"

        # 3. Check if transaction with this lot_id exists
        res_tx = await db.execute(select(Transaction).where(Transaction.lot_id == lot_id))
        existing_tx = res_tx.scalar_one_or_none()
        if existing_tx:
            return cls._to_response(existing_tx)

        # 4. Create new transaction
        pt = WKTElement(f"POINT({data.collection_lng} {data.collection_lat})", srid=4326)
        lot = Transaction(
            lot_id=lot_id,
            collector_id=collector_id,
            category=data.category,
            weight_kg=data.weight_kg,
            quoted_price=data.quoted_price,
            collection_location=pt,
            created_at=created_dt,
            transaction_status=TransactionStatus.LISTED,
            payment_status=PaymentStatus.PENDING,
        )
        db.add(lot)

        # Record photo hashes in traceability record if provided
        if data.photo_hashes:
            rec_hash = hashlib.sha256(
                f"{lot_id}:{data.photo_hashes}:{data.weight_kg}".encode()
            ).hexdigest()
            trace = Traceability(
                lot_id=lot_id,
                photo_hashes=data.photo_hashes,
                weight_kg=data.weight_kg,
                timestamp=created_dt,
                gps_lat=data.collection_lat,
                gps_lng=data.collection_lng,
                location=pt,
                handover_ref_no=f"HND-{lot_id}",
                qr_payload=f"kc://lot/{lot_id}",
                record_hash=rec_hash,
                prev_hash="0" * 64,
            )
            db.add(trace)

        # Record idempotency token in sync_queue
        sync_entry = SyncQueue(
            collector_id=collector_id,
            client_tx_id=data.client_lot_id,
            action="create_lot",
            payload={"assigned_lot_id": lot_id, "category": data.category},
            status=SyncActionStatus.COMPLETED,
            client_timestamp=created_dt,
            processed_at=datetime.now(UTC),
        )
        db.add(sync_entry)

        await db.commit()
        await db.refresh(lot)
        return cls._to_response(lot)

    @classmethod
    async def list_lots(
        cls,
        db: AsyncSession,
        collector_id: str | None = None,
        recycler_id: str | None = None,
        status: str | None = None,
        limit: int = 50,
    ) -> list[LotResponse]:
        query = select(Transaction)
        if collector_id:
            query = query.where(Transaction.collector_id == collector_id)
        if recycler_id:
            query = query.where(Transaction.recycler_id == recycler_id)
        if status:
            query = query.where(Transaction.transaction_status == TransactionStatus(status))

        result = await db.execute(query.order_by(Transaction.created_at.desc()).limit(limit))
        lots = result.scalars().all()
        return [cls._to_response(t) for t in lots]

    @classmethod
    async def get_lot(cls, lot_id: str, db: AsyncSession) -> LotResponse:
        res = await db.execute(select(Transaction).where(Transaction.lot_id == lot_id))
        t = res.scalar_one_or_none()
        if not t:
            raise NotFoundError("Lot", lot_id)
        return cls._to_response(t)

    @classmethod
    async def update_lot_status(
        cls, lot_id: str, data: LotStatusUpdate, db: AsyncSession
    ) -> LotResponse:
        res = await db.execute(select(Transaction).where(Transaction.lot_id == lot_id))
        t = res.scalar_one_or_none()
        if not t:
            raise NotFoundError("Lot", lot_id)

        t.transaction_status = TransactionStatus(data.transaction_status)
        if data.final_price is not None:
            t.final_price = data.final_price
        if data.recycler_id is not None:
            t.recycler_id = data.recycler_id
        if data.handover_lat is not None and data.handover_lng is not None:
            t.handover_location = WKTElement(
                f"POINT({data.handover_lng} {data.handover_lat})", srid=4326
            )
            t.handover_at = datetime.now(UTC)
        if data.anomaly_flag is not None:
            t.anomaly_flag = data.anomaly_flag
            t.anomaly_reason = data.anomaly_reason

        await db.commit()
        await db.refresh(t)
        return cls._to_response(t)
