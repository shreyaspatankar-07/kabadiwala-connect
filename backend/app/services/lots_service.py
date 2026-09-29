"""Lots (Transactions) management with offline idempotency service."""

import hashlib
import logging
import math
from datetime import UTC, datetime

from geoalchemy2.elements import WKTElement
from geoalchemy2.shape import to_shape
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.models.schema import (
    AuthorizationStatus,
    PaymentStatus,
    Recycler,
    SyncActionStatus,
    SyncQueue,
    Traceability,
    Transaction,
    TransactionStatus,
)
from app.schemas.lots import LotCreate, LotResponse, LotStatusUpdate

logger = logging.getLogger("kabadiwala.lots")

# GPS coarsening grid (≈500 m) — same constant as data pipeline anonymizer
_GPS_GRID = 0.005


def _coarsen(value: float) -> float:
    return round(round(value / _GPS_GRID) * _GPS_GRID, 4)


async def _find_matched_recycler_ids(
    db: AsyncSession,
    category: str,
    lot_lat: float,
    lot_lng: float,
) -> list[str]:
    """Return IDs of verified recyclers that accept the lot category and service area.

    Used to scope the WebSocket broadcast — only matched recyclers receive the event.
    """
    result = await db.execute(
        select(Recycler).where(
            Recycler.authorization_status == AuthorizationStatus.VERIFIED,
        )
    )
    recyclers = result.scalars().all()

    matched: list[str] = []
    cat_lower = category.strip().lower()
    for r in recyclers:
        # Category check
        accepted = [m.strip().lower() for m in (r.materials_accepted or [])]
        if cat_lower not in accepted:
            continue

        # Location check (pickup radius OR service-area district/state)
        try:
            pt = to_shape(r.facility_location)
            r_lat, r_lng = pt.y, pt.x
        except Exception:
            r_lat, r_lng = 0.0, 0.0

        dist_km = _haversine(lot_lat, lot_lng, r_lat, r_lng)
        sa = r.service_area or {}
        in_area = (
            (r.pickup_radius_km and dist_km <= float(r.pickup_radius_km))
            or sa.get("all") is True
            or sa.get("state") == "Maharashtra"
            or dist_km <= float(sa.get("max_distance_km", 0))
        )
        if in_area:
            matched.append(r.id)

    return matched


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


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
            collector_confirmed=getattr(t, "collector_confirmed", True),
            recycler_confirmed=getattr(t, "recycler_confirmed", False),
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
        broadcast: bool = True,
    ) -> LotResponse:
        """Idempotent lot creation: replayed requests return existing lot without duplication.

        On first insert, broadcasts a ``lot.created`` WebSocket event to all matched,
        verified recyclers with coarsened GPS (≈500 m grid). Replayed requests are
        returned immediately without re-broadcasting.
        """
        logger.info(
            "[lots] receive create_or_get_lot collector=%s client_lot_id=%s",
            collector_id, data.client_lot_id,
        )

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
                logger.info("[lots] idempotent replay lot_id=%s — skipping broadcast", existing_lot_id)
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
            logger.info("[lots] lot_id already exists=%s — skipping broadcast", lot_id)
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
        logger.info("[lots] committed lot_id=%s category=%s", lot_id, data.category)

        # 5. Broadcast to matched recyclers AFTER successful commit
        if broadcast:
            try:
                from app.api.v1.ws import manager  # local import to avoid circular deps

                matched_ids = await _find_matched_recycler_ids(
                    db, data.category, data.collection_lat, data.collection_lng
                )
                # Only broadcast to recyclers who are currently connected
                connected_matched = [
                    rid for rid in matched_ids if rid in manager.connected_recycler_ids
                ]
                if connected_matched:
                    ws_payload = {
                        "type": "lot.created",
                        "lot": {
                            "lot_id": lot_id,
                            "category": data.category,
                            "weight_kg": float(data.weight_kg),
                            "quoted_price": float(data.quoted_price),
                            # Coarsened GPS — no exact location of collector sent
                            "collection_lat": _coarsen(data.collection_lat),
                            "collection_lng": _coarsen(data.collection_lng),
                            "created_at": created_dt.isoformat(),
                            "transaction_status": TransactionStatus.LISTED.value,
                        },
                    }
                    sent = await manager.broadcast_to_recyclers(connected_matched, ws_payload)
                    logger.info(
                        "[lots] broadcast lot_id=%s matched=%d connected=%d sent=%d",
                        lot_id, len(matched_ids), len(connected_matched), sent,
                    )
                else:
                    logger.info(
                        "[lots] no connected recyclers for lot_id=%s matched=%d",
                        lot_id, len(matched_ids),
                    )
            except Exception as exc:  # noqa: BLE001
                # Broadcast failure must never roll back a committed lot
                logger.warning("[lots] broadcast error lot_id=%s err=%s", lot_id, exc)

        return cls._to_response(lot)

    @classmethod
    async def list_lots(
        cls,
        db: AsyncSession,
        collector_id: str | None = None,
        recycler_id: str | None = None,
        status: str | None = None,
        settled: bool | None = None,
        payment_status: str | None = None,
        limit: int = 50,
    ) -> list[LotResponse]:
        query = select(Transaction)
        if collector_id:
            query = query.where(Transaction.collector_id == collector_id)
        if recycler_id:
            query = query.where(Transaction.recycler_id == recycler_id)
        if status:
            query = query.where(Transaction.transaction_status == TransactionStatus(status))
        if payment_status:
            query = query.where(Transaction.payment_status == PaymentStatus(payment_status))
        if settled is True:
            query = query.where(
                Transaction.collector_confirmed.is_(True),
                Transaction.recycler_confirmed.is_(True),
            )
        elif settled is False:
            query = query.where(
                (Transaction.collector_confirmed.is_(False))
                | (Transaction.recycler_confirmed.is_(False))
            )

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
