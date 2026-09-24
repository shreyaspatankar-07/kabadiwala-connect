"""Tests for SQLAlchemy ORM models, tables, indexes, and constraints."""

from app.models.schema import (
    Base,
    HazardLevel,
    MaterialCondition,
    PaymentStatus,
    PreferredLanguage,
    PriceSource,
    PriceUnit,
    SourceType,
    TransactionStatus,
)


def test_registered_tables():
    """Verify all 10 core tables are mapped in DeclarativeBase metadata."""
    expected_tables = {
        "collectors",
        "materials",
        "recyclers",
        "prices",
        "transactions",
        "traceability",
        "ledger_entries",
        "safety_content",
        "sync_queue",
        "ml_training_samples",
    }
    actual_tables = set(Base.metadata.tables.keys())
    assert expected_tables.issubset(actual_tables), (
        f"Missing tables: {expected_tables - actual_tables}"
    )


def test_table_columns_and_pk():
    """Verify primary keys and essential columns across models."""
    tables = Base.metadata.tables

    # Collectors table
    assert "collector_id" in tables["collectors"].c
    assert tables["collectors"].c["collector_id"].primary_key

    # Materials table
    assert "category" in tables["materials"].c
    assert "condition" in tables["materials"].c
    assert "source_type" in tables["materials"].c

    # Recyclers table
    assert "facility_location" in tables["recyclers"].c
    assert "authorization_number" in tables["recyclers"].c

    # Prices table
    assert "location" in tables["prices"].c
    assert "market_min" in tables["prices"].c
    assert "market_max" in tables["prices"].c

    # Transactions table
    assert "lot_id" in tables["transactions"].c
    assert tables["transactions"].c["lot_id"].primary_key
    assert "collection_location" in tables["transactions"].c
    assert "handover_location" in tables["transactions"].c

    # Traceability table
    assert "record_hash" in tables["traceability"].c
    assert "prev_hash" in tables["traceability"].c
    assert "qr_payload" in tables["traceability"].c

    # Ledger entries table
    assert "entry_type" in tables["ledger_entries"].c
    assert "balance_after" in tables["ledger_entries"].c

    # Safety content table
    assert "audio_prompt_urls" in tables["safety_content"].c
    assert "pictogram_url" in tables["safety_content"].c

    # Sync queue table
    assert "client_tx_id" in tables["sync_queue"].c
    assert "action" in tables["sync_queue"].c

    # ML training samples
    assert "image_path" in tables["ml_training_samples"].c
    assert "quality_score" in tables["ml_training_samples"].c


def test_foreign_key_relationships():
    """Verify relational integrity and foreign key definitions."""
    tables = Base.metadata.tables

    # prices -> recyclers
    prices_fks = {fk.target_fullname for fk in tables["prices"].foreign_keys}
    assert "recyclers.id" in prices_fks

    # transactions -> collectors and recyclers
    tx_fks = {fk.target_fullname for fk in tables["transactions"].foreign_keys}
    assert "collectors.collector_id" in tx_fks
    assert "recyclers.id" in tx_fks

    # traceability -> transactions
    trace_fks = {fk.target_fullname for fk in tables["traceability"].foreign_keys}
    assert "transactions.lot_id" in trace_fks

    # ledger_entries -> collectors and transactions
    ledger_fks = {fk.target_fullname for fk in tables["ledger_entries"].foreign_keys}
    assert "collectors.collector_id" in ledger_fks
    assert "transactions.lot_id" in ledger_fks


def test_enum_members():
    """Verify all domain enums have required values."""
    assert MaterialCondition.WORKING.value == "working"
    assert SourceType.HOUSEHOLD.value == "household"
    assert PriceUnit.KG.value == "kg"
    assert PriceSource.SYNTHETIC.value == "synthetic"
    assert PaymentStatus.CASH_RECEIVED.value == "cash_received"
    assert TransactionStatus.HANDOVER_PENDING.value == "handover_pending"
    assert PreferredLanguage.MR.value == "mr"
    assert HazardLevel.DANGER.value == "danger"
