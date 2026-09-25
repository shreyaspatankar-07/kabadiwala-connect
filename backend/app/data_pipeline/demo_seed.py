"""One-Command Demo Seed Script for Kabadiwala Connect.

Seeds the database with:
1. 8 authorized recyclers across Palghar, Thane, Mumbai, Pune, Nashik, Nagpur (synthetic provenance).
2. 60 days of historical price points for all 7 material categories in all 6 districts.
3. 3 sample collectors with transaction history (at least 5 transactions each, mix of completed/pending/disputed) and financial ledger.
4. 3 flagged anomalous transactions with distinct anomaly reasons (price outlier, weight implausible, rapid burst).
5. All 8 multilingual safety guidance topics (via SafetyService).

Usage:
  py -3.11 -m app.data_pipeline.demo_seed
"""

import asyncio
from datetime import UTC, date, datetime, timedelta
import random
from typing import Any
import uuid

from geoalchemy2 import WKTElement
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import AsyncSessionLocal
from app.data_pipeline.generator import CATEGORY_SPECS, MAHARASHTRA_DISTRICTS
from app.models.schema import (
    AuthorizationBody,
    AuthorizationStatus,
    Collector,
    LedgerEntry,
    LedgerEntryType,
    PaymentStatus,
    PreferredLanguage,
    Price,
    PriceSource,
    PriceUnit,
    Recycler,
    SafetyContent,
    Traceability,
    Transaction,
    TransactionStatus,
    User,
    UserRole,
)
from app.services.safety_service import SafetyService

# -----------------------------------------------------------------------------
# 1. Recycler Demo Data (8 Authorized Recyclers across 6 Districts)
# -----------------------------------------------------------------------------

