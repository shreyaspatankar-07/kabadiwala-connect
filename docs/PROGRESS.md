# Project Progress: Kabadiwala Connect

Living record of project deliverables, milestones completed, and pending roadmap items.

---

## Current Status: Phase 6 (Verifiable Handover Record & Signed QR Flow) Complete

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

- [x] Offline Add Lot Flow (`/mobile/lib/ui/screens/add_lot_screen.dart`):
  - **Camera & Image Processing**: 1-4 photo capture, automatic compression to $\le 200$ KB, EXIF strip with GPS retention, and immutable SHA-256 hash calculation per photo ([image_processor.dart](file:///c:/dev/kabadiwala-connect/mobile/lib/core/hardware/image_processor.dart)).
  - **Edge TFLite Inference**: Model card documentation for MobileNetV3-Small INT8 at [ML_DATASETS.md](file:///c:/dev/kabadiwala-connect/docs/ML_DATASETS.md), packaged placeholder model asset, and on-device classifier (`MaterialClassifier`) returning top-3 predicted categories with confidence bars. Manual override always available without ML.
  - **Sub-Category & Condition Selection**: 4 condition icon chips (`ConditionChips`: working, broken, damaged, burnt) with semantic colors and high contrast, plus sub-category chips (e.g. PCB: Computer/Mobile/TV; Batteries: Li-ion/Lead-Acid; Cables: Copper/Mixed).
  - **Weight Entry & References**: Big number pad with kg/gram toggle, reference pictorial weight helper (`ReferenceWeightHelper`) displaying "this size ~ 5 kg" visual cues, and Bluetooth scale stub interface (`BluetoothScaleService` & `StubBluetoothScaleService`).
  - **Instant Value Estimate**: Instant calculation (`weight * cached_price`), min-max price range bar, large rupee display, and vernacular audio read-out ("अंदाजे सरकारी भाव सुमारे ... रुपये आहे") via persistent speaker button.
  - **Traceable Offline Save**: Deterministic offline Lot ID (`KC-MH-YYMM-<HASH>`), local Drift SQLite persistence, enqueued into `SyncQueueEntries` FIFO queue (clock icon until synced, tick icon after sync).
  - **GPS Fallback & Multi-Item Support**: Auto-capture GPS coordinates with fallback to last-known coordinates or manual district selector; full support for multiple items per lot and multiple lots per day.
  - **Automated Widget Tests**: 5 new end-to-end widget tests in `mobile/test/add_lot_flow_test.dart` covering photo capture, category selection, weight entry, value estimate display, and offline persistence with sync queue verification. All 19 mobile tests passing cleanly (`flutter test`).

- [x] Regional Price Board Feature (Backend & Mobile):
  - **Backend Price Board API (`/api/v1/prices/board`)**: District & category-aware endpoint using rolling 7d/30d median aggregation (`RollingBoardUpdater`), recency weighting, 7-day trend signal (`up`/`down`/`flat`), percentage change, confidence scoring (`high`/`medium`/`low`), and recycler-offered quote comparisons.
  - **Backend Sparkline History API (`/api/v1/prices/history`)**: 30-day historical daily median price point aggregation for sparkline rendering.
  - **Backend Price Reporting API (`/api/v1/prices/report`)**: Collector scrap price reporting endpoint with source `collector_report`, domain validation pipeline (`DataValidator`), and automated review flagging (`is_flagged_for_review`).
  - **Backend Test Suite**: 4 dedicated tests in `backend/tests/test_prices_api.py`; all 36 backend tests passing cleanly with 89% coverage on services.
  - **Mobile Price Board Screen (`/mobile/lib/ui/screens/price_board_screen.dart`)**: Tab 1 in main navigation shell featuring 7 material category cards (CRT, LCD, PCB, Cables, Batteries, Motors/Magnets, Mixed Plastics) with rates and trend chips.
  - **Category Detail View**: Large digits rate display, 7-day trend arrow with % change, lightweight zero-dependency `SparklineChart` with gradient fill, and recycler quote vs. market min-max range bar.
  - **Vernacular Audio Guidance**: Persistent speaker button reading aloud category name, price per kg, and trend direction in Marathi and Hindi ("सर्किट बोर्ड: आजचा सरकारी भाव 420 रुपये प्रति किलो आहे. भाव वाढला आहे.").
  - **Field Price Reporting & Offline Sync**: "Report a Price" modal with `BigKeypad`, local Drift cache update, and enqueuing to `SyncQueueEntries` FIFO queue.
  - **Cache Staleness Detection**: Prominent amber alert banner when cached data is older than 3 days.
  - **Mobile Test Suite**: 4 new comprehensive widget tests in `mobile/test/price_board_test.dart` covering category grid, detail view with audio playback, staleness warning banner, and offline report submission; all 23 mobile widget tests passing cleanly (`flutter test`).

- [x] Recycler Discovery & Matching Engine (Backend & Mobile):
  - **Backend Matching Core (`backend/app/matching/`)**:
    - `MatchingService.rank_recyclers(lot)` and functional `rank_recyclers(lot)` interface.
    - **Hard Filters**: Verified authorization (`authorization_status = verified` & `valid_till > today`), accepted material category, and location constraints (within `pickup_radius_km` or inside `service_area` polygon/districts).
    - **Multi-Criteria Scoring & Weights**: YAML-configurable weights (`weights.yaml`) covering normalized offered rate (0.30), inverse distance (0.25), pickup availability bonus (0.15), completion rate (0.15), confirmation speed (0.10), and recycler rating (0.05).
    - **Deterministic Tie-Breaking**: Ordered on score $\rightarrow$ offered rate $\rightarrow$ distance $\rightarrow$ rating $\rightarrow$ recycler ID.
    - **Learned Re-Ranker**: `LearnedReranker` powered by LightGBM with automated fallback to rule-based ranking when historical match interactions $< 50$ records.
    - **API Endpoints**: `POST /matching/rank` (and `/api/v1/matching/rank`) returning top-3 ranked recyclers with score, factor breakdown, distance, rate, pickup, and estimated pickup time; `GET /recyclers/nearby` (and `/api/v1/recyclers/nearby`) for distance-sorted search.
    - **Backend Test Suite**: 11 new tests in `test_matching_engine.py` and `test_matching_api.py` covering all hard filters, score ordering, tie-breaking, LightGBM fallback & training, and endpoint integration. All 47 backend tests pass (`py -3.11 -m pytest -q`).
  - **Mobile Best Buyers Screen (`mobile/lib/ui/screens/best_buyers_screen.dart`)**:
    - Accessible directly after offline lot creation or from lot details.
    - Up to 3 recycler cards displaying name, distance with map pin icon, large rate per kg, pickup (truck) vs drop-off (walking) icon, and green verified badge.
    - Ranked #1 card highlighted with a gold border and "सर्वोत्तम पर्याय / Best Choice" banner.
    - Vernacular audio read-out: "[Recycler name], [distance] किलोमीटर दूर, [rate] रुपये प्रति किलो" with automatic playback and manual speaker buttons.
    - "Select this buyer" action with haptic feedback and confirmation.
    - "No buyers found" pictorial empty state with actionable suggestions to adjust category or distance.
    - **Offline Matching Engine in Dart (`offline_matching_engine.dart`)**: Complete port of scoring rules and hard filters running against Drift `CachedRecyclers`.
    - **Shared Test Fixture (`matching_fixture.json`)**: Proves backend and Flutter matching engines generate identical scores and breakdowns down to 4 decimal places!
    - **Mobile Test Suite**: 8 new comprehensive widget and repository unit tests in `mobile/test/best_buyers_screen_test.dart`. All 31 mobile tests pass cleanly (`flutter test`) and `flutter analyze` reports 0 issues.

- [x] Verifiable Handover Record & Signed QR Flow (Backend & Mobile):
  - **Backend Handover Engine (`backend/app/services/handover_service.py` & `/backend/app/api/v1/handover.py`)**:
    - `POST /handover/initiate`: Collector submits final weight, photo hashes, GPS, timestamp, and lot ID. Generates unique 6-char alphanumeric uppercase `handover_ref_no` (excluding ambiguous characters: `0`, `O`, `1`, `I`), constructs sorted JSON payload, and generates server HMAC-SHA256 signature. Inserts initial `Traceability` record with base hash and transitions lot status to `handover_pending`.
    - `POST /handover/confirm`: Recycler scans QR or enters 6-char code, submits measured weight and final price. Verifies cryptographic HMAC-SHA256 signature, enforces configurable weight mismatch tolerance (`HANDOVER_WEIGHT_TOLERANCE_PERCENT = 10%`), appends immutable SHA-256 hash chain (`record_hash = SHA256(payload:prev_hash:weight:price:recycler:time)`), transitions transaction status to `handed_over` (or `disputed` if mismatch $> 10\%$), creates financial credit entry in collector ledger, and marks recycler confirmation.
    - `POST /handover/{lot_id}/downstream`: Recycler updates processing lifecycle status (`received` $\rightarrow$ `dismantled` $\rightarrow$ `processed` $\rightarrow$ `certificate_issued`).
    - `GET /verify/{handover_ref_no}`: Public verification endpoint requiring zero authentication; returns tamper-evident cryptographic validity status, collector weight, category, confirmation timestamp, recycler name, and downstream processing stage.
    - **Security Test Suite (`backend/tests/test_handover_api.py`)**: 5 comprehensive security tests covering happy path lifecycle, tampered QR payload detection (HTTP 400), forged HMAC signature rejection (HTTP 400), replay attack prevention on already confirmed handovers (HTTP 409), and weight mismatch $> 10\%$ dispute flagging. All 52 backend tests pass (`py -3.11 -m pytest -q`).
  - **Mobile Handover & QR Flow (`mobile/lib/core/handover/` & `mobile/lib/ui/`)**:
    - `OfflineHandoverService`: Client-side cryptographic HMAC-SHA256 signing, sorted canonical serialization, 6-character short code generator, local Drift `LocalTraceability` persistence, and background synchronization via `SyncQueueEntries` FIFO queue.
    - `HandoverInitiateScreen`: Triggered from lot detail when status is `matched`. Allows entering final weight via `BigKeypad`, shows summary card (lot ID, weight, estimated value, recycler name), displays full-screen QR code (`qr_flutter`), and prominent 6-character short code badge below QR for manual entry.
    - `RecyclerConfirmScreen`: Recycler enters 6-char code or scans QR, enters measured weight and price; dynamically displays live weight mismatch warning banner (`Key('weight_mismatch_warning')`) if weight differs by $> 10\%$, and transitions transaction to `handed_over` or `disputed`.
    - `HandoverReceiptCard`: High-contrast digital receipt card rendering QR code, spaced 6-character short code, lot ID, material category, final weight, authorized recycler name, and timestamp. Captures to PNG via `RepaintBoundary` and triggers Android share sheet.
    - `DownstreamTimelineWidget`: 4-step pictorial progression timeline (`received` $\rightarrow$ `dismantled` $\rightarrow$ `processed` $\rightarrow$ `certificate_issued`) with green checkmarks, active status rings, and vernacular labels.
    - `VerifyHandoverScreen`: Public in-app verification screen allowing anyone to enter a 6-character reference code, displaying cryptographic integrity status badge, weight, recycler confirmation status, and embedded downstream timeline.
    - **Mobile Test Suite (`mobile/test/handover_flow_test.dart`)**: 6 comprehensive widget tests covering QR display, 6-char code rendering, offline cryptographic HMAC-SHA256 signature verification, live weight mismatch warning banner, receipt sharing callback, and downstream timeline progression. All 37 mobile tests pass cleanly (`flutter test`) and `flutter analyze` reports 0 issues.

---

## Pending Next Phase Tasks

### Phase 7: Recycler & Admin Portal (Next.js)
- [ ] Build Recycler dashboard (incoming lots, weight scale verification, EPR digital receipts).
- [ ] Build Admin/JNARDDC compliance & mass balance overview.

