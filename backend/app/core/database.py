"""Database engine, async session factory, and dependency injection."""

from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings

# Engine configuration with production connection pooling & SSL/pooler safeguards
connect_args = {}
engine_kwargs = {
    "echo": False,
    "future": True,
    "pool_pre_ping": True,
    "pool_recycle": 1800,  # Prevent stale connection drops on cloud firewalls
}

# Apply cloud pool limits and Supabase connection pooler safeguards
db_url = settings.DATABASE_URL
if "supabase" in db_url or "pooler" in db_url or "sslmode=require" in db_url or "ssl=require" in db_url:
    connect_args["ssl"] = "require"
    # When connecting via Supabase PgBouncer/Supavisor transaction pooler (port 6543),
    # asyncpg prepared statements must be disabled.
    if ":6543" in db_url:
        connect_args["statement_cache_size"] = 0

if not db_url.startswith("sqlite"):
    engine_kwargs.update(
        {
            "pool_size": 5,        # Strict pool limit to respect free-tier max client limits
            "max_overflow": 10,    # Temporary burst headroom during peak requests
            "pool_timeout": 30.0,  # Timeout wait for available connection
        }
    )

if connect_args:
    engine_kwargs["connect_args"] = connect_args

engine = create_async_engine(db_url, **engine_kwargs)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency that yields an active database session per request."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