DEMO_RECYCLERS = [
    {
        "id": "REC-SYNTH-001",
        "name": "Maharashtra Green E-Solutions (Synthetic)",
        "district": "Mumbai",
        "lat": 19.0760,
        "lng": 72.8777,
        "cpcb_reg_no": "CPCB/SYNTH/EPR/2026/001",
        "body": AuthorizationBody.CPCB,
        "phone": "+91-98200-11111",
        "pickup_available": True,
        "pickup_radius_km": 35.0,
        "rating": 4.8,
        "rates": {
            "CRT": 14.5,
            "LCD panel": 48.0,
            "PCB (low grade)": 52.0,
            "PCB (mid grade)": 210.0,
            "PCB (high grade)": 620.0,
            "cables": 310.0,
            "batteries": 95.0,
            "motors/magnets": 85.0,
            "mixed plastics": 24.0,
        },
    },
    {
        "id": "REC-SYNTH-002",
        "name": "Mumbai Eco-Refinery Hub (Synthetic)",
        "district": "Mumbai",
        "lat": 19.1200,
        "lng": 72.9100,
        "cpcb_reg_no": "MPCB/SYNTH/EPR/2026/002",
        "body": AuthorizationBody.SPCB,
        "phone": "+91-98200-22222",
        "pickup_available": False,
        "pickup_radius_km": 0.0,
        "rating": 4.5,
        "rates": {
            "CRT": 12.0,
            "LCD panel": 45.0,
            "PCB (low grade)": 48.0,
            "PCB (mid grade)": 195.0,
            "PCB (high grade)": 590.0,
            "cables": 295.0,
            "batteries": 90.0,
            "motors/magnets": 80.0,
            "mixed plastics": 22.0,
        },
    },
    {
        "id": "REC-SYNTH-003",
        "name": "Thane Industrial E-Waste Aggregators (Synthetic)",
        "district": "Thane",
        "lat": 19.2183,
        "lng": 72.9781,
        "cpcb_reg_no": "MPCB/SYNTH/EPR/2026/003",
        "body": AuthorizationBody.SPCB,
        "phone": "+91-98200-33333",
        "pickup_available": True,
        "pickup_radius_km": 25.0,
        "rating": 4.7,
        "rates": {
            "CRT": 13.5,
            "LCD panel": 46.0,
            "PCB (low grade)": 50.0,
            "PCB (mid grade)": 205.0,
            "PCB (high grade)": 610.0,
            "cables": 305.0,
            "batteries": 92.0,
            "motors/magnets": 82.0,
            "mixed plastics": 23.0,
        },
    },
    {
        "id": "REC-SYNTH-004",
        "name": "Palghar Coastal Metal Recovery (Synthetic)",
        "district": "Palghar",
        "lat": 19.6967,
        "lng": 72.7699,
        "cpcb_reg_no": "MPCB/SYNTH/EPR/2026/004",
        "body": AuthorizationBody.SPCB,
        "phone": "+91-98200-44444",
        "pickup_available": True,
        "pickup_radius_km": 40.0,
        "rating": 4.6,
        "rates": {
            "CRT": 11.5,
            "LCD panel": 40.0,
            "PCB (low grade)": 45.0,
            "PCB (mid grade)": 185.0,
            "PCB (high grade)": 560.0,
            "cables": 285.0,
            "batteries": 88.0,
            "motors/magnets": 78.0,
            "mixed plastics": 20.0,
        },
    },
    {
        "id": "REC-SYNTH-005",
        "name": "Pune Circular Resources Pvt Ltd (Synthetic)",
        "district": "Pune",
        "lat": 18.5204,
        "lng": 73.8567,
        "cpcb_reg_no": "CPCB/SYNTH/EPR/2026/005",
        "body": AuthorizationBody.CPCB,
        "phone": "+91-98200-55555",
        "pickup_available": True,
        "pickup_radius_km": 30.0,
        "rating": 4.9,
        "rates": {
            "CRT": 14.0,
            "LCD panel": 47.0,
            "PCB (low grade)": 51.0,
            "PCB (mid grade)": 208.0,
            "PCB (high grade)": 615.0,
            "cables": 308.0,
            "batteries": 94.0,
            "motors/magnets": 84.0,
            "mixed plastics": 23.5,
        },
    },
    {
        "id": "REC-SYNTH-006",
        "name": "Pimpri High-Tech Dismantlers (Synthetic)",
        "district": "Pune",
        "lat": 18.6279,
        "lng": 73.8009,
        "cpcb_reg_no": "MPCB/SYNTH/EPR/2026/006",
        "body": AuthorizationBody.SPCB,
        "phone": "+91-98200-66666",
        "pickup_available": False,
        "pickup_radius_km": 0.0,
        "rating": 4.4,
        "rates": {
            "CRT": 12.5,
            "LCD panel": 44.0,
            "PCB (low grade)": 49.0,
            "PCB (mid grade)": 198.0,
            "PCB (high grade)": 585.0,
            "cables": 298.0,
            "batteries": 89.0,
            "motors/magnets": 79.0,
            "mixed plastics": 21.5,
        },
    },
    {
        "id": "REC-SYNTH-007",
        "name": "Nashik Valley Smelting Works (Synthetic)",
        "district": "Nashik",
        "lat": 19.9975,
        "lng": 73.7898,
        "cpcb_reg_no": "MPCB/SYNTH/EPR/2026/007",
        "body": AuthorizationBody.SPCB,
        "phone": "+91-98200-77777",
        "pickup_available": True,
        "pickup_radius_km": 30.0,
        "rating": 4.6,
        "rates": {
            "CRT": 13.0,
            "LCD panel": 43.0,
            "PCB (low grade)": 47.0,
            "PCB (mid grade)": 192.0,
            "PCB (high grade)": 575.0,
            "cables": 292.0,
            "batteries": 87.0,
            "motors/magnets": 77.0,
            "mixed plastics": 21.0,
        },
    },
    {
        "id": "REC-SYNTH-008",
        "name": "Nagpur Central Vidarbha Recyclers (Synthetic)",
        "district": "Nagpur",
        "lat": 21.1458,
        "lng": 79.0882,
        "cpcb_reg_no": "CPCB/SYNTH/EPR/2026/008",
        "body": AuthorizationBody.CPCB,
        "phone": "+91-98200-88888",
        "pickup_available": True,
        "pickup_radius_km": 50.0,
        "rating": 4.7,
        "rates": {
            "CRT": 13.2,
            "LCD panel": 44.5,
            "PCB (low grade)": 48.5,
            "PCB (mid grade)": 196.0,
            "PCB (high grade)": 590.0,
            "cables": 300.0,
            "batteries": 91.0,
            "motors/magnets": 81.0,
            "mixed plastics": 22.5,
        },
    },
]

