"""Pricing benchmark and regional price board aggregation service."""

import uuid
from datetime import UTC, datetime, timedelta

from geoalchemy2.elements import WKTElement
from geoalchemy2.shape import to_shape
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.models.schema import Price, PriceSource, PriceUnit
from app.schemas.prices import (
    PriceBoardCategory,
    PriceBoardResponse,
    PriceCreate,
    PriceResponse,
)


class PricesService:
    @staticmethod
    def _to_response(p: Price) -> PriceResponse:
        try:
            pt = to_shape(p.location)
            lat, lon = pt.y, pt.x
        except Exception:
            lat, lon = 0.0, 0.0

        return PriceResponse(
            id=p.id,
            category=p.category,
            sub_category=p.sub_category,
            district=p.district,
            city=p.city,
            latitude=lat,
            longitude=lon,
            recorded_at=p.recorded_at,
            buying_price=float(p.buying_price),
            selling_quoted_price=float(p.selling_quoted_price),
            unit=p.unit.value,
            market_min=float(p.market_min),
            market_max=float(p.market_max),
            recycler_id=p.recycler_id,
            source=p.source.value,
            created_at=p.created_at,
        )

    @classmethod
    async def list_prices(
        cls,
        db: AsyncSession,
        district: str | None = None,
        category: str | None = None,
    ) -> list[PriceResponse]:
        query = select(Price)
        if district:
            query = query.where(Price.district.ilike(f"%{district}%"))
        if category:
            query = query.where(Price.category == category)
        result = await db.execute(query.order_by(Price.recorded_at.desc()).limit(100))
        prices = result.scalars().all()
        return [cls._to_response(p) for p in prices]

    @classmethod
    async def get_price(cls, price_id: uuid.UUID, db: AsyncSession) -> PriceResponse:
        res = await db.execute(select(Price).where(Price.id == price_id))
        p = res.scalar_one_or_none()
        if not p:
            raise NotFoundError("Price", price_id)
        return cls._to_response(p)

    @classmethod
    async def create_price(cls, data: PriceCreate, db: AsyncSession) -> PriceResponse:
        pt = WKTElement(f"POINT({data.longitude} {data.latitude})", srid=4326)
        p = Price(
            category=data.category,
            sub_category=data.sub_category,
            district=data.district,
            city=data.city,
            location=pt,
            buying_price=data.buying_price,
            selling_quoted_price=data.selling_quoted_price,
            unit=PriceUnit(data.unit),
            market_min=data.market_min,
            market_max=data.market_max,
            recycler_id=data.recycler_id,
            source=PriceSource(data.source),
        )
        db.add(p)
        await db.commit()
        await db.refresh(p)
        return cls._to_response(p)

    @classmethod
    async def get_price_board(cls, district: str, db: AsyncSession) -> PriceBoardResponse:
        """Aggregate current active market price board for collectors in a district."""
        stmt = (
            select(
                Price.category,
                Price.sub_category,
                Price.unit,
                func.min(Price.market_min).label("min_rate"),
                func.max(Price.market_max).label("max_rate"),
                func.avg(Price.buying_price).label("avg_rate"),
            )
            .where(Price.district.ilike(f"%{district}%"))
            .group_by(Price.category, Price.sub_category, Price.unit)
        )
        res = await db.execute(stmt)
        rows = res.all()

        rates = [
            PriceBoardCategory(
                category=r.category,
                sub_category=r.sub_category,
                unit=r.unit.value,
                min_rate_inr=float(r.min_rate or 0.0),
                max_rate_inr=float(r.max_rate or 0.0),
                avg_buying_price=round(float(r.avg_rate or 0.0), 2),
            )
            for r in rows
        ]

        valid_until = datetime.now(UTC) + timedelta(days=1)
        return PriceBoardResponse(district=district, valid_until=valid_until, rates=rates)
