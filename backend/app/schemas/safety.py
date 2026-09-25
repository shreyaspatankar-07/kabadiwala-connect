"""Pydantic schemas for Safety Guidance Cards and Collector Acknowledgements."""

from datetime import datetime
from typing import Any
from pydantic import BaseModel, ConfigDict, Field


class SafetyCardLocalized(BaseModel):
    """Safety instruction card formatted for a specific language."""

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Unique card ID e.g. SAFE-CABLE-01")
    topic_id: str = Field(..., description="Topic identifier e.g. cables_burn")
    category: str = Field(..., description="Target scrap category e.g. cables, CRT, batteries")
    hazard_level: str = Field(..., description="danger | warning | info")
    pictogram: str = Field(..., description="Icon identifier string")
    title: str = Field(..., description="Localized title string")
    summary: str = Field(..., description="1-line localized summary")
    instructions: list[str] = Field(..., description="3-5 step localized instructions")
    dos: list[str] = Field(..., description="Localized recommended actions")
    donts: list[str] = Field(..., description="Localized prohibited actions")
    audio_ref: str = Field(..., description="Audio asset reference path")
    category_trigger: str | None = Field(None, description="Contextual nudge category match")
    condition_trigger: str | None = Field(None, description="Contextual nudge condition match")


class SafetyCardFull(BaseModel):
    """Full multi-lingual Safety Card with all raw translation dictionaries."""

    model_config = ConfigDict(from_attributes=True)

    id: str
    topic_id: str
    category: str
    hazard_level: str
    pictogram: str
    title_vernacular: dict[str, str]
    summary_vernacular: dict[str, str]
    instructions_vernacular: dict[str, list[str]]
    dos: dict[str, list[str]]
    donts: dict[str, list[str]]
    audio_prompt_urls: dict[str, str]
    category_trigger: str | None = None
    condition_trigger: str | None = None


class SafetyAcknowledgeRequest(BaseModel):
    """Collector 'I Understood' tick acknowledgement payload."""

    collector_id: str = Field(..., description="Collector ID e.g. KC-C-7821")
    topic_id: str = Field(..., description="Safety topic ID e.g. cables_burn")
    acknowledged_at: datetime | None = Field(None, description="Client acknowledgement timestamp")


class SafetyAcknowledgeResponse(BaseModel):
    """Acknowledgement persistence confirmation."""

    success: bool = True
    topic_id: str
    collector_id: str
    acknowledged_at: datetime
    message: str = "Safety guidance acknowledgement recorded successfully"
