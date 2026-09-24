"""Recycler management, admin verification workflow, and expiry auditing service."""

from datetime import UTC, date, datetime

from geoalchemy2.elements import WKTElement
from geoalchemy2.shape import to_shape
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.models.schema import AuthorizationBody, AuthorizationStatus, Recycler
from app.schemas.recyclers import RecyclerCreate, RecyclerResponse, RecyclerUpdate


class RecyclersService:
    @staticmethod
    def _to_response(r: Recycler) -> RecyclerResponse:
        try:
            pt = to_shape(r.facility_location)
            lat, lon = pt.y, pt.x
        except Exception:
            lat, lon = 0.0, 0.0

        return RecyclerResponse(
            id=r.id,
            name=r.name,
            latitude=lat,
            longitude=lon,
            materials_accepted=r.materials_accepted,
            authorization_number=r.authorization_number,
            authorization_body=r.authorization_body.value,
            authorization_status=r.authorization_status.value,
            authorization_valid_till=r.authorization_valid_till,
            phone=r.phone,
            offered_rates=r.offered_rates,
            pickup_available=r.pickup_available,
            pickup_radius_km=r.pickup_radius_km,
            service_area=r.service_area,
            rating=float(r.rating),
            created_at=r.created_at,
            updated_at=r.updated_at,
        )

    @classmethod
    async def list_recyclers(
        cls,
        db: AsyncSession,
        status: str | None = None,
        category: str | None = None,
    ) -> list[RecyclerResponse]:
        query = select(Recycler)
        if status:
            query = query.where(Recycler.authorization_status == AuthorizationStatus(status))
        result = await db.execute(query.order_by(Recycler.name))
        recyclers = result.scalars().all()

        if category:
            recyclers = [r for r in recyclers if category in r.materials_accepted]

        return [cls._to_response(r) for r in recyclers]

    @classmethod
    async def get_recycler(cls, recycler_id: str, db: AsyncSession) -> RecyclerResponse:
        res = await db.execute(select(Recycler).where(Recycler.id == recycler_id))
        r = res.scalar_one_or_none()
        if not r:
            raise NotFoundError("Recycler", recycler_id)
        return cls._to_response(r)

    @classmethod
    async def create_recycler(cls, data: RecyclerCreate, db: AsyncSession) -> RecyclerResponse:
        pt = WKTElement(f"POINT({data.longitude} {data.latitude})", srid=4326)
        r = Recycler(
            id=data.id,
            name=data.name,
            facility_location=pt,
            materials_accepted=data.materials_accepted,
            authorization_number=data.authorization_number,
            authorization_body=AuthorizationBody(data.authorization_body),
            authorization_status=AuthorizationStatus.PENDING,
            authorization_valid_till=data.authorization_valid_till,
            phone=data.phone,
            offered_rates=data.offered_rates,
            pickup_available=data.pickup_available,
            pickup_radius_km=data.pickup_radius_km,
            service_area=data.service_area,
        )
        db.add(r)
        await db.commit()
        await db.refresh(r)
        return cls._to_response(r)

    @classmethod
    async def update_recycler(
        cls, recycler_id: str, data: RecyclerUpdate, db: AsyncSession
    ) -> RecyclerResponse:
        res = await db.execute(select(Recycler).where(Recycler.id == recycler_id))
        r = res.scalar_one_or_none()
        if not r:
            raise NotFoundError("Recycler", recycler_id)

        if data.name is not None:
            r.name = data.name
        if data.materials_accepted is not None:
            r.materials_accepted = data.materials_accepted
        if data.phone is not None:
            r.phone = data.phone
        if data.offered_rates is not None:
            r.offered_rates = data.offered_rates
        if data.pickup_available is not None:
            r.pickup_available = data.pickup_available
        if data.pickup_radius_km is not None:
            r.pickup_radius_km = data.pickup_radius_km
        if data.service_area is not None:
            r.service_area = data.service_area

        await db.commit()
        await db.refresh(r)
        return cls._to_response(r)

    @classmethod
    async def update_verification_status(
        cls, recycler_id: str, status_str: str, db: AsyncSession
    ) -> RecyclerResponse:
        """Admin action: approve, verify, or suspend recycler authorization."""
        res = await db.execute(select(Recycler).where(Recycler.id == recycler_id))
        r = res.scalar_one_or_none()
        if not r:
            raise NotFoundError("Recycler", recycler_id)

        r.authorization_status = AuthorizationStatus(status_str)
        await db.commit()
        await db.refresh(r)
        return cls._to_response(r)

    @staticmethod
    async def check_expired_authorizations(db: AsyncSession) -> int:
        """Scheduled audit job: automatically flags recyclers whose
        EPR authorization has expired.
        """
        today = date.today()
        stmt = (
            update(Recycler)
            .where(
                Recycler.authorization_valid_till < today,
                Recycler.authorization_status != AuthorizationStatus.EXPIRED,
            )
            .values(
                authorization_status=AuthorizationStatus.EXPIRED,
                updated_at=datetime.now(UTC),
            )
        )
        result = await db.execute(stmt)
        await db.commit()
        return result.rowcount
