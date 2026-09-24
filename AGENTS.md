You are building "Kabadiwala Connect", a solution for Smart India Hackathon problem
statement 26229 (Ministry of Mines / JNARDDC): a vernacular, low-literacy,
offline-tolerant Android platform connecting informal e-waste collectors (kabadiwalas)
with authorized recyclers under India's E-Waste (Management) Rules 2022.

USERS

- Collector: low literacy, entry-level Android (2GB RAM, Android 8+), patchy
  connectivity, speaks Marathi/Hindi, works in cash.
- Recycler/aggregator: authorized under EPR, uses a simple web portal.
- Admin: verifies recyclers, monitors data quality, views analytics.

NON-NEGOTIABLE PRINCIPLES

1. Offline-first: every core collector action (create lot, get estimate, view price
   board, generate handover record, view ledger) works with zero connectivity and
   syncs later.
2. Low-literacy UX: icon-first, big touch targets (min 56dp), max 1 primary action per
   screen, every screen has a speaker button that reads it aloud, numbers shown with
   pictorial cues, minimal typing.
3. Languages: Marathi (default) and Hindi at minimum, English optional. All strings in
   ARB/i18n files, zero hardcoded text. Design so a new language = one new file.
4. Small and light: target APK < 25 MB, cold start < 3 s on 2GB device, no heavy
   dependencies. Compress images to <= 200 KB before storage.
5. Cash-first: digital payment is optional and never a prerequisite. Payment status
   can be "cash_received", "pending", "digital_paid".
6. Data minimization: no Aadhaar, no name required. Collector ID is a generated ID
   plus phone-number OTP or PIN-only. Store only what the PS lists.
7. Traceability: every lot has a unique reference ID and an immutable handover record
   (photo hashes, weight, timestamp, GPS, recycler confirmation).
8. Datasets are living: implement generation, validation, cleaning, update and use
   pipelines, not static seed files.

STACK

- Mobile: Flutter, Drift (SQLite), Riverpod, TFLite, geolocator, camera.
- Backend: FastAPI, PostgreSQL + PostGIS, SQLAlchemy, Alembic, Pydantic.
- Recycler/Admin portal: Next.js + Tailwind + TypeScript.
- ML: Python 3.11 (`py -3.11`), scikit-learn, LightGBM, TensorFlow/Keras -> TFLite.
- Monorepo layout: /mobile, /backend, /portal, /ml, /data, /docs.

WORKING RULES

- For all Python commands, always use `py -3.11` instead of `python` or `python3` (e.g. `py -3.11 -m venv .venv`, scripts, Makefiles).
- Write tests for every module. Keep functions small and typed.
- After every task: run tests, update /docs/PROGRESS.md, list what is done/pending.
- Never invent real recycler data. Use clearly labelled synthetic data and mark
  provenance (source: synthetic|field|scraped_public).
- Ask me before adding any dependency over 2 MB to the mobile app.
