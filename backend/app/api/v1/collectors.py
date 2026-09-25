"""Collectors and privacy data deletion router."""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy import delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.models.schema import (
    Collector,
    LedgerEntry,
    SafetyAcknowledgement,
    SyncQueue,
    Transaction,
    User,
)

router = APIRouter(prefix="/collectors", tags=["Collectors & Privacy"])


@router.delete(
    "/{collector_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete collector data (Right to be Forgotten & Privacy)",
)
async def delete_collector_data(
    collector_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Purge collector records across local sync queues, ledgers, transactions, and user account."""
    # 1. Delete sync queue entries
    await db.execute(delete(SyncQueue).where(SyncQueue.collector_id == collector_id))

    # 2. Delete safety acknowledgements
    await db.execute(
        delete(SafetyAcknowledgement).where(SafetyAcknowledgement.collector_id == collector_id)
    )

    # 3. Delete ledgers
    await db.execute(delete(LedgerEntry).where(LedgerEntry.collector_id == collector_id))

    # 4. Delete transactions
    await db.execute(delete(Transaction).where(Transaction.collector_id == collector_id))

    # 5. Delete user login if linked
    await db.execute(delete(User).where(User.collector_id == collector_id))

    # 6. Delete collector profile
    await db.execute(delete(Collector).where(Collector.collector_id == collector_id))

    await db.commit()

    return {
        "status": "deleted",
        "collector_id": collector_id,
        "message": "All personal collector records purged successfully.",
    }