# -----------------------------------------------------------------------------
# 2. Sample Collectors & Transactions Data
# -----------------------------------------------------------------------------

DEMO_COLLECTORS = [
    {
        "id": "KC-C-7821",
        "name": "Ramesh Scrap",
        "phone": "+91-98000-78210",
        "lang": PreferredLanguage.MR,
        "area": "Thane",
        "lat": 19.2183,
        "lng": 72.9781,
    },
    {
        "id": "KC-C-4512",
        "name": "Sunil E-Collect",
        "phone": "+91-98000-45120",
        "lang": PreferredLanguage.HI,
        "area": "Mumbai",
        "lat": 19.0760,
        "lng": 72.8777,
    },
    {
        "id": "KC-C-9034",
        "name": "Prakash Metal",
        "phone": "+91-98000-90340",
        "lang": PreferredLanguage.MR,
        "area": "Pune",
        "lat": 18.5204,
        "lng": 73.8567,
    },
]


async def seed_demo_data(db: AsyncSession) -> dict[str, int]:
    """Seed comprehensive demo data for demo mode and live testing."""
    now = datetime.now(UTC)
    seeded_counts: dict[str, int] = {}

    print("==========================================================")
    print("[DEMO SEED] Kabadiwala Connect: Seeding Demo Database")
    print("==========================================================")

    # 1. Seed Safety Content
    print("1. Seeding 8 Multilingual Safety Cards...")
    safety_count = await SafetyService.seed_safety_content(db)
    seeded_counts["safety_topics"] = safety_count
    print(f"   -> Seeded {safety_count} safety topics.")

    # 2. Seed Recyclers
    print("2. Seeding 8 Authorized Recyclers across 6 Districts...")
    recycler_count = 0
    for r_data in DEMO_RECYCLERS:
        existing = await db.get(Recycler, r_data["id"])
        pt = WKTElement(f"POINT({r_data['lng']} {r_data['lat']})", srid=4326)
        if not existing:
            rec = Recycler(
                id=r_data["id"],
                name=r_data["name"],
                facility_location=pt,
                materials_accepted=list(r_data["rates"].keys()),
                authorization_number=r_data["cpcb_reg_no"],
                authorization_body=r_data["body"],
                authorization_status=AuthorizationStatus.VERIFIED,
                authorization_valid_till=date(2028, 12, 31),
                phone=r_data["phone"],
                offered_rates=r_data["rates"],
                pickup_available=r_data["pickup_available"],
                pickup_radius_km=r_data["pickup_radius_km"],
                service_area={"districts": [r_data["district"]]},
                rating=r_data["rating"],
            )
            db.add(rec)
            recycler_count += 1
        else:
            existing.name = r_data["name"]
            existing.facility_location = pt
            existing.offered_rates = r_data["rates"]
            existing.pickup_available = r_data["pickup_available"]
            existing.rating = r_data["rating"]
            recycler_count += 1
    await db.commit()
    seeded_counts["recyclers"] = recycler_count
    print(f"   -> Seeded/verified {recycler_count} authorized recyclers.")

    # 3. Seed 60 Days Price History across all 7 categories in all 6 districts
    print("3. Seeding 60-day Price History across Maharashtra districts...")
    price_count = 0
    rng = random.Random(42)

    categories = list(CATEGORY_SPECS.keys())
    districts = list(MAHARASHTRA_DISTRICTS.keys())

    for day_offset in range(60, -1, -2):  # Every 2 days
        point_date = now - timedelta(days=day_offset)
        for cat in categories:
            spec = CATEGORY_SPECS[cat]
            for dist in districts:
                dist_info = MAHARASHTRA_DISTRICTS[dist]
                lat = dist_info["lat"] + rng.uniform(-0.02, 0.02)
                lng = dist_info["lng"] + rng.uniform(-0.02, 0.02)
                base_p = spec["base_price_kg"] * dist_info["price_modifier"]
                price_val = round(base_p * (1.0 + rng.uniform(-0.08, 0.08)), 2)

                price_rec = Price(
                    id=uuid.uuid4(),
                    category=cat,
                    sub_category=spec["sub_categories"][0],
                    district=dist,
                    city=dist_info["city"],
                    location=WKTElement(f"POINT({lng} {lat})", srid=4326),
                    recorded_at=point_date,
                    buying_price=price_val,
                    selling_quoted_price=round(price_val * 1.08, 2),
                    unit=PriceUnit.KG,
                    market_min=round(spec["market_min_kg"] * dist_info["price_modifier"], 2),
                    market_max=round(spec["market_max_kg"] * dist_info["price_modifier"], 2),
                    recycler_id=DEMO_RECYCLERS[rng.randint(0, len(DEMO_RECYCLERS) - 1)]["id"],
                    source=PriceSource.SYNTHETIC,
                )
                db.add(price_rec)
                price_count += 1

    await db.commit()
    seeded_counts["price_points"] = price_count
    print(f"   -> Seeded {price_count} historical price observation points.")

    # 4. Seed 3 Collectors with Transaction History & Financial Ledger
    print("4. Seeding 3 Sample Collectors with Multi-State Transactions & Ledgers...")
    tx_count = 0
    ledger_count = 0

    tx_specs = [
        # Collector 1: Ramesh Scrap (Thane) - 6 transactions (4 completed, 1 pending, 1 disputed)
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00101",
            "cat": "PCB (mid grade)",
            "weight": 14.5,
            "rate": 205.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 2,  # Thane Recycler
            "days_ago": 18,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00102",
            "cat": "cables",
            "weight": 22.0,
            "rate": 305.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 2,
            "days_ago": 12,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00103",
            "cat": "batteries",
            "weight": 18.0,
            "rate": 92.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 2,
            "days_ago": 7,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00104",
            "cat": "CRT",
            "weight": 28.0,
            "rate": 13.5,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 2,
            "days_ago": 3,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00105",
            "cat": "LCD panel",
            "weight": 15.0,
            "rate": 46.0,
            "status": TransactionStatus.HANDOVER_PENDING,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": 2,
            "days_ago": 1,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 0,
            "lot_id": "KC-MH-2609-00106",
            "cat": "PCB (high grade)",
            "weight": 8.0,
            "rate": 610.0,
            "status": TransactionStatus.DISPUTED,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": 2,
            "days_ago": 0,
            "anom": False,
            "anom_reason": "Weight mismatch > 10% (Collector: 8.0kg vs Recycler: 6.2kg)",
        },
        # Collector 2: Sunil E-Collect (Mumbai) - 5 transactions (3 completed, 1 pending, 1 cancelled)
        {
            "collector_idx": 1,
            "lot_id": "KC-MH-2609-00201",
            "cat": "cables",
            "weight": 35.0,
            "rate": 310.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 0,  # Mumbai Recycler
            "days_ago": 14,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 1,
            "lot_id": "KC-MH-2609-00202",
            "cat": "motors/magnets",
            "weight": 40.0,
            "rate": 85.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 0,
            "days_ago": 9,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 1,
            "lot_id": "KC-MH-2609-00203",
            "cat": "PCB (low grade)",
            "weight": 50.0,
            "rate": 52.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 0,
            "days_ago": 4,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 1,
            "lot_id": "KC-MH-2609-00204",
            "cat": "LCD panel",
            "weight": 18.0,
            "rate": 48.0,
            "status": TransactionStatus.HANDOVER_PENDING,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": 0,
            "days_ago": 1,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 1,
            "lot_id": "KC-MH-2609-00205",
            "cat": "mixed plastics",
            "weight": 30.0,
            "rate": 24.0,
            "status": TransactionStatus.CANCELLED,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": None,
            "days_ago": 2,
            "anom": False,
            "anom_reason": None,
        },
        # Collector 3: Prakash Metal (Pune) - 5 transactions (3 completed, 1 pending, 1 disputed)
        {
            "collector_idx": 2,
            "lot_id": "KC-MH-2609-00301",
            "cat": "PCB (high grade)",
            "weight": 12.0,
            "rate": 615.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 4,  # Pune Recycler
            "days_ago": 16,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 2,
            "lot_id": "KC-MH-2609-00302",
            "cat": "batteries",
            "weight": 25.0,
            "rate": 94.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 4,
            "days_ago": 10,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 2,
            "lot_id": "KC-MH-2609-00303",
            "cat": "CRT",
            "weight": 32.0,
            "rate": 14.0,
            "status": TransactionStatus.HANDED_OVER,
            "pay_status": PaymentStatus.CASH_RECEIVED,
            "rec_idx": 4,
            "days_ago": 5,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 2,
            "lot_id": "KC-MH-2609-00304",
            "cat": "cables",
            "weight": 20.0,
            "rate": 308.0,
            "status": TransactionStatus.HANDOVER_PENDING,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": 4,
            "days_ago": 1,
            "anom": False,
            "anom_reason": None,
        },
        {
            "collector_idx": 2,
            "lot_id": "KC-MH-2609-00305",
            "cat": "motors/magnets",
            "weight": 55.0,
            "rate": 84.0,
            "status": TransactionStatus.DISPUTED,
            "pay_status": PaymentStatus.PENDING,
            "rec_idx": 4,
            "days_ago": 0,
            "anom": False,
            "anom_reason": "Material contaminated with soil/ferrous residue",
        },
    ]

    for c_data in DEMO_COLLECTORS:
        existing_c = await db.get(Collector, c_data["id"])
        if not existing_c:
            col = Collector(
                collector_id=c_data["id"],
                phone=c_data["phone"],
                pin_hash="$2b$12$e8p1mE.DEMO.HASH.SAMPLEPIN",
                preferred_language=c_data["lang"],
                operating_area=c_data["area"],
            )
            db.add(col)
    await db.commit()

    # Track running balances per collector
    running_balances = {c["id"]: 0.0 for c in DEMO_COLLECTORS}

    for item in tx_specs:
        c_info = DEMO_COLLECTORS[item["collector_idx"]]
        c_id = c_info["id"]
        tx_time = now - timedelta(days=item["days_ago"])
        rec_id = DEMO_RECYCLERS[item["rec_idx"]]["id"] if item["rec_idx"] is not None else None
        total_val = round(item["weight"] * item["rate"], 2)

        existing_tx = await db.get(Transaction, item["lot_id"])
        pt = WKTElement(f"POINT({c_info['lng']} {c_info['lat']})", srid=4326)

        if not existing_tx:
            tx = Transaction(
                lot_id=item["lot_id"],
                collector_id=c_id,
                category=item["cat"],
                weight_kg=item["weight"],
                quoted_price=item["rate"],
                final_price=total_val if item["status"] == TransactionStatus.HANDED_OVER else None,
                recycler_id=rec_id,
                collection_location=pt,
                handover_location=pt if item["status"] == TransactionStatus.HANDED_OVER else None,
                created_at=tx_time,
                handover_at=tx_time if item["status"] == TransactionStatus.HANDED_OVER else None,
                payment_status=item["pay_status"],
                transaction_status=item["status"],
                anomaly_flag=item["anom"],
                anomaly_reason=item["anom_reason"],
            )
            db.add(tx)
            tx_count += 1

            # If completed handover, create Traceability record and Ledger credit
            if item["status"] == TransactionStatus.HANDED_OVER:
                trace = Traceability(
                    id=uuid.uuid4(),
                    lot_id=item["lot_id"],
                    photo_hashes=["sha256_mock_photo_1", "sha256_mock_photo_2"],
                    weight_kg=item["weight"],
                    timestamp=tx_time,
                    gps_lat=c_info["lat"],
                    gps_lng=c_info["lng"],
                    location=pt,
                    handover_ref_no=f"REF{rng.randint(1000, 9999)}",
                    qr_payload=f'{{"lot_id":"{item["lot_id"]}","weight":{item["weight"]}}}',
                    recycler_confirmation=True,
                    confirmed_at=tx_time,
                    confirmed_by=rec_id,
                    record_hash=f"hash_{uuid.uuid4().hex[:16]}",
                    prev_hash=f"prev_{uuid.uuid4().hex[:16]}",
                )
                db.add(trace)

                running_balances[c_id] += total_val
                ledger = LedgerEntry(
                    id=uuid.uuid4(),
                    collector_id=c_id,
                    lot_id=item["lot_id"],
                    entry_type=LedgerEntryType.CREDIT,
                    amount=total_val,
                    payment_mode=PaymentStatus.CASH_RECEIVED,
                    description=f"{item['cat']} ({item['weight']} kg @ ₹{item['rate']}/kg)",
                    balance_after=running_balances[c_id],
                    recorded_at=tx_time,
                )
                db.add(ledger)
                ledger_count += 1

    await db.commit()
    seeded_counts["collector_transactions"] = tx_count
    seeded_counts["ledger_entries"] = ledger_count
    print(f"   -> Seeded {tx_count} transactions across 3 collectors ({ledger_count} ledger entries).")

    # 5. Seed 3 Flagged Anomalous Transactions (Price Outlier, Weight Implausible, Rapid Burst)
    print("5. Seeding 3 Flagged Anomalous Transactions...")
    anom_count = 0
    anom_specs = [
        {
            "lot_id": "KC-MH-2609-ANOM1",
            "collector_id": "KC-C-7821",
            "cat": "PCB (mid grade)",
            "weight": 10.0,
            "rate": 1850.0,  # 10x normal rate
            "reason": "price_outlier: Quoted rate ₹1850.0/kg exceeds 2.5x IQR upper threshold (₹260.0/kg)",
            "lat": 19.2183,
            "lng": 72.9781,
        },
        {
            "lot_id": "KC-MH-2609-ANOM2",
            "collector_id": "KC-C-4512",
            "cat": "CRT",
            "weight": 4500.0,  # 4.5 ton monitor
            "rate": 12.0,
            "reason": "weight_implausible: Single unit weight 4500.0 kg exceeds sanity limit (50.0 kg) for CRT",
            "lat": 19.0760,
            "lng": 72.8777,
        },
        {
            "lot_id": "KC-MH-2609-ANOM3",
            "collector_id": "KC-C-9034",
            "cat": "batteries",
            "weight": 15.0,
            "rate": 90.0,
            "reason": "rapid_burst: 5 identical lots submitted within 180 seconds at same GPS coordinate",
            "lat": 18.5204,
            "lng": 73.8567,
        },
    ]

    for anom in anom_specs:
        existing = await db.get(Transaction, anom["lot_id"])
        pt = WKTElement(f"POINT({anom['lng']} {anom['lat']})", srid=4326)
        if not existing:
            tx = Transaction(
                lot_id=anom["lot_id"],
                collector_id=anom["collector_id"],
                category=anom["cat"],
                weight_kg=anom["weight"],
                quoted_price=anom["rate"],
                final_price=None,
                recycler_id=None,
                collection_location=pt,
                created_at=now - timedelta(hours=2),
                payment_status=PaymentStatus.PENDING,
                transaction_status=TransactionStatus.LISTED,
                anomaly_flag=True,
                anomaly_reason=anom["reason"],
            )
            db.add(tx)
            anom_count += 1

    await db.commit()
    seeded_counts["anomalies"] = anom_count
    print(f"   -> Seeded {anom_count} flagged anomalous transactions.")

    print("==========================================================")
    print("[SUCCESS] Demo Seeding Successfully Completed!")
    print(f"   Recyclers: {seeded_counts['recyclers']}")
    print(f"   Price Points: {seeded_counts['price_points']}")
    print(f"   Transactions: {seeded_counts['collector_transactions']}")
    print(f"   Ledger Entries: {seeded_counts['ledger_entries']}")
    print(f"   Anomalies: {seeded_counts['anomalies']}")
    print(f"   Safety Topics: {seeded_counts['safety_topics']}")
