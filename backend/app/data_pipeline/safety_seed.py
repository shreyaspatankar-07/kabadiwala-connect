"""CLI tool and standalone runner to seed safety guidance content."""

from app.db.session import SessionLocal
from app.services.safety_service import SafetyService


def main() -> None:
    """Run safety content seeding."""
    print("Seeding safety guidance cards into database...")
    db = SessionLocal()
    try:
        count = SafetyService.seed_safety_content(db)
        print(f"Successfully seeded {count} safety guidance cards.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
