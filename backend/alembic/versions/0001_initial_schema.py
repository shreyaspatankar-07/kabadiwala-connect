"""Initial PostgreSQL and PostGIS schema migration for Kabadiwala Connect.

Revision ID: 0001_initial_schema
Revises: None
Create Date: 2026-09-25 00:20:00.000000

"""

from collections.abc import Sequence

import geoalchemy2
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0001_initial_schema"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 0. Ensure PostGIS extension is available
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    # 1. collectors table
    op.create_table(
        "collectors",
        sa.Column("collector_id", sa.String(length=32), nullable=False),
        sa.Column(
            "preferred_language",
            sa.Enum("mr", "hi", "en", name="preferredlanguage"),
            nullable=False,
            server_default="mr",
        ),
        sa.Column("operating_area", sa.String(length=100), nullable=False, comment="District only"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("collector_id"),
    )
    op.create_index(
        op.f("ix_collectors_collector_id"), "collectors", ["collector_id"], unique=False
    )

    # 2. materials table
    op.create_table(
        "materials",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column("sub_category", sa.String(length=50), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("image_ref", sa.String(length=255), nullable=True),
        sa.Column("approx_weight_kg", sa.Float(), nullable=False),
        sa.Column(
            "condition",
            sa.Enum("working", "broken", "damaged", "burnt", name="materialcondition"),
            nullable=False,
        ),
        sa.Column(
            "source_type",
            sa.Enum("household", "office", "shop", "repair_unit", "other", name="sourcetype"),
            nullable=False,
        ),
        sa.Column("estimated_value", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_materials_category"), "materials", ["category"], unique=False)
    op.create_index(op.f("ix_materials_sub_category"), "materials", ["sub_category"], unique=False)

    # 3. recyclers table
    op.create_table(
        "recyclers",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column(
            "facility_location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=False,
        ),
        sa.Column("materials_accepted", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("authorization_number", sa.String(length=100), nullable=False),
        sa.Column(
            "authorization_body",
            sa.Enum("CPCB", "SPCB", "OTHER", name="authorizationbody"),
            nullable=False,
        ),
        sa.Column(
            "authorization_status",
            sa.Enum("verified", "pending", "expired", "suspended", name="authorizationstatus"),
            nullable=False,
            server_default="pending",
        ),
        sa.Column("authorization_valid_till", sa.Date(), nullable=False),
        sa.Column("phone", sa.String(length=20), nullable=False),
        sa.Column("offered_rates", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column(
            "pickup_available", sa.Boolean(), nullable=False, server_default=sa.text("false")
        ),
        sa.Column("pickup_radius_km", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("service_area", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("rating", sa.Numeric(precision=3, scale=2), nullable=False, server_default="0.0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("rating >= 0.0 AND rating <= 5.0", name="chk_recycler_rating_range"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("authorization_number"),
    )
    op.create_index(op.f("ix_recyclers_id"), "recyclers", ["id"], unique=False)
    op.create_index(
        "idx_recyclers_facility_location",
        "recyclers",
        ["facility_location"],
        unique=False,
        postgresql_using="gist",
    )

    # 4. prices table
    op.create_table(
        "prices",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column("sub_category", sa.String(length=50), nullable=True),
        sa.Column("district", sa.String(length=100), nullable=False),
        sa.Column("city", sa.String(length=100), nullable=True),
        sa.Column(
            "location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=False,
        ),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("buying_price", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("selling_quoted_price", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column(
            "unit", sa.Enum("kg", "piece", name="priceunit"), nullable=False, server_default="kg"
        ),
        sa.Column("market_min", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("market_max", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("recycler_id", sa.String(length=36), nullable=True),
        sa.Column(
            "source",
            sa.Enum("recycler_quote", "field_survey", "synthetic", name="pricesource"),
            nullable=False,
            server_default="synthetic",
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("market_min <= market_max", name="chk_price_min_max"),
        sa.CheckConstraint("buying_price >= 0", name="chk_price_buying_positive"),
        sa.ForeignKeyConstraint(["recycler_id"], ["recyclers.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_prices_category"), "prices", ["category"], unique=False)
    op.create_index(op.f("ix_prices_sub_category"), "prices", ["sub_category"], unique=False)
    op.create_index(op.f("ix_prices_district"), "prices", ["district"], unique=False)
    op.create_index(op.f("ix_prices_recorded_at"), "prices", ["recorded_at"], unique=False)
    op.create_index(
        "idx_prices_location", "prices", ["location"], unique=False, postgresql_using="gist"
    )

    # 5. transactions table
    op.create_table(
        "transactions",
        sa.Column("lot_id", sa.String(length=40), nullable=False, comment="e.g. KC-MH-2609-00123"),
        sa.Column("collector_id", sa.String(length=32), nullable=False),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column("weight_kg", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("quoted_price", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("final_price", sa.Numeric(precision=12, scale=2), nullable=True),
        sa.Column("recycler_id", sa.String(length=36), nullable=True),
        sa.Column(
            "collection_location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=False,
        ),
        sa.Column(
            "handover_location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=True,
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("handover_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "payment_status",
            sa.Enum("cash_received", "pending", "digital_paid", name="paymentstatus"),
            nullable=False,
            server_default="pending",
        ),
        sa.Column(
            "transaction_status",
            sa.Enum(
                "draft",
                "listed",
                "matched",
                "handover_pending",
                "handed_over",
                "confirmed",
                "disputed",
                "cancelled",
                name="transactionstatus",
            ),
            nullable=False,
            server_default="draft",
        ),
        sa.Column("anomaly_flag", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("anomaly_reason", sa.String(length=255), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("weight_kg > 0", name="chk_transaction_weight_positive"),
        sa.CheckConstraint("quoted_price >= 0", name="chk_transaction_quoted_positive"),
        sa.ForeignKeyConstraint(["collector_id"], ["collectors.collector_id"]),
        sa.ForeignKeyConstraint(["recycler_id"], ["recyclers.id"]),
        sa.PrimaryKeyConstraint("lot_id"),
    )
    op.create_index(op.f("ix_transactions_lot_id"), "transactions", ["lot_id"], unique=False)
    op.create_index(
        op.f("ix_transactions_collector_id"), "transactions", ["collector_id"], unique=False
    )
    op.create_index(op.f("ix_transactions_category"), "transactions", ["category"], unique=False)
    op.create_index(
        op.f("ix_transactions_recycler_id"), "transactions", ["recycler_id"], unique=False
    )
    op.create_index(
        op.f("ix_transactions_created_at"), "transactions", ["created_at"], unique=False
    )
    op.create_index(
        op.f("ix_transactions_payment_status"), "transactions", ["payment_status"], unique=False
    )
    op.create_index(
        op.f("ix_transactions_transaction_status"),
        "transactions",
        ["transaction_status"],
        unique=False,
    )
    op.create_index(
        op.f("ix_transactions_anomaly_flag"), "transactions", ["anomaly_flag"], unique=False
    )
    op.create_index(
        "idx_transactions_collection_location",
        "transactions",
        ["collection_location"],
        unique=False,
        postgresql_using="gist",
    )
    op.create_index(
        "idx_transactions_handover_location",
        "transactions",
        ["handover_location"],
        unique=False,
        postgresql_using="gist",
    )

    # 6. traceability table
    op.create_table(
        "traceability",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("lot_id", sa.String(length=40), nullable=False),
        sa.Column("photo_hashes", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("weight_kg", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("timestamp", sa.DateTime(timezone=True), nullable=False),
        sa.Column("gps_lat", sa.Float(), nullable=False),
        sa.Column("gps_lng", sa.Float(), nullable=False),
        sa.Column(
            "location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=False,
        ),
        sa.Column("handover_ref_no", sa.String(length=64), nullable=False),
        sa.Column("qr_payload", sa.Text(), nullable=False),
        sa.Column(
            "recycler_confirmation", sa.Boolean(), nullable=False, server_default=sa.text("false")
        ),
        sa.Column("confirmed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("confirmed_by", sa.String(length=100), nullable=True),
        sa.Column(
            "downstream_status",
            sa.Enum(
                "received", "dismantled", "processed", "certificate_issued", name="downstreamstatus"
            ),
            nullable=False,
            server_default="received",
        ),
        sa.Column("record_hash", sa.String(length=64), nullable=False, comment="SHA-256"),
        sa.Column(
            "prev_hash", sa.String(length=64), nullable=False, comment="SHA-256 hash chained"
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["lot_id"], ["transactions.lot_id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("handover_ref_no"),
    )
    op.create_index(op.f("ix_traceability_lot_id"), "traceability", ["lot_id"], unique=False)
    op.create_index(op.f("ix_traceability_timestamp"), "traceability", ["timestamp"], unique=False)
    op.create_index(
        op.f("ix_traceability_record_hash"), "traceability", ["record_hash"], unique=False
    )
    op.create_index(
        "idx_traceability_location",
        "traceability",
        ["location"],
        unique=False,
        postgresql_using="gist",
    )

    # 7. ledger_entries table
    op.create_table(
        "ledger_entries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("collector_id", sa.String(length=32), nullable=False),
        sa.Column("lot_id", sa.String(length=40), nullable=True),
        sa.Column("entry_type", sa.Enum("credit", "debit", name="ledgerentrytype"), nullable=False),
        sa.Column("amount", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column(
            "payment_mode",
            sa.Enum("cash_received", "pending", "digital_paid", name="paymentstatus"),
            nullable=False,
            server_default="cash_received",
        ),
        sa.Column("description", sa.String(length=255), nullable=False),
        sa.Column("balance_after", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("amount >= 0", name="chk_ledger_amount_positive"),
        sa.ForeignKeyConstraint(["collector_id"], ["collectors.collector_id"]),
        sa.ForeignKeyConstraint(["lot_id"], ["transactions.lot_id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_ledger_entries_collector_id"), "ledger_entries", ["collector_id"], unique=False
    )
    op.create_index(op.f("ix_ledger_entries_lot_id"), "ledger_entries", ["lot_id"], unique=False)
    op.create_index(
        op.f("ix_ledger_entries_recorded_at"), "ledger_entries", ["recorded_at"], unique=False
    )

    # 8. safety_content table
    op.create_table(
        "safety_content",
        sa.Column("id", sa.String(length=32), nullable=False, comment="e.g. SAFE-BATT-01"),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column(
            "hazard_level",
            sa.Enum("info", "warning", "danger", name="hazardlevel"),
            nullable=False,
            server_default="info",
        ),
        sa.Column("pictogram_url", sa.String(length=255), nullable=False),
        sa.Column("audio_prompt_urls", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("title_vernacular", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column(
            "instructions_vernacular", postgresql.JSONB(astext_type=sa.Text()), nullable=False
        ),
        sa.Column("dos", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("donts", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_safety_content_category"), "safety_content", ["category"], unique=False
    )

    # 9. sync_queue table
    op.create_table(
        "sync_queue",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("collector_id", sa.String(length=32), nullable=False),
        sa.Column("client_tx_id", sa.String(length=64), nullable=False, comment="Idempotency key"),
        sa.Column("action", sa.String(length=50), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column(
            "status",
            sa.Enum(
                "pending",
                "processing",
                "completed",
                "failed",
                "dead_letter",
                name="syncactionstatus",
            ),
            nullable=False,
            server_default="pending",
        ),
        sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_error", sa.Text(), nullable=True),
        sa.Column("client_timestamp", sa.DateTime(timezone=True), nullable=False),
        sa.Column("processed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("client_tx_id"),
    )
    op.create_index(
        op.f("ix_sync_queue_collector_id"), "sync_queue", ["collector_id"], unique=False
    )
    op.create_index(
        op.f("ix_sync_queue_client_tx_id"), "sync_queue", ["client_tx_id"], unique=False
    )
    op.create_index(op.f("ix_sync_queue_action"), "sync_queue", ["action"], unique=False)
    op.create_index(op.f("ix_sync_queue_status"), "sync_queue", ["status"], unique=False)

    # 10. ml_training_samples table
    op.create_table(
        "ml_training_samples",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("image_path", sa.String(length=255), nullable=False),
        sa.Column("label", sa.String(length=50), nullable=False),
        sa.Column("weight_kg", sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column("price", sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column(
            "location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=True,
        ),
        sa.Column(
            "source",
            sa.Enum("synthetic", "field", "scraped_public", name="dataprovenancesource"),
            nullable=False,
            server_default="synthetic",
        ),
        sa.Column("quality_score", sa.Float(), nullable=False, server_default="1.0"),
        sa.Column("verified", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("verified_by", sa.String(length=100), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_ml_training_samples_label"), "ml_training_samples", ["label"], unique=False
    )
    op.create_index(
        op.f("ix_ml_training_samples_source"), "ml_training_samples", ["source"], unique=False
    )
    op.create_index(
        op.f("ix_ml_training_samples_verified"), "ml_training_samples", ["verified"], unique=False
    )
    op.create_index(
        "idx_ml_samples_location",
        "ml_training_samples",
        ["location"],
        unique=False,
        postgresql_using="gist",
    )


def downgrade() -> None:
    op.drop_table("ml_training_samples")
    op.drop_table("sync_queue")
    op.drop_table("safety_content")
    op.drop_table("ledger_entries")
    op.drop_table("traceability")
    op.drop_table("transactions")
    op.drop_table("prices")
    op.drop_table("recyclers")
    op.drop_table("materials")
    op.drop_table("collectors")

    op.execute("DROP TYPE IF EXISTS dataprovenancesource CASCADE;")
    op.execute("DROP TYPE IF EXISTS syncactionstatus CASCADE;")
    op.execute("DROP TYPE IF EXISTS hazardlevel CASCADE;")
    op.execute("DROP TYPE IF EXISTS ledgerentrytype CASCADE;")
    op.execute("DROP TYPE IF EXISTS downstreamstatus CASCADE;")
    op.execute("DROP TYPE IF EXISTS transactionstatus CASCADE;")
    op.execute("DROP TYPE IF EXISTS paymentstatus CASCADE;")
    op.execute("DROP TYPE IF EXISTS authorizationstatus CASCADE;")
    op.execute("DROP TYPE IF EXISTS authorizationbody CASCADE;")
    op.execute("DROP TYPE IF EXISTS pricesource CASCADE;")
    op.execute("DROP TYPE IF EXISTS priceunit CASCADE;")
    op.execute("DROP TYPE IF EXISTS sourcetype CASCADE;")
    op.execute("DROP TYPE IF EXISTS materialcondition CASCADE;")
    op.execute("DROP TYPE IF EXISTS preferredlanguage CASCADE;")
