"""Comprehensive unit tests for backend services to achieve >=80% coverage."""

import uuid
from datetime import UTC, date, datetime, timedelta

import pytest
from geoalchemy2.elements import WKTElement
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, AuthenticationError, NotFoundError
from app.models.schema import (
    AuthorizationBody,
    AuthorizationStatus,
    HazardLevel,
    Recycler,
    SafetyContent,
)
from app.schemas.auth import (
    EmailLoginRequest,
    OTPRequest,
    OTPVerifyRequest,
    PINLoginRequest,
    PINSetupRequest,
    UserRegisterRequest,
)
from app.schemas.ledger import LedgerEntryCreate
from app.schemas.lots import LotCreate, LotStatusUpdate
from app.schemas.materials import MaterialCreate, MaterialUpdate
from app.schemas.prices import PriceCreate
from app.schemas.recyclers import RecyclerCreate, RecyclerUpdate
from app.schemas.sync import SyncOperation
from app.services.auth_service import AuthService
from app.services.ledger_service import LedgerService
from app.services.lots_service import LotsService
from app.services.materials_service import MaterialsService
from app.services.prices_service import PricesService
from app.services.recyclers_service import RecyclersService
from app.services.sync_service import SyncService

# ============================================================================
# AuthService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_auth_service_otp_flow(db_session: AsyncSession):
    # Request OTP
    req = OTPRequest(phone="+919111222333", language="mr")
    resp = await AuthService.request_otp(req)
    assert resp.status == "otp_sent"
    assert resp.mock_otp == "123456"

    # Verify invalid OTP
    with pytest.raises(AuthenticationError):
        await AuthService.verify_otp(
            OTPVerifyRequest(phone="+919111222333", otp="000000"),
            db_session,
        )

    # Verify valid OTP (new user)
    token_resp = await AuthService.verify_otp(
        OTPVerifyRequest(phone="+919111222333", otp="123456", operating_area="Nagpur"),
        db_session,
    )
    assert token_resp.role == "collector"
    assert token_resp.collector_id is not None
    assert token_resp.has_pin is False

    # Verify valid OTP again (existing user)
    token_resp2 = await AuthService.verify_otp(
        OTPVerifyRequest(phone="+919111222333", otp="123456"),
        db_session,
    )
    assert token_resp2.collector_id == token_resp.collector_id


@pytest.mark.asyncio
async def test_auth_service_pin_flow(db_session: AsyncSession, test_collector, test_admin):
    collector_user, _ = test_collector
    admin_user, _ = test_admin

    # Admin cannot setup PIN
    with pytest.raises(AppError):
        await AuthService.setup_pin(admin_user, PINSetupRequest(pin="1234"), db_session)

    # Collector setup PIN
    await AuthService.setup_pin(collector_user, PINSetupRequest(pin="5678"), db_session)

    # Login with valid PIN
    login_resp = await AuthService.login_with_pin(
        PINLoginRequest(phone=collector_user.phone, pin="5678"),
        db_session,
    )
    assert login_resp.has_pin is True
    assert login_resp.role == "collector"

    # Login with invalid PIN
    with pytest.raises(AuthenticationError):
        await AuthService.login_with_pin(
            PINLoginRequest(phone=collector_user.phone, pin="0000"),
            db_session,
        )

    # Login with non-existing phone
    with pytest.raises(AuthenticationError):
        await AuthService.login_with_pin(
            PINLoginRequest(phone="+919999999999", pin="5678"),
            db_session,
        )


@pytest.mark.asyncio
async def test_auth_service_email_flow(db_session: AsyncSession):
    reg_req = UserRegisterRequest(
        email="service_recycler@domain.com",
        password="ValidPassword123!",
        role="recycler",
        recycler_id="REC-SVC-01",
    )
    resp = await AuthService.register_user(reg_req, db_session)
    assert resp.role == "recycler"

    # Duplicate registration
    with pytest.raises(AppError) as exc_info:
        await AuthService.register_user(reg_req, db_session)
    assert exc_info.value.code == "EMAIL_EXISTS"

    # Login with email success
    login_resp = await AuthService.login_email(
        EmailLoginRequest(email="service_recycler@domain.com", password="ValidPassword123!"),
        db_session,
    )
    assert login_resp.access_token is not None

    # Login with wrong password
    with pytest.raises(AuthenticationError):
        await AuthService.login_email(
            EmailLoginRequest(email="service_recycler@domain.com", password="WrongPassword!"),
            db_session,
        )

    # Login with wrong email
    with pytest.raises(AuthenticationError):
        await AuthService.login_email(
            EmailLoginRequest(email="notfound@domain.com", password="ValidPassword123!"),
            db_session,
        )


