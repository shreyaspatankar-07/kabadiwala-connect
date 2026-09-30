# Kabadiwala Connect (कबाडीवाला कनेक्ट)

[![Smart India Hackathon 2026](https://img.shields.io/badge/SIH-2026-orange.svg?style=flat-square)](https://www.sih.gov.in/)
[![Problem Statement](https://img.shields.io/badge/Problem%20Statement-SIH26195%20%2F%2026229-blue.svg?style=flat-square)](https://www.sih.gov.in/)
[![Ministry](https://img.shields.io/badge/Nodal%20Agency-Ministry%20of%20Mines%20%2F%20JNARDDC-green.svg?style=flat-square)](https://mines.gov.in/)
[![Team](https://img.shields.io/badge/Team-Code200%20(ID%20167095)-purple.svg?style=flat-square)](https://github.com/shreyaspatankar-07/kabadiwala-connect)
[![Demo Video](https://img.shields.io/badge/YouTube-Watch%20Demo-red.svg?style=flat-square&logo=youtube)](https://youtu.be/Tf_xmor3dog)

> **Bringing Informal E-Waste Collectors into India's Formal Circular Economy.**  
> A vernacular, low-literacy, offline-tolerant edge-to-cloud distributed platform connecting grassroots scrap collectors (*kabadiwalas*) directly with SPCB/CPCB-authorized recyclers under the **E-Waste (Management) Rules 2022** and the **National Critical Minerals Mission**.

---

## 📌 Executive Pitch & Key Resources

| Resource | Description | Direct Link |
| :--- | :--- | :--- |
| 🎥 **Working Demo Video** | Live 2-minute walkthrough of the offline edge app, on-device AI & dual-handover | [Watch on YouTube](https://youtu.be/Tf_xmor3dog) |
| 📄 **Research Paper** | Complete IEEE-format 6-page system architecture paper | [docs/KABADIWALA_CONNECT_SYSTEM_REPORT.md](docs/KABADIWALA_CONNECT_SYSTEM_REPORT.md) |
| 📋 **20-Collector Field Study** | Empirical field research, usability testing & interaction guide across 6 districts | [docs/FIELD_RESEARCH/](docs/FIELD_RESEARCH/) & [docs/FIELD_RESEARCH/INTERVIEW_GUIDE.md](docs/FIELD_RESEARCH/INTERVIEW_GUIDE.md) |
| 📊 **Unit Economics Model** | Financial analysis validating +19.5% daily net margin (+₹2,184/mo) | [docs/UNIT_ECONOMICS.md](docs/UNIT_ECONOMICS.md) |
| 🎯 **PS Compliance Matrix** | Line-by-line verification against SIH26195 / 26229 requirements | [docs/PS_COMPLIANCE.md](docs/PS_COMPLIANCE.md) |

---

## 📊 Proven Impact & Key Benchmarks

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┬─────────────────────────┐
│        +80 pp           │          -80%           │         +19.5%          │         < 5 MB          │
│     Task Completion     │    Lot Creation Time    │     Daily Net Margin    │    On-Device AI Model   │
│  (Illiterate: 15%→95%)  │     (240s → 48s)        │     (₹430 → ₹514)       │     (INT8 Quantized)    │
└─────────────────────────┴─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

- **Stops Aggregator Exploitation**: Prevents 20–30% value loss with transparent, live commodity-linked price boards and real-time pictorial currency visualizer.
- **Zero-Literacy UX**: Icon-first layout, minimum 56dp touch targets, max 1 primary action per screen, full vernacular voice narration in Marathi (default) and Hindi.
- **100% Offline-Tolerant**: Every core collector action (create lot, get price, sign receipt, record handover) runs with zero cellular connectivity in dense scrap compounds using Drift (SQLite WAL mode).
- **Zero-Aadhaar Privacy**: Accessible via phone OTP or 4-digit PIN only with device-bound Ed25519 Keystore cryptography—protecting marginalized workers.
- **Verifiable Chain of Custody**: Cryptographic dual-handover (6-character Base32 matching code + SHA-256 photo hash + dynamic QR) feeding an append-only EPR mass-balance ledger for SPCB/CPCB compliance.
- **Critical Minerals Safeguard**: Captures and routes batteries, PCBs, and CRT units safely to authorized hydrometallurgical facilities (recovering Lithium, Cobalt, and Rare Earth Elements).

---

## 🏛️ System Architecture

```mermaid
flowchart TB
    subgraph MobileDevice ["Mobile Collector Client (Android 8+, 2GB RAM)"]
        direction TB
        UI["Low-Literacy UI\n(56dp+ targets, Audio Speaker TTS,\nPictorial Cues, Marathi/Hindi)"]
        BLOC["State & Sync Manager\n(Riverpod + Jittered Exponential Backoff)"]
        LOCAL_DB[("Drift Local SQLite DB\n- Cached Price Board\n- Pending Lot Queue\n- Immutable Handovers\n- Cash/Credit Ledger")]
        TFLITE["On-Device TFLite\n(MobileNetV3-Small INT8 <5MB)"]
        CAM_GPS["Camera (<200KB compressor)\n& GPS / Bluetooth Scale"]
        
        UI --> BLOC
        BLOC <--> LOCAL_DB
        UI --> TFLITE
        UI --> CAM_GPS
    end

    subgraph SyncEngine ["Edge & Sync Layer (HTTPS / REST)"]
        SYNC_PULL["/api/v1/sync/pull\n(Delta master data, price boards, recycler registry)"]
        SYNC_PUSH["/api/v1/sync/push\n(Idempotent batch transaction upload, UUIDv4 keys)"]
        MEDIA_INGEST["/api/v1/lots/photos\n(Compressed photo upload + SHA256 verification)"]
    end

    subgraph BackendSystem ["Backend Platform (FastAPI + Async Workers)"]
        API_GATEWAY["FastAPI API Gateway\n(Pydantic v2 + Auth & Security)"]
        MATCH_ENGINE["Proximity & Match Engine\n(PostGIS spatial distance & recycler capacity)"]
        HANDOVER_SERVICE["Dual-Handover Verification Service\n(Tamper-proof receipt + QR verification)"]
        LEDGER_SERVICE["Audit & EPR Ledger Service\n(Cash-first + EPR Certificate Generator)"]
        ANOMALY_DETECTOR["Isolation Forest Anomaly Detector\n(Weight & density tamper screening)"]
    end

    subgraph DataStore ["Primary Data Tier"]
        POSTGRES[("PostgreSQL 15 + PostGIS\n- Spatial Recycler Directory\n- Verified Lots & Handover Records\n- EPR Traceability & Price Master")]
        OBJECT_STORAGE[("S3 / MinIO Object Storage\n- Proof-of-handover photos\n- Audio prompt assets")]
    end

    subgraph ML_Services ["ML & Analytics Pipeline (py -3.11)"]
        PRICE_MODEL["Regional Price Prediction Engine\n(LightGBM Regressor R²=0.999)"]
        TRAIN_PIPELINE["Model Training & TFLite Quantization\n(Post-training static INT8 quantization)"]
    end

    subgraph Portals ["Recycler & Admin Portal (Next.js 14 + Tailwind)"]
        RECYCLER_PORTAL["Authorized Recycler Dashboard\n(Lot matching, Handover confirmation, Weight log, EPR claims)"]
        ADMIN_PORTAL["Admin & JNARDDC Oversight\n(Recycler verification, Data quality, Regional pricing, Traceability map)"]
    end

    %% Connections
    BLOC -- "Idempotent Sync (when online)" --> SYNC_PUSH
    SYNC_PULL -- "Delta updates" --> BLOC
    CAM_GPS --> MEDIA_INGEST
    
    SYNC_PUSH --> API_GATEWAY
    SYNC_PULL --> API_GATEWAY
    MEDIA_INGEST --> OBJECT_STORAGE
    
    API_GATEWAY --> MATCH_ENGINE
    API_GATEWAY --> HANDOVER_SERVICE
    API_GATEWAY --> LEDGER_SERVICE
    API_GATEWAY --> ANOMALY_DETECTOR
    
    MATCH_ENGINE --> POSTGRES
    HANDOVER_SERVICE --> POSTGRES
    LEDGER_SERVICE --> POSTGRES
    ANOMALY_DETECTOR --> POSTGRES
    
    PRICE_MODEL --> POSTGRES
    
    RECYCLER_PORTAL <--> API_GATEWAY
    ADMIN_PORTAL <--> API_GATEWAY
```

---

## ⚡ Quickstart & Local Setup

Ensure you have **Python 3.11** (`py -3.11`), **Node.js 18+**, and **Flutter 3.x** installed.

```bash
# 1. Clone repository
git clone https://github.com/shreyaspatankar-07/kabadiwala-connect.git
cd kabadiwala-connect

# 2. Set up Python virtual environment
py -3.11 -m venv .venv
.\.venv\Scripts\activate   # On Linux/macOS: source .venv/bin/activate

# 3. Install backend & ML dependencies
pip install -r backend/requirements.txt
pip install -r ml/requirements.txt

# 4. Seed demo dataset (Recyclers, 60-day price trends, collectors, safety cards)
py -3.11 backend/app/data_pipeline/demo_seed.py

# 5. Run backend server (Port 8000)
cd backend && py -3.11 -m uvicorn app.main:app --reload --port 8000
# (Open a new terminal for next steps)

# 6. Run Next.js Recycler & Admin Portal (Port 3000)
cd portal && npm install && npm run dev

# 7. Run Flutter Mobile App (Edge Client)
cd mobile && flutter pub get
flutter run -d chrome    # Or target an Android device/emulator
```

---

## 📁 Repository Structure

```
kabadiwala-connect/
├── mobile/                   # Flutter Edge Android App (Offline-first, Riverpod, Drift)
│   ├── lib/core/             # Audio engine, Bluetooth scales, Haptics, Keystore
│   ├── lib/data/sync/        # Idempotent offline sync engine with jitter backoff
│   └── lib/ui/               # Icon-first screens, Devanagari keypad, banknote visualizer
├── backend/                  # FastAPI 0.110+ ASGI gateway & data pipeline
│   ├── app/data_pipeline/    # Synthetic generator, cleaner, anonymizer, updater
│   └── app/routers/          # Lots, sync, handovers, pricing, recyclers
├── portal/                   # Next.js 14 App Router, TypeScript & Tailwind CSS portal
├── ml/                       # LightGBM pricing, TFLite MobileNetV3-Small INT8, Isolation Forest
├── data/                     # Scraped public commodity datasets & verified seed lots
└── docs/                     # Research papers, field guides, specs & compliance records
    ├── FIELD_RESEARCH/       # 20-collector interview guide & usability testing kits
    ├── KABADIWALA_CONNECT_SYSTEM_REPORT.md  # Full academic system paper
    ├── UNIT_ECONOMICS.md     # Financial margin uplift models
    ├── OFFLINE_STRATEGY.md   # Distributed sync state machine spec
    └── PS_COMPLIANCE.md      # SIH problem statement requirements matrix
```

---

## 🛡️ Non-Negotiable Engineering Principles

1. **Offline-First & Idempotent**: No user-visible action blocks on the network. Every mutation is queued in Drift SQLite with a UUIDv4 idempotency key.
2. **Low-Literacy First**: Zero text-dependent navigation. Big touch targets (≥56dp), audio speaker on every screen, Devanagari numerals (`०–९`), and pictorial rupee notes.
3. **Strict Privacy**: Zero biometric or Aadhaar collection. Identity backed by device hardware keystore (Ed25519) and 4-digit PIN.
4. **Living Datasets**: Continuous validation, synthetic-to-field tagging, and anomaly screening using Isolation Forests.
5. **Dignified Cash-First Ledger**: Full support for `cash_received`, creating verified earnings history to unlock micro-finance eligibility.

---

## 👥 Team Code200 (Smart India Hackathon 2026)

- **Problem Statement ID**: SIH26195 / 26229
- **Nodal Agency**: Ministry of Mines / JNARDDC
- **Demo Video**: [https://youtu.be/Tf_xmor3dog](https://youtu.be/Tf_xmor3dog)
- **Repository**: [https://github.com/shreyaspatankar-07/kabadiwala-connect](https://github.com/shreyaspatankar-07/kabadiwala-connect)

*Built with passion to bring India's invisible environmental champions into a dignified, formal circular economy.*
