"""SQLAlchemy Base and Model Declarations for Kabadiwala Connect."""

import enum
import uuid
from datetime import UTC, date, datetime
from typing import Any

from geoalchemy2 import Geometry
from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.types import TypeDecorator


# Fallback JSON type for cross-dialect compatibility (PostgreSQL JSONB / SQLite JSON)
class JSONCompatible(TypeDecorator):
    impl = Text
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == "postgresql":
            return dialect.type_descriptor(JSONB())
        return dialect.type_descriptor(Text())

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        if dialect.name == "postgresql":
            return value
        import json

        return json.dumps(value)

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        if dialect.name == "postgresql":
            return value
        import json

        if isinstance(value, (dict, list)):
            return value
        return json.loads(value)


class Base(DeclarativeBase):
    """Base class for all ORM models."""

    pass


# -----------------------------------------------------------------------------
# Enums
# -----------------------------------------------------------------------------


class MaterialCondition(enum.StrEnum):
    WORKING = "working"
    BROKEN = "broken"
    DAMAGED = "damaged"
    BURNT = "burnt"


class SourceType(enum.StrEnum):
    HOUSEHOLD = "household"
    OFFICE = "office"
    SHOP = "shop"
    REPAIR_UNIT = "repair_unit"
    OTHER = "other"


class PriceUnit(enum.StrEnum):
    KG = "kg"
    PIECE = "piece"


class PriceSource(enum.StrEnum):
    RECYCLER_QUOTE = "recycler_quote"
    FIELD_SURVEY = "field_survey"
    SYNTHETIC = "synthetic"
    COLLECTOR_REPORT = "collector_report"


class AuthorizationBody(enum.StrEnum):
    CPCB = "CPCB"
    SPCB = "SPCB"
    OTHER = "OTHER"


class AuthorizationStatus(enum.StrEnum):
    VERIFIED = "verified"
    PENDING = "pending"
    EXPIRED = "expired"
    SUSPENDED = "suspended"


class PaymentStatus(enum.StrEnum):
    CASH_RECEIVED = "cash_received"
    PENDING = "pending"
    DIGITAL_PAID = "digital_paid"


class TransactionStatus(enum.StrEnum):
    DRAFT = "draft"
    LISTED = "listed"
    MATCHED = "matched"
    HANDOVER_PENDING = "handover_pending"
    HANDED_OVER = "handed_over"
    CONFIRMED = "confirmed"
    DISPUTED = "disputed"
    CANCELLED = "cancelled"


class DownstreamStatus(enum.StrEnum):
    RECEIVED = "received"
    DISMANTLED = "dismantled"
    PROCESSED = "processed"
    CERTIFICATE_ISSUED = "certificate_issued"


class PreferredLanguage(enum.StrEnum):
    MR = "mr"
    HI = "hi"
    EN = "en"


class LedgerEntryType(enum.StrEnum):
    CREDIT = "credit"
    DEBIT = "debit"


class HazardLevel(enum.StrEnum):
    INFO = "info"
    WARNING = "warning"
    DANGER = "danger"