def export_demo_fixtures(output_path: str = "data/synthetic/demo_seed_dataset.json") -> dict[str, Any]:
    """Export complete demo dataset to standalone JSON file for offline demo mode."""
    import json
    from pathlib import Path

    repo_root = Path(__file__).resolve().parent.parent.parent.parent
    target_file = repo_root / output_path
    target_file.parent.mkdir(parents=True, exist_ok=True)

    demo_payload = {
        "metadata": {
            "title": "Kabadiwala Connect Demo Fixtures",
            "source": "synthetic",
            "generated_at": datetime.now(UTC).isoformat(),
            "districts": list(MAHARASHTRA_DISTRICTS.keys()),
        },
        "recyclers": DEMO_RECYCLERS,
        "collectors": [
            {
                "id": c["id"],
                "name": c["name"],
                "phone": c["phone"],
                "language": c["lang"].value,
                "operating_area": c["area"],
                "latitude": c["lat"],
                "longitude": c["lng"],
            }
            for c in DEMO_COLLECTORS
        ],
        "anomalies": [
            {
                "lot_id": "KC-MH-2609-ANOM1",
                "collector_id": "KC-C-7821",
                "category": "PCB (mid grade)",
                "weight_kg": 10.0,
                "quoted_price": 1850.0,
                "reason": "price_outlier: Quoted rate ₹1850.0/kg exceeds 2.5x IQR upper threshold (₹260.0/kg)",
            },
            {
                "lot_id": "KC-MH-2609-ANOM2",
                "collector_id": "KC-C-4512",
                "category": "CRT",
                "weight_kg": 4500.0,
                "quoted_price": 12.0,
                "reason": "weight_implausible: Single unit weight 4500.0 kg exceeds sanity limit (50.0 kg) for CRT",
            },
            {
                "lot_id": "KC-MH-2609-ANOM3",
                "collector_id": "KC-C-9034",
                "category": "batteries",
                "weight_kg": 15.0,
                "quoted_price": 90.0,
                "reason": "rapid_burst: 5 identical lots submitted within 180 seconds at same GPS coordinate",
            },
        ],
    }

    with open(target_file, "w", encoding="utf-8") as f:
        json.dump(demo_payload, f, indent=2)

    print(f"[DEMO EXPORT] Exported demo fixtures to {target_file}")
    return demo_payload


async def _run_seed() -> None:
    export_demo_fixtures()
    try:
        async with AsyncSessionLocal() as session:
            await seed_demo_data(session)
    except Exception as exc:
        print("\n[NOTE] PostgreSQL database is not reachable at DATABASE_URL.")
        print(f"       Details: {exc}")
        print("       Exported demo fixtures to data/synthetic/demo_seed_dataset.json")
        print("       Start docker containers with 'docker compose up -d' for live DB ingestion.\n")


def main() -> None:
    """Synchronous entrypoint for CLI & Makefile execution."""
    asyncio.run(_run_seed())


if __name__ == "__main__":
    main()

