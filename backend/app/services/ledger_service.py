"""Cash-first ledger service for informal collectors."""

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.schema import LedgerEntry, LedgerEntryType, PaymentStatus
from app.schemas.ledger import LedgerEntryCreate, LedgerEntryResponse, LedgerSummary


class LedgerService:
    @staticmethod
    def _to_response(e: LedgerEntry) -> LedgerEntryResponse:
        return LedgerEntryResponse(
            id=e.id,
            collector_id=e.collector_id,
            lot_id=e.lot_id,
            entry_type=e.entry_type.value,
            amount=float(e.amount),
            payment_mode=e.payment_mode.value,
            description=e.description,
            balance_after=float(e.balance_after),
            recorded_at=e.recorded_at,
            created_at=e.created_at,
        )

    @classmethod
    async def list_entries(
        cls, collector_id: str, db: AsyncSession, limit: int = 50
    ) -> list[LedgerEntryResponse]:
        query = (
            select(LedgerEntry)
            .where(LedgerEntry.collector_id == collector_id)
            .order_by(LedgerEntry.recorded_at.desc())
            .limit(limit)
        )
        result = await db.execute(query)
        entries = result.scalars().all()
        return [cls._to_response(e) for e in entries]

    @classmethod
    async def create_entry(
        cls, collector_id: str, data: LedgerEntryCreate, db: AsyncSession
    ) -> LedgerEntryResponse:
        # Calculate latest balance
        stmt = (
            select(LedgerEntry.balance_after)
            .where(LedgerEntry.collector_id == collector_id)
            .order_by(LedgerEntry.recorded_at.desc(), LedgerEntry.created_at.desc())
            .limit(1)
        )
        res = await db.execute(stmt)
        last_bal = float(res.scalar_one_or_none() or 0.0)

        if data.entry_type == "credit":
            new_bal = round(last_bal + float(data.amount), 2)
        else:
            new_bal = round(max(last_bal - float(data.amount), 0.0), 2)

        entry = LedgerEntry(
            collector_id=collector_id,
            lot_id=data.lot_id,
            entry_type=LedgerEntryType(data.entry_type),
            amount=data.amount,
            payment_mode=PaymentStatus(data.payment_mode),
            description=data.description,
            balance_after=new_bal,
            recorded_at=data.recorded_at or datetime.now(UTC),
        )
        db.add(entry)
        await db.commit()
        await db.refresh(entry)
        return cls._to_response(entry)

    @classmethod
    async def get_summary(cls, collector_id: str, db: AsyncSession) -> LedgerSummary:
        # Sum credits
        stmt_credit = select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
            LedgerEntry.collector_id == collector_id,
            LedgerEntry.entry_type == LedgerEntryType.CREDIT,
        )
        total_earned = (await db.execute(stmt_credit)).scalar_one()

        # Sum cash received
        stmt_cash = select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
            LedgerEntry.collector_id == collector_id,
            LedgerEntry.entry_type == LedgerEntryType.CREDIT,
            LedgerEntry.payment_mode == PaymentStatus.CASH_RECEIVED,
        )
        cash_received = (await db.execute(stmt_cash)).scalar_one()

        # Count total
        stmt_count = select(func.count(LedgerEntry.id)).where(
            LedgerEntry.collector_id == collector_id
        )
        count = (await db.execute(stmt_count)).scalar_one()

        # Current balance
        stmt_latest = (
            select(LedgerEntry.balance_after)
            .where(LedgerEntry.collector_id == collector_id)
            .order_by(LedgerEntry.recorded_at.desc(), LedgerEntry.created_at.desc())
            .limit(1)
        )
        current_bal = (await db.execute(stmt_latest)).scalar_one_or_none() or 0.0

        pending = max(total_earned - cash_received, 0.0)

        return LedgerSummary(
            collector_id=collector_id,
            total_earned_inr=round(float(total_earned), 2),
            cash_received_inr=round(float(cash_received), 2),
            pending_inr=round(float(pending), 2),
            current_balance_inr=round(float(current_bal), 2),
            total_transactions=int(count),
        )
