# Data Management & Pipelines: Kabadiwala Connect

Under our non-negotiable principles:
> **Datasets are living:** implement generation, validation, cleaning, update and use pipelines, not static seed files.
> **Never invent real recycler data.** Use clearly labelled synthetic data and mark provenance (`source: synthetic|field|scraped_public`).

---

## Directory Structure

```
data/
├── raw/                         # Raw ingested observations and synthetic seed snapshots
│   └── raw_prices_latest.json
├── processed/                   # Validated, normalized, cleaned price observations
│   ├── cleaned_prices_latest.json
│   ├── rolling_board_latest.json
│   └── quality_metrics_latest.json
├── quarantine/                  # Anomalous, corrupt, or out-of-bounds records with failure reasons
│   └── quarantine_YYYYMMDD.json
├── exports/                     # Anonymized datasets for public sharing and ML model training
│   ├── anonymized_prices_latest.json
│   └── anonymized_prices_latest.csv
├── notebooks/                   # Quality profiling and interactive EDA notebooks
│   ├── data_quality_profiling.ipynb
│   └── run_profiling.py
├── schemas/                     # JSON Schemas & contracts for data models
└── synthetic/                   # Synthetic seed data generators with provenance tracking
```

---

## Dataset Lifecycle Commands

All operations strictly invoke Python 3.11 via `py -3.11`:

```bash
# 1. Seed Generation: Produce realistic price streams with noise & seasonal curves
make data-seed

# 2. Validation & Cleaning: Filter domain violations, quarantine outliers, update rolling board & dataset card
make data-validate

# 3. Export: Anonymize collector IDs (salted HMAC) and coarsen GPS (~500m) for ML
make data-export

# 4. Data Quality Profile Report:
py -3.11 data/notebooks/run_profiling.py
```

---

## Provenance & Privacy Rules

1. **Provenance Tagging:** Every record has an explicit `source` attribute:
   - `synthetic`: Generated statistically with seasonal and macroeconomic simulation.
   - `field_survey`: Verified ground price submissions.
   - `recycler_quote`: Authorized recycler rate boards.
   - `transaction`: Real completed platform handovers.
2. **Strict Data Minimization:** Zero PII is stored. No Aadhaar, personal names, phone numbers, or residential addresses.
3. **Collector Anonymization:** Collector IDs are masked with salted SHA-256 (`ANON-C-<HASH>`).
4. **Spatial Coarsening:** GPS coordinates in exports are snapped to a `0.005°` grid (~500m precision) to protect informal scrap shop locations.