class SyncActionStatus(enum.StrEnum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    DEAD_LETTER = "dead_letter"


class DataProvenanceSource(enum.StrEnum):
    SYNTHETIC = "synthetic"
    FIELD = "field"
    SCRAPED_PUBLIC = "scraped_public"


class UserRole(enum.StrEnum):
    COLLECTOR = "collector"
    RECYCLER = "recycler"
    ADMIN = "admin"


# -----------------------------------------------------------------------------
# Models
# -----------------------------------------------------------------------------


class Collector(Base):
    """Informal E-Waste Collector Profile (Strict Data Minimization: No Aadhaar/Name)."""

    __tablename__ = "collectors"

    collector_id: Mapped[str] = mapped_column(String(32), primary_key=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(20), unique=True, nullable=True, index=True)
    pin_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    preferred_language: Mapped[PreferredLanguage] = mapped_column(
        Enum(PreferredLanguage), default=PreferredLanguage.MR, nullable=False
    )
    operating_area: Mapped[str] = mapped_column(
        String(100), nullable=False, comment="District only"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    transactions: Mapped[list["Transaction"]] = relationship(
        "Transaction", back_populates="collector"
    )
    ledger_entries: Mapped[list["LedgerEntry"]] = relationship(
        "LedgerEntry", back_populates="collector"
    )


class Material(Base):
    """Catalog of E-Waste Materials and Categories."""

    __tablename__ = "materials"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    sub_category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    image_ref: Mapped[str | None] = mapped_column(String(255), nullable=True)
    approx_weight_kg: Mapped[float] = mapped_column(Float, nullable=False)
    condition: Mapped[MaterialCondition] = mapped_column(Enum(MaterialCondition), nullable=False)
    source_type: Mapped[SourceType] = mapped_column(Enum(SourceType), nullable=False)
    estimated_value: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )


class Recycler(Base):
    """Authorized E-Waste Recycler / Aggregator under EPR Rules 2022."""

    __tablename__ = "recyclers"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    facility_location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=False)
    materials_accepted: Mapped[list[str]] = mapped_column(JSONCompatible, nullable=False)
    authorization_number: Mapped[str] = mapped_column(
        String(100), unique=True, nullable=False, index=True
    )
    authorization_body: Mapped[AuthorizationBody] = mapped_column(
        Enum(AuthorizationBody), nullable=False
    )
    authorization_status: Mapped[AuthorizationStatus] = mapped_column(
        Enum(AuthorizationStatus), default=AuthorizationStatus.PENDING, nullable=False
    )
    authorization_valid_till: Mapped[date] = mapped_column(Date, nullable=False)
    phone: Mapped[str] = mapped_column(String(20), nullable=False)
    offered_rates: Mapped[dict[str, Any]] = mapped_column(
        JSONCompatible, default=dict, nullable=False
    )
    pickup_available: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    pickup_radius_km: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    service_area: Mapped[dict[str, Any]] = mapped_column(
        JSONCompatible, default=dict, nullable=False
    )
    rating: Mapped[float] = mapped_column(Numeric(3, 2), default=0.0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )

    prices: Mapped[list["Price"]] = relationship("Price", back_populates="recycler")
    transactions: Mapped[list["Transaction"]] = relationship(
        "Transaction", back_populates="recycler"
    )

    __table_args__ = (
        Index("idx_recyclers_facility_location", facility_location, postgresql_using="gist"),
        CheckConstraint("rating >= 0.0 AND rating <= 5.0", name="chk_recycler_rating_range"),
    )


class Price(Base):
    """Regional & Benchmark Pricing Records for E-Waste Materials."""

    __tablename__ = "prices"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    sub_category: Mapped[str | None] = mapped_column(String(50), nullable=True, index=True)
    district: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    city: Mapped[str | None] = mapped_column(String(100), nullable=True)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False, index=True
    )
    buying_price: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    selling_quoted_price: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    unit: Mapped[PriceUnit] = mapped_column(Enum(PriceUnit), default=PriceUnit.KG, nullable=False)
    market_min: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    market_max: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    recycler_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("recyclers.id"), nullable=True
    )
    source: Mapped[PriceSource] = mapped_column(
        Enum(PriceSource), default=PriceSource.SYNTHETIC, nullable=False
    )
    is_flagged_for_review: Mapped[bool] = mapped_column(
        Boolean, default=False, server_default="false", nullable=False
    )
    review_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    recycler: Mapped[Recycler | None] = relationship("Recycler", back_populates="prices")

    __table_args__ = (
        Index("idx_prices_location", location, postgresql_using="gist"),
        CheckConstraint("market_min <= market_max", name="chk_price_min_max"),
        CheckConstraint("buying_price >= 0", name="chk_price_buying_positive"),
    )


