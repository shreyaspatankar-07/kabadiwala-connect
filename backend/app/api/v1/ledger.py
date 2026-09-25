"""Collector Ledger API router."""

from datetime import UTC, datetime, timedelta
from typing import Annotated
import uuid

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.errors import BadRequestError, PermissionDeniedError
from app.models.schema import User
from app.schemas.ledger import (
    CollectorLedgerOverview,
    EarningsStatementResponse,
    LedgerEntryCreate,
    LedgerEntryResponse,
    LedgerSummary,
    MarkCashReceivedResponse,
    RecyclerConfirmCashRequest,
    RecyclerConfirmCashResponse,
    UPIIntentResponse,
)
from app.services.ledger_service import LedgerService

router = APIRouter(prefix="/ledger", tags=["Collector Ledger"])


@router.get(
    "",
    response_model=CollectorLedgerOverview,
    summary="Get collector earnings overview with today, week, month, all-time totals and transaction list",
)
async def get_collector_ledger(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    collector_id: Annotated[str | None, Query(description="Collector ID to query")] = None,
):
    target_id = collector_id or current_user.collector_id
    if not target_id:
        raise BadRequestError("collector_id parameter or collector authentication is required.")

    return await LedgerService.get_collector_overview(target_id, db)


@router.post(
    "/{entry_id}/mark-cash-received",
    response_model=MarkCashReceivedResponse,
    summary="Collector marks a pending entry as cash received",
)
async def mark_cash_received(
    entry_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    target_collector_id = current_user.collector_id
    if not target_collector_id:
        raise PermissionDeniedError("Only collectors can mark cash received.")

    return await LedgerService.mark_cash_received(entry_id, target_collector_id, db)


@router.post(
    "/{entry_id}/recycler-confirm-cash",
    response_model=RecyclerConfirmCashResponse,
    summary="Recycler confirms cash payment. Flags transaction as disputed if amounts mismatch.",
)
async def recycler_confirm_cash(
    entry_id: uuid.UUID,
    data: RecyclerConfirmCashRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    # Stub endpoint for recycler portal verification
    return await LedgerService.recycler_confirm_cash(entry_id, data.recycler_confirmed_amount, db)


def _parse_statement_dt(val: str | None, default: datetime) -> datetime:
    if not val:
        return default
    # Replace space with + if timezone was decoded
    clean = val.replace(" ", "+")
    try:
        dt = datetime.fromisoformat(clean)
        return dt if dt.tzinfo else dt.replace(tzinfo=UTC)
    except Exception:
        return default


@router.get(
    "/statement",
    response_model=EarningsStatementResponse,
    summary="Get structured earnings statement for income proof export",
)
async def get_earnings_statement(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    collector_id: Annotated[str | None, Query()] = None,
    from_date: Annotated[str | None, Query(alias="from")] = None,
    to_date: Annotated[str | None, Query(alias="to")] = None,
):
    target_id = collector_id or current_user.collector_id
    if not target_id:
        raise BadRequestError("collector_id parameter or collector authentication is required.")

    now = datetime.now(UTC)
    start = _parse_statement_dt(from_date, now - timedelta(days=30))
    end = _parse_statement_dt(to_date, now)

    return await LedgerService.get_earnings_statement(target_id, start, end, db)


@router.post(
    "/{entry_id}/upi-intent",
    response_model=UPIIntentResponse,
    summary="Generate optional NPCI UPI payment deep link string when collector opts in",
)
async def get_upi_intent(
    entry_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    target_id = current_user.collector_id
    if not target_id:
        raise PermissionDeniedError("Only collectors can request UPI payment intents.")

    return await LedgerService.get_upi_intent(entry_id, target_id, db)


# ------------------------------------------------------------------------------
# Existing Endpoints preserved for backwards compatibility
# ------------------------------------------------------------------------------


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
