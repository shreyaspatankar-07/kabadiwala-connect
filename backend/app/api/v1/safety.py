"""FastAPI endpoints for Safety Guidance Cards and Collector Acknowledgements."""

from typing import Annotated, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.schemas.safety import (
    SafetyAcknowledgeRequest,
    SafetyAcknowledgeResponse,
    SafetyCardLocalized,
)
from app.services.safety_service import SafetyService

router = APIRouter(prefix="/safety", tags=["Safety Guidance"])


@router.get("", response_model=list[SafetyCardLocalized])
@router.get("/", response_model=list[SafetyCardLocalized])
async def get_safety_cards(
    language: Annotated[str, Query(description="Locale: mr (default), hi, en")] = "mr",
    category: Annotated[str | None, Query(description="Filter by scrap category")] = None,
    db: Annotated[AsyncSession, Depends(get_db)] = None,
) -> list[SafetyCardLocalized]:
    """Retrieve all safety instruction cards localized in Marathi, Hindi, or English."""
    return SafetyService.get_all_cards(language=language, category=category, db=db)


@router.get("/{topic_id}", response_model=SafetyCardLocalized)
async def get_safety_card_by_topic(
    topic_id: str,
    language: Annotated[str, Query(description="Locale: mr, hi, en")] = "mr",
    db: Annotated[AsyncSession, Depends(get_db)] = None,
) -> SafetyCardLocalized:
    """Retrieve full illustrated safety detail for a specific hazard topic."""
    card = SafetyService.get_card_by_topic(topic_id=topic_id, language=language, db=db)
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Safety topic '{topic_id}' not found",
        )
    return card


@router.post("/acknowledged", response_model=SafetyAcknowledgeResponse)
@router.post("/ack", response_model=SafetyAcknowledgeResponse)
async def acknowledge_safety_card(
    payload: SafetyAcknowledgeRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> SafetyAcknowledgeResponse:
    """Record collector 'I Understood' tick acknowledgement for audit and safety compliance."""
    return await SafetyService.record_acknowledgement(req=payload, db=db)


@router.post("/seed", status_code=status.HTTP_201_CREATED)
async def seed_safety_database(
    db: Annotated[AsyncSession, Depends(get_db)],
) -> dict[str, Any]:
    """Seed or update database with the authoritative 8 safety topics."""
    count = await SafetyService.seed_safety_content(db)
    return {"message": f"Successfully seeded {count} safety cards", "count": count}