# ============================================================================
# MaterialsService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_materials_service(db_session: AsyncSession):
    # Create material
    create_dto = MaterialCreate(
        category="e-waste",
        sub_category="CRT Monitor",
        description="Heavy CRT monitor with leaded glass",
        image_ref="crt_monitor.png",
        approx_weight_kg=12.5,
        condition="broken",
        source_type="household",
        estimated_value=150.0,
    )
    mat = await MaterialsService.create_material(create_dto, db_session)
    assert mat.category == "e-waste"
    assert mat.sub_category == "CRT Monitor"

    # Get material
    found = await MaterialsService.get_material(mat.id, db_session)
    assert found.id == mat.id

    # Get non-existent material
    with pytest.raises(NotFoundError):
        await MaterialsService.get_material(uuid.uuid4(), db_session)

    # List materials with filter
    all_mats = await MaterialsService.list_materials(db_session, category="e-waste")
    assert len(all_mats) >= 1
    empty_mats = await MaterialsService.list_materials(db_session, category="non-existent")
    assert len(empty_mats) == 0

    # Update material
    updated = await MaterialsService.update_material(
        mat.id,
        MaterialUpdate(
            description="Updated CRT monitor description",
            condition="damaged",
            estimated_value=180.0,
        ),
        db_session,
    )
    assert updated.description == "Updated CRT monitor description"
    assert updated.condition == "damaged"
    assert updated.estimated_value == 180.0

    # Update non-existent material
    with pytest.raises(NotFoundError):
        await MaterialsService.update_material(uuid.uuid4(), MaterialUpdate(), db_session)


# ============================================================================
# RecyclersService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_recyclers_service(db_session: AsyncSession):
    create_dto = RecyclerCreate(
        id="REC-SVC-TEST",
        name="Green Tech Recyclers",
        latitude=19.0760,
        longitude=72.8777,
        materials_accepted=["PCB", "Batteries"],
        authorization_number="AUTH-MH-2024-001",
        authorization_body="CPCB",
        authorization_valid_till=date.today() + timedelta(days=365),
        phone="+919876543210",
        offered_rates={"PCB": 120.0, "Batteries": 45.0},
        pickup_available=True,
        pickup_radius_km=25.0,
        service_area={"district": "Mumbai"},
    )
    rec = await RecyclersService.create_recycler(create_dto, db_session)
    assert rec.id == "REC-SVC-TEST"
    assert rec.authorization_status == "pending"

    # Get recycler
    found = await RecyclersService.get_recycler("REC-SVC-TEST", db_session)
    assert found.name == "Green Tech Recyclers"

    # Not found
    with pytest.raises(NotFoundError):
        await RecyclersService.get_recycler("REC-NON-EXISTENT", db_session)

    # List recyclers with filter
    recs = await RecyclersService.list_recyclers(db_session, status="pending", category="PCB")
    assert len(recs) >= 1
    assert recs[0].id == "REC-SVC-TEST"

    # Update recycler
    updated = await RecyclersService.update_recycler(
        "REC-SVC-TEST",
        RecyclerUpdate(name="Green Tech Recyclers Pvt Ltd", phone="+919999888877"),
        db_session,
    )
    assert updated.name == "Green Tech Recyclers Pvt Ltd"
    assert updated.phone == "+919999888877"

    with pytest.raises(NotFoundError):
        await RecyclersService.update_recycler("REC-NOT-FOUND", RecyclerUpdate(), db_session)

    # Verification workflow: Admin verifies recycler
    verified = await RecyclersService.update_verification_status(
        "REC-SVC-TEST", "verified", db_session
    )
    assert verified.authorization_status == "verified"

    with pytest.raises(NotFoundError):
        await RecyclersService.update_verification_status("REC-NOT-FOUND", "verified", db_session)

    # Audit expired authorizations
    # Add an expired recycler
    expired_pt = WKTElement("POINT(72.8777 19.0760)", srid=4326)
    expired_rec = Recycler(
        id="REC-EXPIRED-TEST",
        name="Old Recycler",
        facility_location=expired_pt,
        materials_accepted=["PCB"],
        authorization_number="AUTH-OLD",
        authorization_body=AuthorizationBody.SPCB,
        authorization_status=AuthorizationStatus.VERIFIED,
        authorization_valid_till=date.today() - timedelta(days=10),
        phone="+919000000000",
    )
    db_session.add(expired_rec)
    await db_session.commit()

    count = await RecyclersService.check_expired_authorizations(db_session)
    assert count >= 1

    audited = await RecyclersService.get_recycler("REC-EXPIRED-TEST", db_session)
    assert audited.authorization_status == "expired"


