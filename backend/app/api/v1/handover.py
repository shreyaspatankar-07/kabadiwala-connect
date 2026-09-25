"""Handover API router for QR generation, recycler confirmation, and downstream EPR tracking."""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db, require_role
from app.models.schema import User
from app.schemas.handover import (
    DownstreamStatusResponse,
    DownstreamStatusUpdate,
    HandoverConfirmRequest,
    HandoverConfirmResponse,
    HandoverInitiateRequest,
    HandoverInitiateResponse,
)
from app.services.handover_service import HandoverService

router = APIRouter(prefix="/handover", tags=["Handover & Traceability"])


@router.post(
    "/initiate",
    response_model=HandoverInitiateResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Initiate verifiable handover and generate signed QR payload",
    dependencies=[Depends(require_role(["collector", "admin"]))],
)
async def initiate_handover(
    data: HandoverInitiateRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Collector initiates handover, producing a unique 6-character short code

    and a tamper-evident HMAC-SHA256 signed QR payload.
    """
    return await HandoverService.initiate_handover(
        data=data,
        db=db,
        collector_id=current_user.id,
    )


@router.post(
    "/confirm",
    response_model=HandoverConfirmResponse,
    summary="Recycler confirms physical handover via QR scan or short code",
    dependencies=[Depends(require_role(["recycler", "admin"]))],
)
async def confirm_handover(
    data: HandoverConfirmRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Recycler confirms physical handover by scanning the signed QR code or entering the 6-character code.

    Enforces weight mismatch tolerance (10%) and appends to the immutable hash chain.
    """
    return await HandoverService.confirm_handover(
        data=data,
        db=db,
        recycler_id=current_user.id,
    )


@router.post(
    "/{lot_id}/downstream",
    response_model=DownstreamStatusResponse,
    summary="Update EPR downstream processing lifecycle stage",
    dependencies=[Depends(require_role(["recycler", "admin"]))],
)
async def update_downstream_status(
    lot_id: str,
    data: DownstreamStatusUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Updates downstream lifecycle progress (received -> dismantled -> processed -> certificate_issued)."""
    return await HandoverService.update_downstream_status(
        lot_id=lot_id,
        status_str=data.status,
        db=db,
    )
