# Project Progress: Kabadiwala Connect

Living record of project deliverables, milestones completed, and pending roadmap items.

---

## Current Status: Phase 4 (Mobile Collector App Shell) Complete

### Completed Items
- [x] Review of SIH PS 26229 requirements & non-negotiable principles.
- [x] Environment audit: Verified `Flutter 3.47.5`, `Python 3.11.9 (py -3.11)`, `Node.js 24.11.1`, and `Docker 29.8.0`.
- [x] Enforced `py -3.11` across all tooling and configuration files.
- [x] Architecture Documentation ([ARCHITECTURE.md](file:///c:/dev/kabadiwala-connect/docs/ARCHITECTURE.md)) with Mermaid component diagram.
- [x] Offline-First Strategy ([OFFLINE_STRATEGY.md](file:///c:/dev/kabadiwala-connect/docs/OFFLINE_STRATEGY.md)) detailing local-first data flow, conflict resolution, backoff retry, and low-literacy icon cues.
- [x] OpenAPI 3.1 API Specification ([API_SPEC.md](file:///c:/dev/kabadiwala-connect/docs/API_SPEC.md)) covering auth, lots, prices, recyclers, matching, handover, ledger, sync/push, sync/pull, safety, and analytics.
- [x] Monorepo Directory Layout: `/mobile`, `/backend`, `/portal`, `/ml`, `/data`, `/docs`.
- [x] Docker Orchestration: `docker-compose.yml` with PostgreSQL 16 + PostGIS, Backend FastAPI, and Portal Next.js.
- [x] Root `Makefile` targeting `py -3.11` and CI workflows (`.github/workflows/ci.yml`).
- [x] Synthetic data generator pipeline with provenance tracking (`data/synthetic/generate_synthetic_data.py`).
- [x] Comprehensive Data Dictionary ([DATA_DICTIONARY.md](file:///c:/dev/kabadiwala-connect/docs/DATA_DICTIONARY.md)) with Mermaid ER diagram.
- [x] PostgreSQL 16 + PostGIS Schema & SQLAlchemy ORM models ([schema.py](file:///c:/dev/kabadiwala-connect/backend/app/models/schema.py)) covering all 10 core entities with spatial GiST indexes, check constraints, and audit timestamps.
- [x] Alembic Migrations ([0001_initial_schema.py](file:///c:/dev/kabadiwala-connect/backend/alembic/versions/0001_initial_schema.py)) with PostGIS extension activation and full upgrade/downgrade paths.
- [x] Matching Drift (SQLite) Tables on Mobile ([tables.dart](file:///c:/dev/kabadiwala-connect/mobile/lib/data/tables.dart) & [local_database.dart](file:///c:/dev/kabadiwala-connect/mobile/lib/data/local_database.dart)) covering the offline-first subset.
- [x] Collector Authentication: Pluggable phone+OTP (`MockOTPProvider`) and 4-digit PIN with bcrypt hashing, zero PII collection.
- [x] Portal Authentication: Recycler and admin registration/login with email + salted password hash and JWT tokens with RBAC claims (`collector`, `recycler`, `admin`).
- [x] Core CRUD Endpoints: Full CRUD for lots/transactions, materials catalog, authorized recyclers directory, price boards, and financial cash-first ledger.
- [x] Offline Idempotency: Deterministic lot generation (`KC-MH-YYMM-<HASH>`) and `client_lot_id` / `client_tx_id` indexing via `sync_queue` table preventing duplicate lot creation on client replay.
- [x] Offline Synchronization Engine:
  - `POST /api/v1/sync/push`: Batch client operations with client UUIDs and conflict logging.
  - `GET /api/v1/sync/pull?since=<cursor>`: Delta synchronization returning updated materials, prices, recyclers, safety cards, and user-scoped transactions and ledger entries.
- [x] Recycler Verification & Expiry Audit: Admin authorization approval/suspension endpoints and automated audit job (`/api/v1/recyclers/jobs/audit-expired`) flagging expired authorizations.
- [x] System Non-Functionals: Structured JSON request logging with UUID tracing, sliding-window rate limiting, and unified error response envelope.
- [x] OpenAPI & Postman Artifacts: Automated export of [openapi.json](file:///c:/dev/kabadiwala-connect/docs/openapi.json) and [postman_collection.json](file:///c:/dev/kabadiwala-connect/docs/postman_collection.json).
- [x] Living Dataset Lifecycle Pipeline (`/backend/app/data_pipeline` and `/data`):
  - **Generation:** Realistic synthetic price stream generator for Maharashtra districts (Palghar, Thane, Mumbai, Pune, Nashik, Nagpur) for all 10 PS categories with seasonal noise, commodity trends, and injected outliers, plus real DB ingestion.
  - **Validation:** Multi-rule validation engine (positivity, unit sanity, geo-fence, weight sanity bounds, duplicate check, future timestamp rejection) with date-partitioned quarantine routing (`/data/quarantine/`).
  - **Cleaning:** IQR + MAD Robust Z-score outlier detection, unit normalization to per-kg INR rates, and missing value imputation policies.
  - **Anonymization:** Salted HMAC-SHA256 collector ID hashing and ~500m GPS spatial coarsening (`0.005°` resolution).
  - **Updating:** Rolling 7-day and 30-day median price board engine with recency-weighted recycler quotes, trend direction (`up`/`down`/`flat`), and data health scoring (91.7/100).
  - **Documentation:** Automated living [DATASET_CARD.md](file:///c:/dev/kabadiwala-connect/docs/DATASET_CARD.md) generator.
  - **CLI & Makefile Integration:** `make data-seed`, `make data-validate`, `make data-export` invoking `py -3.11`.
  - **Data Quality Profiling:** Jupyter notebook ([data_quality_profiling.ipynb](file:///c:/dev/kabadiwala-connect/data/notebooks/data_quality_profiling.ipynb)) and terminal runner script ([run_profiling.py](file:///c:/dev/kabadiwala-connect/data/notebooks/run_profiling.py)).
- [x] Backend Automated Test Suite: 33 unit and API integration tests in `backend/tests/` passing cleanly with **83% overall coverage** and **96% test coverage** on `app/services` (exceeding $\ge 80\%$ requirement).
- [x] Mobile Collector App Shell (`/mobile`):
  - **Offline-First Persistence**: Drift SQLite database (`local_database.dart`), repositories (`lot_repository.dart`, `price_repository.dart`, `ledger_repository.dart`), and background sync engine (`sync_engine.dart`) with `connectivity_plus` listener, exponential backoff, and FIFO queue.
  - **Low-Literacy Design System**: `AppTheme` with min 56dp touch targets, semantic colors (Green = Go/Earn `#047857`, Red = Danger `#DC2626`, Yellow = Pending `#D97706`), tactile haptic feedback (`HapticService`), and persistent speaker button on every screen (`SpeakerButton`).
  - **Vernacular i18n & Audio Feedback**: 100% complete Marathi (`app_mr.arb`), Hindi (`app_hi.arb`), and English (`app_en.arb`) with zero English fallback in vernacular files. Keyed audio transcript and asset mapping (`audio_map.dart`) with `AudioFeedbackService`.
  - **First-Run Onboarding Flow**: `LanguageSelectionScreen` with auto-playing audio prompt and big selection tiles; single-field `PinSetupScreen` with 72dp keypad and audio verification.
  - **Bottom Navigation Shell**: 4 icon tabs (`MainNavigationShell`): Add Lot, Price Board, Earnings, Safety, with top sync status badge (`SyncStatusBadge`).
  - **Small APK Target & Performance**: R8 shrinking, resource shrinking, split-per-ABI configured in `build.gradle.kts`, ProGuard rules in `proguard-rules.pro`, and comprehensive size budget documented in [PERF.md](file:///c:/dev/kabadiwala-connect/docs/PERF.md) (~14.9 MB per ABI vs < 25 MB budget).
  - **Mobile Test Suite**: 14/14 automated widget and repository unit tests passing cleanly in `mobile/test/`.

---

## Pending Next Phase Tasks

### Phase 5: Hardware & ML Integration on Mobile
- [ ] Implement camera photo compression ($\le 200$ KB) and SHA-256 hash calculation.
- [ ] On-device TFLite classification model integration for e-waste category inference.
- [ ] QR code generation for tamper-evident dual-handover audit trail.

### Phase 6: Recycler & Admin Portal (Next.js)
- [ ] Build Recycler dashboard (incoming lots, weight scale verification, EPR digital receipts).
- [ ] Build Admin/JNARDDC compliance & mass balance overview.
