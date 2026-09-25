"""Add collector_report to pricesource and review flags to prices table.

Revision ID: 0002_price_reporting_fields
Revises: 0001_initial_schema
Create Date: 2026-09-25 13:35:00.000000

"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0002_price_reporting_fields"
down_revision: str | None = "0001_initial_schema"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Add 'collector_report' to pricesource enum in Postgres
    op.execute("ALTER TYPE pricesource ADD VALUE IF NOT EXISTS 'collector_report';")

    # 2. Add is_flagged_for_review and review_reason to prices table
    op.add_column(
        "prices",
        sa.Column(
            "is_flagged_for_review", sa.Boolean(), server_default=sa.text("false"), nullable=False
        ),
    )
    op.add_column(
        "prices",
        sa.Column("review_reason", sa.String(length=255), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("prices", "review_reason")
    op.drop_column("prices", "is_flagged_for_review")
