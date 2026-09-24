"""Materials catalog API router."""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, require_role
from app.schemas.materials import MaterialCreate, MaterialResponse, MaterialUpdate
from app.services.materials_service import MaterialsService

router = APIRouter(prefix="/materials", tags=["Materials"])


@router.get("", response_model=list[MaterialResponse], summary="List materials catalog")
async def list_materials(
    db: Annotated[AsyncSession, Depends(get_db)],
    category: Annotated[str | None, Query(description="Filter by broad category")] = None,
):
    return await MaterialsService.list_materials(db, category=category)


@router.get("/{material_id}", response_model=MaterialResponse, summary="Get material by ID")
async def get_material(
    material_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await MaterialsService.get_material(material_id, db)


@router.post(
    "",
    response_model=MaterialResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_role(["admin"]))],
    summary="Add material to catalog (Admin only)",
)
async def create_material(
    data: MaterialCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await MaterialsService.create_material(data, db)


@router.put(
    "/{material_id}",
    response_model=MaterialResponse,
    dependencies=[Depends(require_role(["admin"]))],
    summary="Update material entry (Admin only)",
)
async def update_material(
    material_id: uuid.UUID,
    data: MaterialUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await MaterialsService.update_material(material_id, data, db)
