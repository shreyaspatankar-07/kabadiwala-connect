"""SQLAlchemy Model for Dynamic System Configurations."""

from typing import Any

from sqlalchemy import String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.schema import Base, JSONCompatible


class SystemConfig(Base):
    """Dynamic system configurations and threshold settings."""

    __tablename__ = "system_configs"

    key: Mapped[str] = mapped_column(String(128), primary_key=True)
    value: Mapped[dict[str, Any]] = mapped_column(
        JSONB().with_variant(JSONCompatible(), "sqlite"),
        nullable=False,
    )
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
