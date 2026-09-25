"""Recyclers API router with admin approval workflow."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, require_role
from app.schemas.recyclers import (
    RecyclerCreate,
    RecyclerNearbyResponse,
    RecyclerResponse,
    RecyclerUpdate,
)
from app.services.recyclers_service import RecyclersService

router = APIRouter(prefix="/recyclers", tags=["Recyclers"])


@router.get(
    "/nearby",
    response_model=list[RecyclerNearbyResponse],
    summary="Find authorized recyclers nearby",
)
async def get_nearby_recyclers(
    lat: Annotated[float, Query(ge=-90.0, le=90.0, description="Collector latitude")],
    lng: Annotated[float, Query(ge=-180.0, le=180.0, description="Collector longitude")],
    db: Annotated[AsyncSession, Depends(get_db)],
    radius_km: Annotated[float, Query(gt=0, description="Search radius in kilometers")] = 25.0,
    category: Annotated[
        str | None, Query(description="Filter by accepted material category")
    ] = None,
):
    return await RecyclersService.get_nearby_recyclers(
        lat=lat, lng=lng, radius_km=radius_km, category=category, db=db
    )


@router.get("", response_model=list[RecyclerResponse], summary="List authorized recyclers")
async def list_recyclers(
    db: Annotated[AsyncSession, Depends(get_db)],
    status: Annotated[str | None, Query(description="Filter by authorization status")] = None,
    category: Annotated[str | None, Query(description="Filter by accepted category")] = None,
):
    return await RecyclersService.list_recyclers(db, status=status, category=category)


@router.get("/{recycler_id}", response_model=RecyclerResponse, summary="Get recycler by ID")
async def get_recycler(
    recycler_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await RecyclersService.get_recycler(recycler_id, db)


@router.post(
    "",
    response_model=RecyclerResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_role(["admin", "recycler"]))],
    summary="Register a new recycler facility",
)
async def create_recycler(
    data: RecyclerCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await RecyclersService.create_recycler(data, db)


@router.put(
    "/{recycler_id}",
    response_model=RecyclerResponse,
    dependencies=[Depends(require_role(["admin", "recycler"]))],
    summary="Update recycler details",
)
async def update_recycler(
    recycler_id: str,
    data: RecyclerUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await RecyclersService.update_recycler(recycler_id, data, db)


@router.post(
    "/{recycler_id}/verify",
    response_model=RecyclerResponse,
    dependencies=[Depends(require_role(["admin"]))],
    summary="Admin approves & verifies recycler authorization",
)
async def verify_recycler(
    recycler_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await RecyclersService.update_verification_status(recycler_id, "verified", db)


@router.post(
    "/{recycler_id}/suspend",
    response_model=RecyclerResponse,
    dependencies=[Depends(require_role(["admin"]))],
    summary="Admin suspends recycler authorization",
)
async def suspend_recycler(
    recycler_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await RecyclersService.update_verification_status(recycler_id, "suspended", db)


@router.post(
    "/jobs/audit-expired",
    summary="Audit job: auto-flag recyclers with expired EPR authorization",
    dependencies=[Depends(require_role(["admin"]))],
)
async def audit_expired_authorizations(db: Annotated[AsyncSession, Depends(get_db)]):
    count = await RecyclersService.check_expired_authorizations(db)
    return {"status": "audit_complete", "expired_records_flagged": count}