class Transaction(Base):
    """E-Waste Lot Transactions and Handover State Machine."""

    __tablename__ = "transactions"

    lot_id: Mapped[str] = mapped_column(
        String(40), primary_key=True, index=True, comment="e.g. KC-MH-2609-00123"
    )
    collector_id: Mapped[str] = mapped_column(
        String(32), ForeignKey("collectors.collector_id"), nullable=False, index=True
    )
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    weight_kg: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    quoted_price: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    final_price: Mapped[float | None] = mapped_column(Numeric(12, 2), nullable=True)
    recycler_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("recyclers.id"), nullable=True, index=True
    )
    collection_location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=False)
    handover_location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False, index=True
    )
    handover_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    payment_status: Mapped[PaymentStatus] = mapped_column(
        Enum(PaymentStatus), default=PaymentStatus.PENDING, nullable=False, index=True
    )
    transaction_status: Mapped[TransactionStatus] = mapped_column(
        Enum(TransactionStatus), default=TransactionStatus.DRAFT, nullable=False, index=True
    )
    anomaly_flag: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)
    anomaly_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )

    collector: Mapped[Collector] = relationship("Collector", back_populates="transactions")
    recycler: Mapped[Recycler | None] = relationship("Recycler", back_populates="transactions")
    traceability_records: Mapped[list["Traceability"]] = relationship(
        "Traceability", back_populates="transaction"
    )
    ledger_entries: Mapped[list["LedgerEntry"]] = relationship(
        "LedgerEntry", back_populates="transaction"
    )

    __table_args__ = (
        Index("idx_transactions_collection_location", collection_location, postgresql_using="gist"),
        Index("idx_transactions_handover_location", handover_location, postgresql_using="gist"),
        CheckConstraint("weight_kg > 0", name="chk_transaction_weight_positive"),
        CheckConstraint("quoted_price >= 0", name="chk_transaction_quoted_positive"),
    )


