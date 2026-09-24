# Project Progress: Kabadiwala Connect

Living record of project deliverables, milestones completed, and pending roadmap items.

---

## Current Status: Phase 1 (Scaffolding & Architecture)

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
- [x] Code quality checks: Ruff linter & Pytest passing across `/backend` and `/ml` using `py -3.11`.

---

## Pending Next Phase Tasks

### Phase 2: Core Data Tier & Schemas
- [ ] Initialize Alembic migrations for PostgreSQL + PostGIS schema.
- [ ] Create synthetic data generator with strict provenance tracking (`source: synthetic`).
- [ ] Configure Drift SQLite schema & migrations in Flutter client.

### Phase 3: Backend & API Services
- [ ] Implement JWT / OTP authentication service.
- [ ] Implement `/sync/push` and `/sync/pull` delta engines.
- [ ] Implement spatial PostGIS proximity matcher for authorized recyclers.
- [ ] Implement dual-handover verification with SHA-256 tamper-proof ledger.

### Phase 4: Low-Literacy Mobile Client (Flutter)
- [ ] Implement Drift DAOs and local SQLite sync queue.
- [ ] Build vernacular low-literacy UI components (56dp+ buttons, speaker TTS button on all screens).
- [ ] Implement offline camera photo compression ($\le 200$ KB).
- [ ] Integrate TFLite classification model.

### Phase 5: Recycler & Admin Portal (Next.js)
- [ ] Build Recycler dashboard (incoming lots, weight scale verification, EPR receipts).
- [ ] Build Admin/JNARDDC compliance & mass balance overview.
