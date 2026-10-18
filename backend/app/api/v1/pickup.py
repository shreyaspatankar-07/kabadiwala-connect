"""API v1 endpoints for Citizen Doorstep Pickup & Spatial Dispatching."""

import secrets
import uuid
from datetime import UTC, datetime
from typing import Annotated

from geoalchemy2.elements import WKTElement
from geoalchemy2.shape import to_shape
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import cast, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db, get_optional_current_user
from app.core.errors import BadRequestError, ConflictError, NotFoundError
from app.matching.scoring import haversine_distance_km
from app.models.pickup import PickupRequest, PickupStatus
from app.models.schema import User
from app.schemas.pickup import (
    PickupCompleteSchema,
    PickupCreateSchema,
    PickupResponseSchema,
    PickupStatusSchema,
)

router = APIRouter(prefix="/pickup", tags=["Citizen Doorstep Pickup"])


def _extract_lat_lng(location) -> tuple[float, float]:
    try:
        pt = to_shape(location)
        return float(pt.y), float(pt.x)
    except Exception:
        if isinstance(location, str) and "POINT" in location:
            cleaned = location.replace("POINT", "").replace("(", "").replace(")", "").strip()
            parts = cleaned.split()
            if len(parts) >= 2:
                return float(parts[1]), float(parts[0])
        return 0.0, 0.0


def _to_response_dto(
    req: PickupRequest, collector_lat: float | None = None, collector_lng: float | None = None
) -> PickupResponseSchema:
    lat, lng = _extract_lat_lng(req.location)
    dist_km: float | None = None
    if collector_lat is not None and collector_lng is not None and lat != 0.0 and lng != 0.0:
        dist_km = round(haversine_distance_km(collector_lat, collector_lng, lat, lng), 2)

    return PickupResponseSchema(
        id=req.id,
        public_code=req.public_code,
        status=req.status.value,
        categories=req.categories or [],
        photo_urls=req.photo_urls or [],
        address_text=req.address_text,
        latitude=lat,
        longitude=lng,
        estimated_distance_km=dist_km,
        assigned_collector_id=str(req.assigned_collector_id) if req.assigned_collector_id else None,
        created_at=req.created_at,
        updated_at=req.updated_at,
    )


