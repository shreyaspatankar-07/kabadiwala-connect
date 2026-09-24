"""Materials catalog service."""

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.models.schema import Material, MaterialCondition, SourceType
from app.schemas.materials import MaterialCreate, MaterialResponse, MaterialUpdate


class MaterialsService:
    @staticmethod
    async def list_materials(
        db: AsyncSession, category: str | None = None
    ) -> list[MaterialResponse]:
        query = select(Material)
        if category:
            query = query.where(Material.category == category)
        result = await db.execute(query.order_by(Material.category, Material.sub_category))
        materials = result.scalars().all()
        return [
            MaterialResponse(
                id=m.id,
                category=m.category,
                sub_category=m.sub_category,
                description=m.description,
                image_ref=m.image_ref,
                approx_weight_kg=m.approx_weight_kg,
                condition=m.condition.value,
                source_type=m.source_type.value,
                estimated_value=float(m.estimated_value),
                created_at=m.created_at,
                updated_at=m.updated_at,
            )
            for m in materials
        ]

    @staticmethod
    async def get_material(material_id: uuid.UUID, db: AsyncSession) -> MaterialResponse:
        res = await db.execute(select(Material).where(Material.id == material_id))
        m = res.scalar_one_or_none()
        if not m:
            raise NotFoundError("Material", material_id)
        return MaterialResponse(
            id=m.id,
            category=m.category,
            sub_category=m.sub_category,
            description=m.description,
            image_ref=m.image_ref,
            approx_weight_kg=m.approx_weight_kg,
            condition=m.condition.value,
            source_type=m.source_type.value,
            estimated_value=float(m.estimated_value),
            created_at=m.created_at,
            updated_at=m.updated_at,
        )

    @staticmethod
    async def create_material(data: MaterialCreate, db: AsyncSession) -> MaterialResponse:
        m = Material(
            category=data.category,
            sub_category=data.sub_category,
            description=data.description,
            image_ref=data.image_ref,
            approx_weight_kg=data.approx_weight_kg,
            condition=MaterialCondition(data.condition),
            source_type=SourceType(data.source_type),
            estimated_value=data.estimated_value,
        )
        db.add(m)
        await db.commit()
        await db.refresh(m)
        return MaterialResponse(
            id=m.id,
            category=m.category,
            sub_category=m.sub_category,
            description=m.description,
            image_ref=m.image_ref,
            approx_weight_kg=m.approx_weight_kg,
            condition=m.condition.value,
            source_type=m.source_type.value,
            estimated_value=float(m.estimated_value),
            created_at=m.created_at,
            updated_at=m.updated_at,
        )

    @staticmethod
    async def update_material(
        material_id: uuid.UUID, data: MaterialUpdate, db: AsyncSession
    ) -> MaterialResponse:
        res = await db.execute(select(Material).where(Material.id == material_id))
        m = res.scalar_one_or_none()
        if not m:
            raise NotFoundError("Material", material_id)

        if data.description is not None:
            m.description = data.description
        if data.approx_weight_kg is not None:
            m.approx_weight_kg = data.approx_weight_kg
        if data.condition is not None:
            m.condition = MaterialCondition(data.condition)
        if data.source_type is not None:
            m.source_type = SourceType(data.source_type)
        if data.estimated_value is not None:
            m.estimated_value = data.estimated_value

        await db.commit()
        await db.refresh(m)
        return MaterialResponse(
            id=m.id,
            category=m.category,
            sub_category=m.sub_category,
            description=m.description,
            image_ref=m.image_ref,
            approx_weight_kg=m.approx_weight_kg,
            condition=m.condition.value,
            source_type=m.source_type.value,
            estimated_value=float(m.estimated_value),
            created_at=m.created_at,
            updated_at=m.updated_at,
        )
