"""Test configuration, fixtures, and in-memory test database."""

from collections.abc import AsyncGenerator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import event
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import StaticPool

from app.api.deps import get_db
from app.core.security import create_access_token
from app.main import app
from app.models.schema import Base, Collector, PreferredLanguage, User, UserRole


@pytest.fixture(scope="session")
def test_engine():
    engine = create_async_engine(
        "sqlite+aiosqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        echo=False,
    )

    @event.listens_for(engine.sync_engine, "connect")
    def set_sqlite_functions(dbapi_connection, connection_record):
        def as_ewkb(val):
            if val is None:
                return None
            if isinstance(val, bytes):
                return val
            if isinstance(val, str):
                import shapely.wkt

                if val.startswith("SRID="):
                    val = val.split(";", 1)[1]
                try:
                    return shapely.wkt.loads(val).wkb
                except Exception:
                    return shapely.wkt.loads("POINT(0 0)").wkb
            return None

        dbapi_connection.create_function("RecoverGeometryColumn", 5, lambda a, b, c, d, e: 1)
        dbapi_connection.create_function("DiscardGeometryColumn", 2, lambda a, b: 1)
        dbapi_connection.create_function("InitSpatialMetaData", 0, lambda: 1)
        dbapi_connection.create_function("CreateSpatialIndex", 2, lambda a, b: 1)
        dbapi_connection.create_function("DisableSpatialIndex", 2, lambda a, b: 1)
        dbapi_connection.create_function("CheckSpatialIndex", 2, lambda a, b: 1)
        to_str = lambda val: val if isinstance(val, str) else str(val)  # noqa: E731
        dbapi_connection.create_function("GeomFromEWKT", 1, to_str)
        dbapi_connection.create_function("AsEWKT", 1, to_str)
        dbapi_connection.create_function("ST_GeomFromEWKT", 1, to_str)
        dbapi_connection.create_function("ST_AsEWKT", 1, to_str)
        dbapi_connection.create_function("AsEWKB", 1, as_ewkb)
        dbapi_connection.create_function("ST_AsBinary", 1, as_ewkb)
        dbapi_connection.create_function("GeomFromEWKB", 1, lambda b: b)

    return engine


@pytest.fixture
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = async_sessionmaker(
        bind=test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async with async_session() as session:
        yield session
        await session.rollback()

    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
async def async_client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client

    app.dependency_overrides.clear()


@pytest.fixture
async def test_collector(db_session: AsyncSession) -> tuple[User, str]:
    """Create a sample collector and generate their JWT token."""
    col = Collector(
        collector_id="KC-C-TEST01",
        phone="+919876543210",
        preferred_language=PreferredLanguage.MR,
        operating_area="Mumbai Suburban",
    )
    db_session.add(col)
    await db_session.flush()

    user = User(
        phone="+919876543210",
        role=UserRole.COLLECTOR,
        collector_id="KC-C-TEST01",
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)

    token = create_access_token(
        subject=str(user.id),
        role="collector",
        extra_claims={"collector_id": "KC-C-TEST01"},
    )
    return user, token


@pytest.fixture
async def test_admin(db_session: AsyncSession) -> tuple[User, str]:
    """Create an admin user and token."""
    user = User(
        email="admin@kabadiwala.in",
        role=UserRole.ADMIN,
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)

    token = create_access_token(
        subject=str(user.id),
        role="admin",
    )
    return user, token


@pytest.fixture
async def test_recycler_user(db_session: AsyncSession) -> tuple[User, str]:
    """Create a recycler user and token."""
    user = User(
        email="recycler@ecorecycle.in",
        role=UserRole.RECYCLER,
        recycler_id="REC-TEST-001",
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)

    token = create_access_token(
        subject=str(user.id),
        role="recycler",
        extra_claims={"recycler_id": "REC-TEST-001"},
    )
    return user, token