class Traceability(Base):
    """Tamper-Evident Hash-Chained Handover Audit Trail for EPR."""

    __tablename__ = "traceability"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    lot_id: Mapped[str] = mapped_column(
        String(40), ForeignKey("transactions.lot_id"), nullable=False, index=True
    )
    photo_hashes: Mapped[list[str]] = mapped_column(JSONCompatible, nullable=False)
    weight_kg: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False, index=True
    )
    gps_lat: Mapped[float] = mapped_column(Float, nullable=False)
    gps_lng: Mapped[float] = mapped_column(Float, nullable=False)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=False)
    handover_ref_no: Mapped[str] = mapped_column(
        String(64), unique=True, nullable=False, index=True
    )
    qr_payload: Mapped[str] = mapped_column(Text, nullable=False)
    recycler_confirmation: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    confirmed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    confirmed_by: Mapped[str | None] = mapped_column(String(100), nullable=True)
    downstream_status: Mapped[DownstreamStatus] = mapped_column(
        Enum(DownstreamStatus), default=DownstreamStatus.RECEIVED, nullable=False
    )
    record_hash: Mapped[str] = mapped_column(
        String(64), nullable=False, index=True, comment="SHA-256"
    )
    prev_hash: Mapped[str] = mapped_column(
        String(64), nullable=False, comment="SHA-256 hash chained"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    transaction: Mapped[Transaction] = relationship(
        "Transaction", back_populates="traceability_records"
    )

    __table_args__ = (Index("idx_traceability_location", location, postgresql_using="gist"),)


class LedgerEntry(Base):
    """Cash-First Financial Ledger for Informal Collectors."""

    __tablename__ = "ledger_entries"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    collector_id: Mapped[str] = mapped_column(
        String(32), ForeignKey("collectors.collector_id"), nullable=False, index=True
    )
    lot_id: Mapped[str | None] = mapped_column(
        String(40), ForeignKey("transactions.lot_id"), nullable=True, index=True
    )
    entry_type: Mapped[LedgerEntryType] = mapped_column(Enum(LedgerEntryType), nullable=False)
    amount: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    payment_mode: Mapped[PaymentStatus] = mapped_column(
        Enum(PaymentStatus), default=PaymentStatus.CASH_RECEIVED, nullable=False
    )
    description: Mapped[str] = mapped_column(String(255), nullable=False)
    balance_after: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False, index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    collector: Mapped[Collector] = relationship("Collector", back_populates="ledger_entries")
    transaction: Mapped[Transaction | None] = relationship(
        "Transaction", back_populates="ledger_entries"
    )

    __table_args__ = (CheckConstraint("amount >= 0", name="chk_ledger_amount_positive"),)


class SafetyContent(Base):
    """Vernacular Dismantling & Safety Instruction Cards."""

    __tablename__ = "safety_content"

    id: Mapped[str] = mapped_column(String(32), primary_key=True, comment="e.g. SAFE-BATT-01")
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    hazard_level: Mapped[HazardLevel] = mapped_column(
        Enum(HazardLevel), default=HazardLevel.INFO, nullable=False
    )
    pictogram_url: Mapped[str] = mapped_column(String(255), nullable=False)
    audio_prompt_urls: Mapped[dict[str, str]] = mapped_column(
        JSONCompatible, default=dict, nullable=False, comment="Map of locale to audio URL"
    )
    title_vernacular: Mapped[dict[str, str]] = mapped_column(
        JSONCompatible, default=dict, nullable=False
    )
    instructions_vernacular: Mapped[dict[str, str]] = mapped_column(
        JSONCompatible, default=dict, nullable=False
    )
    dos: Mapped[list[str]] = mapped_column(JSONCompatible, default=list, nullable=False)
    donts: Mapped[list[str]] = mapped_column(JSONCompatible, default=list, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )


class SyncQueue(Base):
    """Server-Side Record of Ingested Offline Sync Actions with Idempotency."""

    __tablename__ = "sync_queue"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    collector_id: Mapped[str] = mapped_column(String(32), nullable=False, index=True)
    client_tx_id: Mapped[str] = mapped_column(
        String(64), unique=True, nullable=False, index=True, comment="Idempotency key"
    )
    action: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    payload: Mapped[dict[str, Any]] = mapped_column(JSONCompatible, nullable=False)
    status: Mapped[SyncActionStatus] = mapped_column(
        Enum(SyncActionStatus), default=SyncActionStatus.PENDING, nullable=False, index=True
    )
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    last_error: Mapped[str | None] = mapped_column(Text, nullable=True)
    client_timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    processed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )


class MLTrainingSample(Base):
    """Labeled E-Waste Images and Multi-Modal Training Samples."""

    __tablename__ = "ml_training_samples"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    image_path: Mapped[str] = mapped_column(String(255), nullable=False)
    label: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    weight_kg: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    price: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=True)
    source: Mapped[DataProvenanceSource] = mapped_column(
        Enum(DataProvenanceSource),
        default=DataProvenanceSource.SYNTHETIC,
        nullable=False,
        index=True,
    )
    quality_score: Mapped[float] = mapped_column(Float, default=1.0, nullable=False)
    verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)
    verified_by: Mapped[str | None] = mapped_column(String(100), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    __table_args__ = (Index("idx_ml_samples_location", location, postgresql_using="gist"),)


class User(Base):
    """User account credentials and role mapping (collector, recycler, admin)."""

    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    email: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(20), unique=True, nullable=True, index=True)
    hashed_password: Mapped[str | None] = mapped_column(String(255), nullable=True)
    pin_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole), nullable=False, default=UserRole.COLLECTOR, index=True
    )
    collector_id: Mapped[str | None] = mapped_column(
        String(32), ForeignKey("collectors.collector_id"), nullable=True
    )
    recycler_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("recyclers.id"), nullable=True
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )
