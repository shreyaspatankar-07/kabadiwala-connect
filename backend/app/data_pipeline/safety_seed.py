"""CLI tool and standalone runner to seed safety guidance content."""

import asyncio

from app.core.database import AsyncSessionLocal
from app.services.safety_service import SafetyService


async def _run() -> None:
    """Run safety content seeding asynchronously."""
    print("Seeding safety guidance cards into database...")
    async with AsyncSessionLocal() as session:
        count = await SafetyService.seed_safety_content(session)
        await session.commit()
        print(f"Successfully seeded {count} safety guidance cards.")


def main() -> None:
    """Entry point for CLI and Makefile."""
    asyncio.run(_run())


if __name__ == "__main__":
    main()
