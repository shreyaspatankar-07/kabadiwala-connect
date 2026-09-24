"""Tests for Alembic migrations and revision integrity."""

from pathlib import Path

from alembic.config import Config
from alembic.script import ScriptDirectory


def test_alembic_configuration_and_revisions():
    """Verify that Alembic configuration finds revisions and head revision matches."""
    backend_dir = Path(__file__).parent.parent
    alembic_ini = backend_dir / "alembic.ini"
    assert alembic_ini.exists(), "alembic.ini not found"

    config = Config(str(alembic_ini))
    config.set_main_option("script_location", str(backend_dir / "alembic"))

    script = ScriptDirectory.from_config(config)
    head_rev = script.get_current_head()

    assert head_rev == "0001_initial_schema"

    rev = script.get_revision(head_rev)
    assert rev is not None
    assert rev.module.upgrade is not None
    assert rev.module.downgrade is not None


def test_initial_migration_contains_expected_tables():
    """Verify that the initial migration script creates all required domain tables."""
    backend_dir = Path(__file__).parent.parent
    migration_file = backend_dir / "alembic" / "versions" / "0001_initial_schema.py"
    assert migration_file.exists()

    content = migration_file.read_text(encoding="utf-8")
    expected_tables = [
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
    ]

    for table in expected_tables:
        assert f'"{table}"' in content, f"Table '{table}' not created in initial migration."
        assert f'op.drop_table("{table}")' in content, f"Table '{table}' drop not in downgrade."

    # Verify PostGIS extension is created
    assert "CREATE EXTENSION IF NOT EXISTS postgis;" in content
