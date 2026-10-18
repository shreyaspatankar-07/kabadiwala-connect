"""Add system_configs table with dynamic fraud thresholds.

Revision ID: 0004_system_configs
Revises: 0003_pickup_requests
Create Date: 2026-10-18 10:45:00.000000

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0004_system_configs"
down_revision: str | None = "0003_pickup_requests"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Create system_configs table
    system_configs_table = op.create_table(
        "system_configs",
        sa.Column("key", sa.String(length=128), nullable=False),
        sa.Column("value", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.PrimaryKeyConstraint("key"),
    )

    # 2. Seed initial configuration payload
    initial_payload = {
        "velocity_burst_seconds": 120,
        "max_gps_jump_km": 50.0,
        "weight_tolerance_percent": 10.0,
    }
    op.bulk_insert(
        system_configs_table,
        [
            {
                "key": "fraud_thresholds",
                "value": initial_payload,
                "description": "Dynamic thresholds for the Isolation Forest and deterministic fraud guards",
            }
        ],
    )


def downgrade() -> None:
    op.drop_table("system_configs")
