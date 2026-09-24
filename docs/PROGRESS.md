# Project Progress: Kabadiwala Connect

Living record of project deliverables, milestones completed, and pending roadmap items.

---

## Current Status: Phase 3 (FastAPI Core Backend API & Sync Engine) Complete

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
- [x] Collector Authentication: Pluggable phone+OTP (`MockOTPProvider`) and 4-digit PIN with bcrypt/argon2 hashing, zero PII collection (no Aadhaar, no names; only phone and operating area).
- [x] Portal Authentication: Recycler and admin registration/login with email + salted password hash and JWT tokens with RBAC claims (`collector`, `recycler`, `admin`).
- [x] Core CRUD Endpoints: Full CRUD for lots/transactions, materials catalog, authorized recyclers directory, price boards, and financial cash-first ledger.
- [x] Offline Idempotency: Deterministic lot generation (`KC-MH-YYMM-<HASH>`) and `client_lot_id` / `client_tx_id` indexing via `sync_queue` table preventing duplicate lot creation on client replay.
- [x] Offline Synchronization Engine:
  - `POST /api/v1/sync/push`: Batch client operations with client UUIDs and conflict logging.
  - `GET /api/v1/sync/pull?since=<cursor>`: Delta synchronization returning updated materials, prices, recyclers, safety cards, and user-scoped transactions and ledger entries.
- [x] Recycler Verification & Expiry Audit: Admin authorization approval/suspension endpoints and automated audit job (`/api/v1/recyclers/jobs/audit-expired`) flagging expired authorizations.
- [x] System Non-Functionals: Structured JSON request logging with UUID tracing, sliding-window rate limiting, and unified error response envelope.
- [x] OpenAPI & Postman Artifacts: Automated export of [openapi.json](file:///c:/dev/kabadiwala-connect/docs/openapi.json) and [postman_collection.json](file:///c:/dev/kabadiwala-connect/docs/postman_collection.json).
- [x] Automated Test Suite: 26 unit and API integration tests in `backend/tests/` passing cleanly with **96% test coverage** on `app/services` (exceeding $\ge 80\%$ requirement).
- [x] Code formatting & linting: Ruff checks and format clean across all modules using `py -3.11`.

---

## Pending Next Phase Tasks

### Phase 4: Low-Literacy Mobile Client (Flutter)
- [ ] Implement Drift DAOs and local SQLite sync queue.
- [ ] Build vernacular low-literacy UI components (56dp+ touch targets, speaker TTS button on every screen).
- [ ] Implement offline camera photo compression ($\le 200$ KB) and hash verification.
- [ ] Integrate on-device TFLite classification model for offline material identification.

### Phase 5: Recycler & Admin Portal (Next.js)
- [ ] Build Recycler dashboard (incoming lots, weight scale verification, EPR digital receipts).
- [ ] Build Admin/JNARDDC compliance & mass balance overview.
