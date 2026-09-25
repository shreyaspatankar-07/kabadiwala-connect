"""Prices and regional Price Board API router."""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, require_role
from app.schemas.prices import (
    PriceBoardResponse,
    PriceCreate,
    PriceHistoryResponse,
    PriceReportCreate,
    PriceReportResponse,
    PriceResponse,
)
from app.services.prices_service import PricesService

router = APIRouter(prefix="/prices", tags=["Prices"])


@router.get("", response_model=list[PriceResponse], summary="List recorded scrap benchmark prices")
async def list_prices(
    db: Annotated[AsyncSession, Depends(get_db)],
    district: Annotated[str | None, Query(description="Filter by district")] = None,
    category: Annotated[str | None, Query(description="Filter by category")] = None,
):
    return await PricesService.list_prices(db, district=district, category=category)


@router.get(
    "/board", response_model=PriceBoardResponse, summary="Get active price board for district"
)
async def get_price_board(
    db: Annotated[AsyncSession, Depends(get_db)],
    district: Annotated[
        str, Query(description="District name, e.g. Mumbai, Pune, Palghar")
    ] = "Mumbai Suburban",
    category: Annotated[str | None, Query(description="Filter by scrap material category")] = None,
):
    return await PricesService.get_price_board(district, db, category=category)


@router.get(
    "/history",
    response_model=PriceHistoryResponse,
    summary="Get 30-day historical daily median prices for sparkline chart",
)
async def get_price_history(
    db: Annotated[AsyncSession, Depends(get_db)],
    district: Annotated[str, Query(description="District name")] = "Mumbai Suburban",
    category: Annotated[str, Query(description="Material category")] = "PCB",
    days: Annotated[int, Query(description="Number of history days", ge=1, le=90)] = 30,
):
    return await PricesService.get_price_history(district, category, days, db)


@router.post(
    "/report",
    response_model=PriceReportResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Collector reports an offered scrap price from the field",
)
async def report_price(
    data: PriceReportCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await PricesService.report_price(data, db)


@router.get("/{price_id}", response_model=PriceResponse, summary="Get price record by ID")
async def get_price(
    price_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await PricesService.get_price(price_id, db)


@router.post(
    "",
    response_model=PriceResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_role(["admin", "recycler"]))],
    summary="Record a new benchmark price quote",
)
async def create_price(
    data: PriceCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await PricesService.create_price(data, db)
