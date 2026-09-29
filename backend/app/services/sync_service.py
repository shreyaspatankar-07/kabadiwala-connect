import hashlib
import json
from datetime import UTC, datetime
from typing import Any

from geoalchemy2.elements import WKTElement
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.schema import DownstreamStatus, SafetyContent, SyncActionStatus, SyncQueue, Traceability
from app.schemas.ledger import LedgerEntryCreate
from app.schemas.lots import LotCreate, LotStatusUpdate
from app.schemas.sync import (
    SafetyContentItem,
    SyncOperation,
    SyncPullResponse,
    SyncPushResponse,
)
from app.services.ledger_service import LedgerService
from app.services.lots_service import LotsService
from app.services.materials_service import MaterialsService
from app.services.prices_service import PricesService
from app.services.recyclers_service import RecyclersService


def _normalize_dt(dt: datetime | None) -> datetime | None:
    if dt is None:
        return None
    if dt.tzinfo is None:
        return dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


class SyncService:
    @staticmethod
    async def push_batch(
        collector_id: str,
        operations: list[SyncOperation],
        db: AsyncSession,
    ) -> SyncPushResponse:
        processed_ids: list[str] = []
        conflicts: list[dict[str, Any]] = []

        for op in operations:
            # Idempotency check: see if client_tx_id has already been processed
            res = await db.execute(
                select(SyncQueue).where(
                    SyncQueue.client_tx_id == op.client_tx_id,
                    SyncQueue.collector_id == collector_id,
                )
            )
            existing = res.scalar_one_or_none()
            if existing and existing.status == SyncActionStatus.COMPLETED:
                processed_ids.append(op.client_tx_id)
                continue

            try:
                if op.action == "create_lot":
                    lot_create = LotCreate(**op.payload)
                    await LotsService.create_or_get_lot(collector_id, lot_create, db)

                elif op.action == "record_cash_payment":
                    entry_create = LedgerEntryCreate(**op.payload)
                    await LedgerService.create_entry(collector_id, entry_create, db)

                elif op.action == "record_handover":
                    lot_id = op.payload.get("lot_id")
                    ref_no = op.payload.get("handover_ref_no")
                    if lot_id and ref_no:
                        trace_res = await db.execute(
                            select(Traceability).where(Traceability.lot_id == lot_id)
                        )
                        existing_trace = trace_res.scalar_one_or_none()
                        if existing_trace:
                            existing_trace.handover_ref_no = ref_no
                            if "signature" in op.payload:
                                existing_trace.qr_payload = json.dumps(op.payload, separators=(",", ":"))
                        else:
                            now_utc = datetime.now(UTC)
                            qr_payload_str = json.dumps(op.payload, separators=(",", ":"))
                            rec_hash = hashlib.sha256(f"{qr_payload_str}:{'0'*64}".encode()).hexdigest()
                            new_trace = Traceability(
                                lot_id=lot_id,
                                photo_hashes=op.payload.get("photo_hashes", []),
                                weight_kg=float(op.payload.get("weight_kg", 0.0)),
                                timestamp=now_utc,
                                gps_lat=float(op.payload.get("gps_lat", 19.0760)),
                                gps_lng=float(op.payload.get("gps_lng", 72.8777)),
                                location=WKTElement(f"POINT({op.payload.get('gps_lng', 72.8777)} {op.payload.get('gps_lat', 19.0760)})", srid=4326),
                                handover_ref_no=ref_no,
                                qr_payload=qr_payload_str,
                                recycler_confirmation=False,
                                downstream_status=DownstreamStatus.RECEIVED,
                                record_hash=rec_hash,
                                prev_hash="0" * 64,
                                created_at=now_utc,
                            )
                            db.add(new_trace)

                processed_ids.append(op.client_tx_id)

            except Exception as e:
                conflicts.append({"client_tx_id": op.client_tx_id, "error": str(e)})

        await db.commit()
        return SyncPushResponse(
            processed=processed_ids,
            conflicts=conflicts,
            server_time=datetime.now(UTC),
        )

    @staticmethod
    async def pull_delta(
        collector_id: str | None,
        since: datetime | None,
        db: AsyncSession,
    ) -> SyncPullResponse:
        norm_since = _normalize_dt(since)

        # 1. Materials
        materials = await MaterialsService.list_materials(db)
        if norm_since:
            materials = [m for m in materials if _normalize_dt(m.updated_at) >= norm_since]

        # 2. Prices
        prices = await PricesService.list_prices(db)
        if norm_since:
            prices = [p for p in prices if _normalize_dt(p.recorded_at) >= norm_since]

        # 3. Recyclers
        recyclers = await RecyclersService.list_recyclers(db)
        if norm_since:
            recyclers = [r for r in recyclers if _normalize_dt(r.updated_at) >= norm_since]

        # 4. Safety content
        res_safety = await db.execute(select(SafetyContent))
        safety_rows = res_safety.scalars().all()
        safety_items = [
            SafetyContentItem(
                id=s.id,
                category=s.category,
                hazard_level=s.hazard_level.value,
                pictogram_url=s.pictogram_url,
                audio_prompt_urls=s.audio_prompt_urls,
                title_vernacular=s.title_vernacular,
                instructions_vernacular=s.instructions_vernacular,
                dos=s.dos,
                donts=s.donts,
            )
            for s in safety_rows
        ]

        # 5. Collector's own lots
        my_lots = []
        if collector_id:
            all_lots = await LotsService.list_lots(db, collector_id=collector_id, limit=200)
            my_lots = (
                [lot for lot in all_lots if _normalize_dt(lot.updated_at) >= norm_since]
                if norm_since
                else all_lots
            )

        # 6. Collector's own ledger
        my_ledger = []
        if collector_id:
            all_entries = await LedgerService.list_entries(collector_id, db, limit=200)
            my_ledger = (
                [entry for entry in all_entries if _normalize_dt(entry.recorded_at) >= norm_since]
                if norm_since
                else all_entries
            )

        now = datetime.now(UTC)
        return SyncPullResponse(
            cursor=now.isoformat(),
            server_time=now,
            materials=materials,
            prices=prices,
            recyclers=recyclers,
            safety_content=safety_items,
            my_lots=my_lots,
            my_ledger=my_ledger,
        )