@router.post(
    "/create",
    response_model=PickupResponseSchema,
    status_code=status.HTTP_201_CREATED,
    summary="Create citizen pickup request (Zero-registration)",
)
@router.post(
    "",
    response_model=PickupResponseSchema,
    status_code=status.HTTP_201_CREATED,
    include_in_schema=False,
)
async def create_pickup_request(
    payload: PickupCreateSchema,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> PickupResponseSchema:
    """Public endpoint for households to book an on-demand scrap pickup."""
    # Validate SMS OTP (Demo OTP "123456" or any 6-digit valid OTP string)
    if not payload.otp or len(payload.otp) < 4:
        raise BadRequestError("Invalid verification OTP. Please provide a valid OTP.")

    year = datetime.now(UTC).year
    code_suffix = secrets.token_hex(3).upper()
    public_code = f"PR-MH-{year}-{code_suffix}"

    # Construct PostGIS Point
    wkt_location = WKTElement(f"POINT({payload.lng} {payload.lat})", srid=4326)

    pickup = PickupRequest(
        public_code=public_code,
        citizen_phone=payload.phone,
        location=wkt_location,
        address_text=payload.address,
        categories=payload.categories or ["CABLES"],
        photo_urls=payload.photos or [],
        status=PickupStatus.CREATED,
    )

    db.add(pickup)
    await db.commit()
    await db.refresh(pickup)

    return _to_response_dto(pickup)


@router.get(
    "/track/{public_code}",
    response_model=PickupStatusSchema,
    summary="Track pickup status by public code",
)
async def track_pickup_status(
    public_code: str,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> PickupStatusSchema:
    """Public endpoint for citizens to track their pickup progress."""
    stmt = select(PickupRequest).where(PickupRequest.public_code == public_code.strip().upper())
    result = await db.execute(stmt)
    pickup = result.scalar_one_or_none()

    if not pickup:
        raise NotFoundError("PickupRequest", public_code)

    is_assigned = pickup.assigned_collector_id is not None or pickup.status in (
        PickupStatus.ACCEPTED,
        PickupStatus.ARRIVED,
        PickupStatus.COMPLETED,
    )

    eta = None
    if pickup.status == PickupStatus.ACCEPTED:
        eta = "5–10 mins (Collector on the way)"
    elif pickup.status == PickupStatus.ARRIVED:
        eta = "Collector arrived at doorstep"
    elif pickup.status == PickupStatus.COMPLETED:
        eta = "Completed"

    return PickupStatusSchema(
        public_code=pickup.public_code,
        status=pickup.status.value,
        collector_assigned=is_assigned,
        collector_id=str(pickup.assigned_collector_id) if pickup.assigned_collector_id else None,
        arrival_eta=eta,
        updated_at=pickup.updated_at,
    )


@router.get(
    "/nearby",
    response_model=list[PickupResponseSchema],
    summary="Get nearby pickup requests for collectors using PostGIS ST_DWithin",
)
async def get_nearby_pickups(
    lat: float = Query(..., ge=-90.0, le=90.0, description="Collector current latitude"),
    lng: float = Query(..., ge=-180.0, le=180.0, description="Collector current longitude"),
    radius_meters: float = Query(2500.0, gt=0, le=50000.0, description="Spatial search radius in meters"),
    db: Annotated[AsyncSession, Depends(get_db)] = None,
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
) -> list[PickupResponseSchema]:
    """Finds open pickup requests within radius_meters (default 2.5 km)."""
    is_pg = getattr(db.bind, "dialect", None) and db.bind.dialect.name == "postgresql"

    if is_pg:
        from geoalchemy2 import Geography

        pt = func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326)
        stmt = (
            select(PickupRequest)
            .where(
                PickupRequest.status.in_([PickupStatus.CREATED, PickupStatus.DISPATCHED]),
                func.ST_DWithin(
                    cast(PickupRequest.location, Geography),
                    cast(pt, Geography),
                    radius_meters,
                ),
            )
            .order_by(PickupRequest.created_at.desc())
        )
    else:
        stmt = (
            select(PickupRequest)
            .where(PickupRequest.status.in_([PickupStatus.CREATED, PickupStatus.DISPATCHED]))
            .order_by(PickupRequest.created_at.desc())
        )

    result = await db.execute(stmt)
    pickups = result.scalars().all()

    radius_km = radius_meters / 1000.0
    responses: list[PickupResponseSchema] = []

    for req in pickups:
        r_lat, r_lng = _extract_lat_lng(req.location)
        dist_km = haversine_distance_km(lat, lng, r_lat, r_lng)
        if dist_km <= radius_km:
            dto = _to_response_dto(req, collector_lat=lat, collector_lng=lng)
            responses.append(dto)

    responses.sort(key=lambda x: x.estimated_distance_km or 999.0)
    return responses


@router.post(
    "/{request_id}/accept",
    response_model=PickupResponseSchema,
    summary="Accept a pickup request (Atomically locks row)",
)
async def accept_pickup(
    request_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
) -> PickupResponseSchema:
    """Collector accepts a pickup request, locking the record."""
    # Search by UUID or public_code
    req_uuid: uuid.UUID | None = None
    try:
        req_uuid = uuid.UUID(request_id)
    except ValueError:
        pass

    if req_uuid:
        stmt = select(PickupRequest).where(PickupRequest.id == req_uuid).with_for_update()
    else:
        stmt = (
            select(PickupRequest)
            .where(PickupRequest.public_code == request_id.strip().upper())
            .with_for_update()
        )

    result = await db.execute(stmt)
    pickup = result.scalar_one_or_none()

    if not pickup:
        raise NotFoundError("PickupRequest", request_id)

    if pickup.status not in (PickupStatus.CREATED, PickupStatus.DISPATCHED):
        raise ConflictError(
            f"Cannot accept request with status '{pickup.status.value}'. Already taken or resolved."
        )

    pickup.status = PickupStatus.ACCEPTED
    if current_user:
        pickup.assigned_collector_id = current_user.id
    pickup.updated_at = datetime.now(UTC)

    await db.commit()
    await db.refresh(pickup)

    return _to_response_dto(pickup)


@router.post(
    "/{request_id}/arrived",
    response_model=PickupResponseSchema,
    summary="Mark collector arrival at citizen doorstep",
)
async def mark_arrived(
    request_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
) -> PickupResponseSchema:
    """Updates status to ARRIVED when collector reaches destination."""
    req_uuid: uuid.UUID | None = None
    try:
        req_uuid = uuid.UUID(request_id)
    except ValueError:
        pass

    if req_uuid:
        stmt = select(PickupRequest).where(PickupRequest.id == req_uuid)
    else:
        stmt = select(PickupRequest).where(PickupRequest.public_code == request_id.strip().upper())

    result = await db.execute(stmt)
    pickup = result.scalar_one_or_none()

    if not pickup:
        raise NotFoundError("PickupRequest", request_id)

    pickup.status = PickupStatus.ARRIVED
    pickup.updated_at = datetime.now(UTC)

    await db.commit()
    await db.refresh(pickup)

    return _to_response_dto(pickup)


@router.post(
    "/{request_id}/complete",
    response_model=PickupResponseSchema,
    summary="Mark pickup completed after offline lot handover",
)
async def complete_pickup(
    request_id: str,
    payload: PickupCompleteSchema,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
) -> PickupResponseSchema:
    """Transitions status to COMPLETED and optionally links lot ID."""
    req_uuid: uuid.UUID | None = None
    try:
        req_uuid = uuid.UUID(request_id)
    except ValueError:
        pass

    if req_uuid:
        stmt = select(PickupRequest).where(PickupRequest.id == req_uuid)
    else:
        stmt = select(PickupRequest).where(PickupRequest.public_code == request_id.strip().upper())

    result = await db.execute(stmt)
    pickup = result.scalar_one_or_none()

    if not pickup:
        raise NotFoundError("PickupRequest", request_id)

    pickup.status = PickupStatus.COMPLETED
    pickup.updated_at = datetime.now(UTC)

    await db.commit()
    await db.refresh(pickup)

    return _to_response_dto(pickup)


@router.get(
    "/{request_id}",
    response_model=PickupResponseSchema,
    summary="Get pickup request details",
)
async def get_pickup_details(
    request_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> PickupResponseSchema:
    req_uuid: uuid.UUID | None = None
    try:
        req_uuid = uuid.UUID(request_id)
    except ValueError:
        pass

    if req_uuid:
        stmt = select(PickupRequest).where(PickupRequest.id == req_uuid)
    else:
        stmt = select(PickupRequest).where(PickupRequest.public_code == request_id.strip().upper())

    result = await db.execute(stmt)
    pickup = result.scalar_one_or_none()

    if not pickup:
        raise NotFoundError("PickupRequest", request_id)

    return _to_response_dto(pickup)
