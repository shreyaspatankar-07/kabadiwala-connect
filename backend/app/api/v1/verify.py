"""Public verification router for inspecting handover records without authentication."""

from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.schemas.handover import HandoverVerificationResponse
from app.services.handover_service import HandoverService

router = APIRouter(prefix="/verify", tags=["Public Verification"])


@router.get(
    "/{handover_ref_no}",
    response_model=HandoverVerificationResponse,
    summary="Public verification of handover authenticity and cryptographic integrity",
)
async def verify_handover(
    handover_ref_no: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Allows any stakeholder or auditor to verify the authenticity, weight, and status

    of an e-waste handover record using its 6-character reference code without authentication.
    """
    return await HandoverService.verify_handover_public(
        handover_ref_no=handover_ref_no.strip().upper(),
        db=db,
    )