# ============================================================================
# PricesService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_prices_service(db_session: AsyncSession):
    create_dto = PriceCreate(
        category="PCB",
        sub_category="Motherboard High Grade",
        district="Pune",
        city="Pune",
        latitude=18.5204,
        longitude=73.8567,
        buying_price=150.0,
        selling_quoted_price=165.0,
        unit="kg",
        market_min=140.0,
        market_max=170.0,
        source="recycler_quote",
    )
    p = await PricesService.create_price(create_dto, db_session)
    assert p.category == "PCB"
    assert p.buying_price == 150.0

    # Get price
    found = await PricesService.get_price(p.id, db_session)
    assert found.id == p.id

    # Not found
    with pytest.raises(NotFoundError):
        await PricesService.get_price(uuid.uuid4(), db_session)

    # List prices
    prices = await PricesService.list_prices(db_session, district="Pune", category="PCB")
    assert len(prices) >= 1

    # Price board aggregation
    board = await PricesService.get_price_board("Pune", db_session)
    assert board.district == "Pune"
    assert len(board.rates) >= 1
    assert board.rates[0].sub_category == "Motherboard High Grade"
    assert board.rates[0].min_rate_inr == 140.0
    assert board.rates[0].max_rate_inr == 170.0


# ============================================================================
# LotsService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_lots_service(db_session: AsyncSession, test_collector):
    col, _ = test_collector
    collector_id = col.collector_id

    lot_dto = LotCreate(
        client_lot_id="client-lot-svc-001",
        category="Batteries",
        weight_kg=15.0,
        quoted_price=750.0,
        collection_lat=18.5204,
        collection_lng=73.8567,
        photo_hashes=["hash1", "hash2"],
    )

    # 1. Create lot
    lot = await LotsService.create_or_get_lot(collector_id, lot_dto, db_session)
    assert lot.category == "Batteries"
    assert lot.weight_kg == 15.0
    assert lot.transaction_status == "listed"

    # 2. Idempotency replay (same client_lot_id returns same lot)
    replay = await LotsService.create_or_get_lot(collector_id, lot_dto, db_session)
    assert replay.lot_id == lot.lot_id

    # 3. Get lot
    found = await LotsService.get_lot(lot.lot_id, db_session)
    assert found.lot_id == lot.lot_id

    with pytest.raises(NotFoundError):
        await LotsService.get_lot("NON-EXISTENT-LOT", db_session)

    # 4. List lots with filters
    lots_list = await LotsService.list_lots(
        db_session,
        collector_id=collector_id,
        status="listed",
    )
    assert len(lots_list) >= 1

    # 5. Update lot status & handover
    updated = await LotsService.update_lot_status(
        lot.lot_id,
        LotStatusUpdate(
            transaction_status="confirmed",
            final_price=720.0,
            recycler_id="REC-MH-01",
            handover_lat=18.5200,
            handover_lng=73.8560,
            anomaly_flag=False,
        ),
        db_session,
    )
    assert updated.transaction_status == "confirmed"
    assert updated.final_price == 720.0
    assert updated.handover_lat == 18.5200

    with pytest.raises(NotFoundError):
        await LotsService.update_lot_status(
            "NON-EXISTENT-LOT",
            LotStatusUpdate(transaction_status="confirmed"),
            db_session,
        )


