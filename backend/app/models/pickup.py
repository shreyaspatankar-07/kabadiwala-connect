"""SQLAlchemy Model for Citizen Doorstep Pickup Requests."""

import enum
import uuid
from datetime import UTC, datetime

from geoalchemy2 import Geometry
from sqlalchemy import (
    DateTime,
    Enum,
    ForeignKey,
    Index,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.schema import Base, JSONCompatible, User


class PickupStatus(enum.StrEnum):
    CREATED = "CREATED"
    DISPATCHED = "DISPATCHED"
    ACCEPTED = "ACCEPTED"
    ARRIVED = "ARRIVED"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class PickupRequest(Base):
    """Citizen doorstep e-waste pickup request model."""

    __tablename__ = "pickup_requests"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    public_code: Mapped[str] = mapped_column(String(32), unique=True, index=True, nullable=False)
    citizen_phone: Mapped[str] = mapped_column(String(32), nullable=False, index=True)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=False)
    address_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    photo_urls: Mapped[list[str]] = mapped_column(JSONCompatible, default=list, nullable=False)
    categories: Mapped[list[str]] = mapped_column(JSONCompatible, default=list, nullable=False)
    status: Mapped[PickupStatus] = mapped_column(
        Enum(PickupStatus, values_callable=lambda x: [e.value for e in x], name="pickupstatus"),
        default=PickupStatus.CREATED,
        nullable=False,
        index=True,
    )
    assigned_collector_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), nullable=True, index=True
    )
    assigned_collector: Mapped[User | None] = relationship("User", foreign_keys=[assigned_collector_id])
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )

    __table_args__ = (
        Index("idx_pickup_requests_location", location, postgresql_using="gist"),
    )
