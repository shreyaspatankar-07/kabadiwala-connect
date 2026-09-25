"""Matching service orchestrating database candidate extraction and ranking."""

from datetime import UTC, datetime
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.matching.reranker import LearnedReranker
from app.matching.schemas import (
    LotMatchInput,
    MatchRankingResponse,
    RankedRecycler,
    RecyclerCandidate,
)
from app.matching.scoring import rank_candidates_rule_based
from app.models.schema import AuthorizationStatus, Recycler, Transaction, TransactionStatus


class MatchingService:
    """Core discovery & ranking service for matching informal lots with authorized recyclers."""

    def __init__(self, reranker: LearnedReranker | None = None):
        self.reranker = reranker or LearnedReranker()

    async def _fetch_db_candidates(
        self, db: AsyncSession, category: str
    ) -> tuple[list[RecyclerCandidate], list[dict[str, Any]]]:
        """Loads verified recyclers from database and aggregates performance statistics."""
        # 1. Fetch verified recyclers
        query = select(Recycler).where(
            Recycler.authorization_status == AuthorizationStatus.VERIFIED
        )
        result = await db.execute(query)
        recycler_records = result.scalars().all()

        if not recycler_records:
            return [], []

        # 2. Performance stats from transactions table
        tx_query = (
            select(
                Transaction.recycler_id,
                func.count(Transaction.lot_id).label("total_tx"),
                func.count(Transaction.lot_id)
                .filter(Transaction.transaction_status == TransactionStatus.CONFIRMED)
                .label("completed_tx"),
            )
            .where(Transaction.recycler_id.isnot(None))
            .group_by(Transaction.recycler_id)
        )

        tx_res = await db.execute(tx_query)
        stats_map: dict[str, dict[str, float]] = {}
        for r_id, total, completed in tx_res.all():
            comp_rate = float(completed) / float(total) if total and total > 0 else 0.85
            stats_map[r_id] = {
                "completion_rate": comp_rate,
                "confirmation_speed_hours": 3.5,  # default fast response
            }

        candidates: list[RecyclerCandidate] = []
        for r in recycler_records:
            lat = 19.0760
            lng = 72.8777
            if hasattr(r, "facility_location") and r.facility_location is not None:
                try:
                    import shapely.wkb

                    geom = shapely.wkb.loads(bytes(r.facility_location.data))
                    lng, lat = geom.x, geom.y
                except Exception:
                    pass

            st = stats_map.get(r.id, {})
            cand = RecyclerCandidate(
                id=r.id,
                name=r.name,
                latitude=lat,
                longitude=lng,
                materials_accepted=r.materials_accepted or [],
                authorization_number=r.authorization_number,
                authorization_status=str(
                    r.authorization_status.value
                    if hasattr(r.authorization_status, "value")
                    else r.authorization_status
                ),
                authorization_valid_till=r.authorization_valid_till,
                phone=r.phone,
                offered_rates={k: float(v) for k, v in (r.offered_rates or {}).items()},
                pickup_available=r.pickup_available,
                pickup_radius_km=float(r.pickup_radius_km),
                service_area=r.service_area or {},
                rating=float(r.rating),
                completion_rate=st.get("completion_rate"),
                confirmation_speed_hours=st.get("confirmation_speed_hours"),
            )
            candidates.append(cand)

        # 3. Fetch past transactions to build training records for learned re-ranker
        training_records: list[dict[str, Any]] = []
        past_txs_res = await db.execute(
            select(Transaction).where(Transaction.recycler_id.isnot(None)).limit(200)
        )
        for t in past_txs_res.scalars().all():
            is_completed = 1 if t.transaction_status == TransactionStatus.CONFIRMED else 0
            # Mock historical features matching vector dimensions
            training_records.append(
                {
                    "features": [0.8, 0.7, 1.0, 0.9, 0.85, 0.8],
                    "label": is_completed,
                }
            )

        return candidates, training_records

    async def rank_recyclers(
        self,
        lot: LotMatchInput | dict[str, Any],
        db: AsyncSession | None = None,
        candidates: list[RecyclerCandidate] | None = None,
    ) -> MatchRankingResponse:
        """Ranks recyclers for a lot using rule-based or learned re-ranker."""
        if isinstance(lot, dict):
            lot = LotMatchInput(**lot)

        train_records: list[dict[str, Any]] = []
        if candidates is None:
            if db is None:
                raise ValueError("Either 'candidates' or 'db' session must be provided.")
            candidates, train_records = await self._fetch_db_candidates(db, lot.category)

        ranked: list[RankedRecycler]
        algo: str
        if train_records:
            ranked, algo = self.reranker.rank_recyclers(candidates, lot, train_records)
        else:
            ranked = rank_candidates_rule_based(candidates, lot)
            algo = "rule_based"

        return MatchRankingResponse(
            lot_id=lot.lot_id,
            category=lot.category,
            total_candidates_evaluated=len(candidates),
            candidates=ranked,
            algorithm=algo,
            matched_at=datetime.now(UTC),
        )


# Global singleton instance
_matching_service = MatchingService()


async def rank_recyclers(
    lot: LotMatchInput | dict[str, Any],
    db: AsyncSession | None = None,
    candidates: list[RecyclerCandidate] | None = None,
) -> MatchRankingResponse:
    """Convenience functional interface: matching.rank_recyclers(lot)."""
    return await _matching_service.rank_recyclers(lot, db=db, candidates=candidates)
