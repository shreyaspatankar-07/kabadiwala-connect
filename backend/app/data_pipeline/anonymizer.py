"""Anonymization and Privacy-Preserving Transformation Engine.

Applies:
1. Salted cryptographic hashing for Collector IDs.
2. Spatial grid coarsening of GPS coordinates to ~500m precision to prevent
   scrap worker/kabadiwala location profiling in analytics and ML datasets.
"""

import hashlib
from collections.abc import Sequence

from app.data_pipeline.schemas import AnonymizedObservation, CleanedPriceObservation

# Grid step size for ~500m resolution (~0.0045° latitude, ~0.0048° longitude in Maharashtra)
COARSENING_GRID_STEP = 0.005
DEFAULT_SALT = "kabadiwala-connect-privacy-salt-2026"


class DataAnonymizer:
    """Transforms cleaned records into privacy-compliant datasets safe for
    ML training and research.
    """

    def __init__(self, salt: str = DEFAULT_SALT, grid_step: float = COARSENING_GRID_STEP) -> None:
        self.salt = salt
        self.grid_step = grid_step

    def hash_collector_id(self, collector_id: str | None) -> str | None:
        """Computes a one-way deterministic salted hash of the collector identifier."""
        if not collector_id:
            return None
        digest = hashlib.sha256(f"{self.salt}:{collector_id}".encode()).hexdigest()[:12].upper()
        return f"ANON-C-{digest}"

    def coarsen_coordinates(self, lat: float, lng: float) -> tuple[float, float]:
        """Snaps exact latitude and longitude to a ~500m spatial grid."""
        coarsened_lat = round(round(lat / self.grid_step) * self.grid_step, 4)
        coarsened_lng = round(round(lng / self.grid_step) * self.grid_step, 4)
        return coarsened_lat, coarsened_lng

    def anonymize_single(self, record: CleanedPriceObservation) -> AnonymizedObservation:
        """Anonymizes a single cleaned price observation."""
        coarse_lat, coarse_lng = self.coarsen_coordinates(record.latitude, record.longitude)
        anon_collector = self.hash_collector_id(record.collector_id)

        return AnonymizedObservation(
            observation_id=record.observation_id,
            category=record.category,
            sub_category=record.sub_category,
            district=record.district,
            city=record.city,
            coarsened_latitude=coarse_lat,
            coarsened_longitude=coarse_lng,
            normalized_price_per_kg=record.normalized_price_per_kg,
            weight_kg=record.weight_kg,
            anonymized_collector_id=anon_collector,
            recycler_id=record.recycler_id,
            source=record.source,
            recorded_at=record.recorded_at,
        )

    def anonymize_batch(
        self, records: Sequence[CleanedPriceObservation]
    ) -> list[AnonymizedObservation]:
        """Anonymizes a collection of cleaned price records."""
        return [self.anonymize_single(r) for r in records]
