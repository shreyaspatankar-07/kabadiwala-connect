# Data Management & Pipelines: Kabadiwala Connect

Under our non-negotiable principles:
> **Datasets are living:** implement generation, validation, cleaning, update and use pipelines, not static seed files.
> **Never invent real recycler data.** Use clearly labelled synthetic data and mark provenance (`source: synthetic|field|scraped_public`).

---

## Directory Structure

```
data/
├── pipelines/               # Continuous validation, cleaning, and ETL pipelines
├── schemas/                 # JSON Schemas & Pydantic contracts for lots, prices, recyclers
│   └── lot_schema.json      # JSON Schema for e-waste lot submissions
└── synthetic/               # Synthetic data generators with provenance tracking
    └── generate_synthetic_data.py
```

## Provenance Rules
Every synthetic dataset record must contain metadata fields:
1. `source`: Must be `"synthetic"`, `"field"`, or `"scraped_public"`.
2. `generated_at`: ISO 8601 UTC timestamp.
3. `generator_version`: Semantic version of the generator script.
