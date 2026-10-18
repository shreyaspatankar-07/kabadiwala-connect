"""Add pickup_requests table with PostGIS geometry and spatial index.

Revision ID: 0003_pickup_requests
Revises: 0002_price_reporting_fields
Create Date: 2026-10-13 09:30:00.000000

"""

from collections.abc import Sequence

import geoalchemy2
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0003_pickup_requests"
down_revision: str | None = "0002_price_reporting_fields"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Create pickupstatus enum
    pickup_status_enum = postgresql.ENUM(
        "CREATED",
        "DISPATCHED",
        "ACCEPTED",
        "ARRIVED",
        "COMPLETED",
        "CANCELLED",
        name="pickupstatus",
        create_type=False,
    )
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        pickup_status_enum.create(bind, checkfirst=True)

    # 2. Create pickup_requests table
    op.create_table(
        "pickup_requests",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("public_code", sa.String(length=32), nullable=False),
        sa.Column("citizen_phone", sa.String(length=32), nullable=False),
        sa.Column(
            "location",
            geoalchemy2.types.Geometry(
                geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT", name="geometry"
            ),
            nullable=False,
        ),
        sa.Column("address_text", sa.Text(), nullable=True),
        sa.Column("photo_urls", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("categories", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column(
            "status",
            sa.Enum(
                "CREATED",
                "DISPATCHED",
                "ACCEPTED",
                "ARRIVED",
                "COMPLETED",
                "CANCELLED",
                name="pickupstatus",
            ),
            nullable=False,
            server_default="CREATED",
        ),
        sa.Column("assigned_collector_id", sa.UUID(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["assigned_collector_id"],
            ["users.id"],
            ondelete="SET NULL",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("public_code"),
    )

    op.create_index(
        "idx_pickup_requests_public_code", "pickup_requests", ["public_code"], unique=True
    )
    op.create_index(
        "idx_pickup_requests_phone", "pickup_requests", ["citizen_phone"], unique=False
    )
    op.create_index(
        "idx_pickup_requests_status", "pickup_requests", ["status"], unique=False
    )
    if bind.dialect.name == "postgresql":
        op.create_index(
            "idx_pickup_requests_location",
            "pickup_requests",
            ["location"],
            unique=False,
            postgresql_using="gist",
        )


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.drop_index("idx_pickup_requests_location", table_name="pickup_requests", postgresql_using="gist")
    op.drop_index("idx_pickup_requests_status", table_name="pickup_requests")
    op.drop_index("idx_pickup_requests_phone", table_name="pickup_requests")
    op.drop_index("idx_pickup_requests_public_code", table_name="pickup_requests")
    op.drop_table("pickup_requests")
    if bind.dialect.name == "postgresql":
        op.execute("DROP TYPE IF EXISTS pickupstatus;")