# ============================================================================
# LedgerService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_ledger_service(db_session: AsyncSession, test_collector):
    col, _ = test_collector
    collector_id = col.collector_id

    # Credit entry
    credit_dto = LedgerEntryCreate(
        entry_type="credit",
        amount=500.0,
        payment_mode="cash_received",
        description="Lot cash payment",
        lot_id="KC-MH-2609-TEST01",
    )
    entry1 = await LedgerService.create_entry(collector_id, credit_dto, db_session)
    assert entry1.amount == 500.0
    assert entry1.balance_after == 500.0

    # Debit entry (e.g. transport cost)
    debit_dto = LedgerEntryCreate(
        entry_type="debit",
        amount=100.0,
        payment_mode="cash_received",
        description="Cart fuel/transport",
    )
    entry2 = await LedgerService.create_entry(collector_id, debit_dto, db_session)
    assert entry2.amount == 100.0
    assert entry2.balance_after == 400.0

    # List entries
    entries = await LedgerService.list_entries(collector_id, db_session)
    assert len(entries) >= 2

    # Get summary
    summary = await LedgerService.get_summary(collector_id, db_session)
    assert summary.total_earned_inr == 500.0
    assert summary.cash_received_inr == 500.0
    assert summary.current_balance_inr == 400.0
    assert summary.total_transactions == 2


# ============================================================================
# SyncService Tests
# ============================================================================


@pytest.mark.asyncio
async def test_sync_service(db_session: AsyncSession, test_collector):
    col, _ = test_collector
    collector_id = col.collector_id

    # Insert a safety content item
    sc = SafetyContent(
        id="SAFE-BATT-01",
        category="Lithium Batteries",
        hazard_level=HazardLevel.DANGER,
        pictogram_url="/pictograms/fire.png",
        title_vernacular={"mr": "बॅटरी सुरक्षा", "hi": "बैटरी सुरक्षा"},
        instructions_vernacular={"mr": "पाणी टाकू नका", "hi": "पानी न डालें"},
        dos=["Keep away from water", "Store in cool place"],
        donts=["Do not puncture", "Do not expose to fire"],
    )
    db_session.add(sc)
    await db_session.commit()

    # Batch Push
    ops = [
        SyncOperation(
            client_tx_id="sync-tx-001",
            action="create_lot",
            payload={
                "client_lot_id": "sync-client-lot-1",
                "category": "E-waste",
                "weight_kg": 5.0,
                "quoted_price": 200.0,
                "collection_lat": 18.52,
                "collection_lng": 73.85,
            },
            client_timestamp=datetime.now(UTC),
        ),
        SyncOperation(
            client_tx_id="sync-tx-002",
            action="record_cash_payment",
            payload={
                "entry_type": "credit",
                "amount": 200.0,
                "payment_mode": "cash_received",
                "description": "Cash from sync lot",
            },
            client_timestamp=datetime.now(UTC),
        ),
        SyncOperation(
            client_tx_id="sync-tx-003",
            action="create_lot",
            payload={"invalid": "payload"},
            client_timestamp=datetime.now(UTC),
        ),
        SyncOperation(
            client_tx_id="sync-tx-004",
            action="update_lot",
            payload={
                "lot_id": "KC-MH-NONEXISTENT",
                "transaction_status": "confirmed",
            },
            client_timestamp=datetime.now(UTC),
        ),
    ]

    push_res = await SyncService.push_batch(collector_id, ops, db_session)
    assert "sync-tx-001" in push_res.processed
    assert "sync-tx-002" in push_res.processed
    assert len(push_res.conflicts) >= 1

    # Replay identical batch push (idempotent)
    push_res_replay = await SyncService.push_batch(collector_id, ops[:2], db_session)
    assert "sync-tx-001" in push_res_replay.processed
    assert "sync-tx-002" in push_res_replay.processed

    # Pull Delta (since beginning of time)
    pull_res = await SyncService.pull_delta(collector_id=collector_id, since=None, db=db_session)
    assert len(pull_res.safety_content) >= 1
    assert len(pull_res.my_lots) >= 1
    assert len(pull_res.my_ledger) >= 1
    assert pull_res.cursor is not None

    # Pull Delta with future since (should return empty delta)
    future_time = datetime.now(UTC) + timedelta(days=1)
    pull_future = await SyncService.pull_delta(
        collector_id=collector_id, since=future_time, db=db_session
    )
    assert len(pull_future.my_lots) == 0
    assert len(pull_future.my_ledger) == 0
