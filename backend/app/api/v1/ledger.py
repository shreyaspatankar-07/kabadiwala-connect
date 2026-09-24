"""Collector Ledger API router."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.errors import PermissionDeniedError
from app.models.schema import User
from app.schemas.ledger import LedgerEntryCreate, LedgerEntryResponse, LedgerSummary
from app.services.ledger_service import LedgerService

router = APIRouter(prefix="/ledger", tags=["Collector Ledger"])


@router.get(
    "/entries", response_model=list[LedgerEntryResponse], summary="List collector ledger entries"
)
async def list_ledger_entries(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
):
    if not current_user.collector_id:
        raise PermissionDeniedError("Ledger entries are only available for collectors.")

    return await LedgerService.list_entries(current_user.collector_id, db, limit=limit)


@router.get(
    "/summary", response_model=LedgerSummary, summary="Get collector ledger balance summary"
)
async def get_ledger_summary(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    if not current_user.collector_id:
        raise PermissionDeniedError("Ledger summary is only available for collectors.")

    return await LedgerService.get_summary(current_user.collector_id, db)


@router.post(
    "/entries",
    response_model=LedgerEntryResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Record a cash receipt or transaction entry in ledger",
)
async def create_ledger_entry(
    data: LedgerEntryCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    if not current_user.collector_id:
        raise PermissionDeniedError("Only collectors can record entries in their ledger.")

    return await LedgerService.create_entry(current_user.collector_id, data, db)
