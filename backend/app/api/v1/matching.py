"""Matching API router for ranking recyclers for e-waste lots."""

from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.matching.schemas import LotMatchInput, MatchRankingResponse
from app.matching.service import rank_recyclers

router = APIRouter(prefix="/matching", tags=["Matching"])


@router.post(
    "/rank", response_model=MatchRankingResponse, summary="Rank top recyclers for an e-waste lot"
)
async def rank_lot_recyclers(
    lot: LotMatchInput,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Evaluates verified candidates against hard constraints (authorization, category, location)

    and applies multi-criteria scoring to return the top 3 ranked buyers.
    """
    return await rank_recyclers(lot, db=db)
