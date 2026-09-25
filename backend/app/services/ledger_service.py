"""Cash-first ledger service for informal collectors."""

from datetime import UTC, datetime, timedelta
import secrets
import uuid

from sqlalchemy import desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.errors import NotFoundError, PermissionDeniedError
from app.models.schema import (
    LedgerEntry,
    LedgerEntryType,
    PaymentStatus,
    Recycler,
    Transaction,
)
from app.schemas.ledger import (
    CollectorLedgerOverview,
    EarningsStatementItem,
    EarningsStatementResponse,
    LedgerEntryCreate,
    LedgerEntryResponse,
    LedgerSummary,
    LedgerTransactionItem,
    MarkCashReceivedResponse,
    RecyclerConfirmCashResponse,
    UPIIntentResponse,
)


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

    @classmethod
    async def get_collector_overview(
        cls, collector_id: str, db: AsyncSession
    ) -> CollectorLedgerOverview:
        """Retrieves today, week, month, all-time totals, pending dues, and transaction items."""
        now = datetime.now(UTC)
        today_start = datetime(now.year, now.month, now.day, tzinfo=UTC)
        week_start = now - timedelta(days=7)
        month_start = now - timedelta(days=30)

        # 1. Total all-time credits
        res_all = await db.execute(
            select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
                LedgerEntry.collector_id == collector_id,
                LedgerEntry.entry_type == LedgerEntryType.CREDIT,
            )
        )
        all_time_total = float(res_all.scalar_one())

        # 2. Today credits
        res_today = await db.execute(
            select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
                LedgerEntry.collector_id == collector_id,
                LedgerEntry.entry_type == LedgerEntryType.CREDIT,
                LedgerEntry.recorded_at >= today_start,
            )
        )
        today_total = float(res_today.scalar_one())

        # 3. Week credits
        res_week = await db.execute(
            select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
                LedgerEntry.collector_id == collector_id,
                LedgerEntry.entry_type == LedgerEntryType.CREDIT,
                LedgerEntry.recorded_at >= week_start,
            )
        )
        week_total = float(res_week.scalar_one())

        # 4. Month credits
        res_month = await db.execute(
            select(func.coalesce(func.sum(LedgerEntry.amount), 0.0)).where(
                LedgerEntry.collector_id == collector_id,
                LedgerEntry.entry_type == LedgerEntryType.CREDIT,
                LedgerEntry.recorded_at >= month_start,
            )
        )
        month_total = float(res_month.scalar_one())

        # 5. Pending dues (from transactions awaiting payment)
        pending_stmt = select(
            func.count(Transaction.lot_id),
            func.coalesce(
                func.sum(func.coalesce(Transaction.final_price, Transaction.quoted_price)), 0.0
            ),
        ).where(
            Transaction.collector_id == collector_id,
            Transaction.payment_status == PaymentStatus.PENDING,
        )
        pending_res = (await db.execute(pending_stmt)).one()
        pending_count = int(pending_res[0])
        pending_amount = float(pending_res[1])

        # 6. Detailed transaction list
        entries_stmt = (
            select(LedgerEntry)
            .where(LedgerEntry.collector_id == collector_id)
            .options(selectinload(LedgerEntry.transaction).selectinload(Transaction.recycler))
            .order_by(desc(LedgerEntry.recorded_at))
            .limit(100)
        )
        entries_res = await db.execute(entries_stmt)
        entries = entries_res.scalars().all()

        tx_items: list[LedgerTransactionItem] = []
        for e in entries:
            tx = e.transaction
            category = tx.category if tx else "E-Waste"
            weight_kg = float(tx.weight_kg) if tx else 0.0
            final_price = float(e.amount)
            recycler_name = (
                tx.recycler.name if (tx and tx.recycler) else "Authorized Recycler Hub"
            )
            pay_status = (
                "disputed"
                if (tx and tx.anomaly_flag)
                else (tx.payment_status.value if tx else e.payment_mode.value)
            )

            tx_items.append(
                LedgerTransactionItem(
                    entry_id=str(e.id),
                    lot_id=e.lot_id,
                    category=category,
                    weight_kg=weight_kg,
                    final_price=final_price,
                    payment_status=pay_status,
                    recycler_name=recycler_name,
                    date=e.recorded_at,
                )
            )

        return CollectorLedgerOverview(
            collector_id=collector_id,
            today_total=round(today_total, 2),
            week_total=round(week_total, 2),
            month_total=round(month_total, 2),
            all_time_total=round(all_time_total, 2),
            pending_dues_count=pending_count,
            pending_dues_amount=round(pending_amount, 2),
            transactions=tx_items,
        )

    @classmethod
    async def mark_cash_received(
        cls, entry_id: uuid.UUID, collector_id: str, db: AsyncSession
    ) -> MarkCashReceivedResponse:
        """Collector marks a pending entry and associated lot as cash received."""
        stmt = (
            select(LedgerEntry)
            .where(LedgerEntry.id == entry_id)
            .options(selectinload(LedgerEntry.transaction))
        )
        res = await db.execute(stmt)
        entry = res.scalar_one_or_none()

        if not entry:
            raise NotFoundError(f"Ledger entry {entry_id} not found.")

        if entry.collector_id != collector_id:
            raise PermissionDeniedError("Cannot modify another collector's ledger entry.")

        # Update entry payment mode
        entry.payment_mode = PaymentStatus.CASH_RECEIVED

        # Update associated transaction if present
        tx = entry.transaction
        if tx:
            tx.payment_status = PaymentStatus.CASH_RECEIVED

        await db.commit()
        await db.refresh(entry)

        return MarkCashReceivedResponse(
            entry_id=str(entry.id),
            lot_id=entry.lot_id,
            payment_status=PaymentStatus.CASH_RECEIVED.value,
            collector_confirmed=True,
            recycler_confirmed=False,
            is_disputed=tx.anomaly_flag if tx else False,
            message="Cash received recorded successfully.",
        )

    @classmethod
    async def recycler_confirm_cash(
        cls, entry_id: uuid.UUID, recycler_amount: float, db: AsyncSession
    ) -> RecyclerConfirmCashResponse:
        """Recycler confirms cash payment. Flags dispute if amount does not match."""
        stmt = (
            select(LedgerEntry)
            .where(LedgerEntry.id == entry_id)
            .options(selectinload(LedgerEntry.transaction))
        )
        res = await db.execute(stmt)
        entry = res.scalar_one_or_none()

        if not entry:
            raise NotFoundError(f"Ledger entry {entry_id} not found.")

        delta = abs(float(entry.amount) - recycler_amount)
        is_disputed = delta > 0.01
        dispute_reason = None

        tx = entry.transaction
        if is_disputed:
            dispute_reason = (
                f"Cash amount mismatch: collector reported ₹{float(entry.amount):.2f}, "
                f"recycler reported ₹{recycler_amount:.2f}"
            )
            if tx:
                tx.anomaly_flag = True
                tx.anomaly_reason = dispute_reason
        else:
            if tx:
                tx.payment_status = PaymentStatus.CASH_RECEIVED

        await db.commit()

        return RecyclerConfirmCashResponse(
            entry_id=str(entry.id),
            lot_id=entry.lot_id,
            payment_status="disputed" if is_disputed else PaymentStatus.CASH_RECEIVED.value,
            is_disputed=is_disputed,
            dispute_reason=dispute_reason,
        )

    @classmethod
    async def get_earnings_statement(
        cls,
        collector_id: str,
        from_date: datetime,
        to_date: datetime,
        db: AsyncSession,
    ) -> EarningsStatementResponse:
        """Generates a structured earnings statement for income proof export."""
        stmt = (
            select(LedgerEntry)
            .where(
                LedgerEntry.collector_id == collector_id,
                LedgerEntry.entry_type == LedgerEntryType.CREDIT,
                LedgerEntry.recorded_at >= from_date,
                LedgerEntry.recorded_at <= to_date,
            )
            .options(selectinload(LedgerEntry.transaction).selectinload(Transaction.recycler))
            .order_by(desc(LedgerEntry.recorded_at))
        )
        res = await db.execute(stmt)
        entries = res.scalars().all()

        total_earned = 0.0
        cash_received = 0.0
        pending_amount = 0.0
        total_weight = 0.0
        items: list[EarningsStatementItem] = []

        for e in entries:
            amt = float(e.amount)
            total_earned += amt
            if e.payment_mode == PaymentStatus.CASH_RECEIVED:
                cash_received += amt
            else:
                pending_amount += amt

            tx = e.transaction
            weight = float(tx.weight_kg) if tx else 0.0
            total_weight += weight
            cat = tx.category if tx else "E-Waste"
            r_name = tx.recycler.name if (tx and tx.recycler) else "Authorized Recycler"
            status_val = (
                "disputed"
                if (tx and tx.anomaly_flag)
                else (tx.payment_status.value if tx else e.payment_mode.value)
            )

            items.append(
                EarningsStatementItem(
                    lot_id=e.lot_id,
                    category=cat,
                    weight_kg=weight,
                    amount=amt,
                    payment_status=status_val,
                    recycler_name=r_name,
                    date=e.recorded_at,
                )
            )

        ref_no = f"STMT-KC-{datetime.now(UTC).strftime('%y%m')}-{secrets.token_hex(3).upper()}"

        return EarningsStatementResponse(
            statement_ref_no=ref_no,
            collector_id=collector_id,
            from_date=from_date,
            to_date=to_date,
            total_earned=round(total_earned, 2),
            cash_received=round(cash_received, 2),
            pending_amount=round(pending_amount, 2),
            total_transactions=len(items),
            total_weight_kg=round(total_weight, 2),
            items=items,
            generated_at=datetime.now(UTC),
        )

    @classmethod
    async def get_upi_intent(
        cls, entry_id: uuid.UUID, collector_id: str, db: AsyncSession
    ) -> UPIIntentResponse:
        """Generates an optional NPCI UPI intent string for digital payment opt-in."""
        stmt = (
            select(LedgerEntry)
            .where(LedgerEntry.id == entry_id)
            .options(selectinload(LedgerEntry.transaction).selectinload(Transaction.recycler))
        )
        res = await db.execute(stmt)
        entry = res.scalar_one_or_none()

        if not entry:
            raise NotFoundError(f"Ledger entry {entry_id} not found.")

        amt = float(entry.amount)
        tx = entry.transaction
        payee_name = (
            tx.recycler.name if (tx and tx.recycler) else "Kabadiwala Connect Authorized Recycler"
        )
        payee_vpa = "collector.kabadiwala@upi"
        lot_tag = f"Lot {entry.lot_id}" if entry.lot_id else "E-Waste Handover"

        # NPCI UPI Standard Deep Link URI
        clean_name = payee_name.replace(" ", "%20")
        clean_note = f"Payment for {lot_tag}".replace(" ", "%20")
        upi_uri = f"upi://pay?pa={payee_vpa}&pn={clean_name}&am={amt:.2f}&cu=INR&tn={clean_note}"

        return UPIIntentResponse(
            entry_id=str(entry.id),
            amount=amt,
            upi_uri=upi_uri,
            payee_name=payee_name,
            payee_vpa=payee_vpa,
        )
