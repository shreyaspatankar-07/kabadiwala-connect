"""Seed script to populate initial system configurations in Supabase / PostgreSQL."""

import asyncio
import json
import logging
import sys
from pathlib import Path

# Ensure backend directory is in path
backend_dir = Path(__file__).resolve().parent.parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert as pg_insert

from app.core.database import AsyncSessionLocal
from app.models.system_config import SystemConfig

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("seed_system_configs")

INITIAL_CONFIGS = [
    {
        "key": "fraud_thresholds",
        "value": {
            "velocity_burst_seconds": 120,
            "max_gps_jump_km": 50.0,
            "weight_tolerance_percent": 10.0,
        },
        "description": "Dynamic thresholds for the Isolation Forest and deterministic fraud guards",
    }
]


async def seed_system_configs() -> None:
    """Upsert initial system configurations into the system_configs table."""
    logger.info("Connecting to database to seed system_configs...")
    async with AsyncSessionLocal() as session:
        for cfg in INITIAL_CONFIGS:
            stmt = select(SystemConfig).where(SystemConfig.key == cfg["key"])
            existing = (await session.execute(stmt)).scalar_one_or_none()
            if existing:
                existing.value = cfg["value"]
                existing.description = cfg["description"]
                logger.info(f"Updated existing configuration for key: {cfg['key']}")
            else:
                new_entry = SystemConfig(
                    key=cfg["key"],
                    value=cfg["value"],
                    description=cfg["description"],
                )
                session.add(new_entry)
                logger.info(f"Inserted new configuration for key: {cfg['key']}")
        await session.commit()
    logger.info("Seeding completed successfully.")


if __name__ == "__main__":
    asyncio.run(seed_system_configs())
