"""Pydantic schemas for Materials catalog."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class MaterialCreate(BaseModel):
    category: str = Field(..., max_length=50)
    sub_category: str = Field(..., max_length=50)
    description: str
    image_ref: str | None = None
    approx_weight_kg: float = Field(..., gt=0)
    condition: str = Field("broken", pattern=r"^(working|broken|damaged|burnt)$")
    source_type: str = Field("household", pattern=r"^(household|office|shop|repair_unit|other)$")
    estimated_value: float = Field(..., ge=0)


class MaterialUpdate(BaseModel):
    description: str | None = None
    approx_weight_kg: float | None = Field(None, gt=0)
    condition: str | None = Field(None, pattern=r"^(working|broken|damaged|burnt)$")
    source_type: str | None = Field(None, pattern=r"^(household|office|shop|repair_unit|other)$")
    estimated_value: float | None = Field(None, ge=0)


class MaterialResponse(BaseModel):
    id: uuid.UUID
    category: str
    sub_category: str
    description: str
    image_ref: str | None
    approx_weight_kg: float
    condition: str
    source_type: str
    estimated_value: float
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
