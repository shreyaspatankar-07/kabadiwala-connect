# Kabadiwala Connect

**Smart India Hackathon Problem Statement 26229**  
**Nodal Agency**: Ministry of Mines / Jawaharlal Nehru Aluminium Research Development and Design Centre (JNARDDC)  
**Domain**: Clean & Green Technology / Informal Sector Circular Economy  

---

## 1. Problem Summary

Over 90% of India's electronic waste is processed in the informal economy by hundreds of thousands of informal waste collectors (*kabadiwalas*) using crude, dangerous methods such as open acid leaching and wire burning. Under India's **E-Waste (Management) Rules 2022**, authorized recyclers must meet stringent Extended Producer Responsibility (EPR) recycling targets but lack direct, transparent supply chain access to this informal base. **Kabadiwala Connect** bridges this gap through a vernacular, low-literacy, offline-tolerant mobile platform and web portal. It empowers grassroots collectors with real-time fair price discovery, AI-assisted scrap classification, offline-resilient digital ledgers, and tamper-evident dual handover verification—routing e-waste safely into the formal circular economy while boosting grassroots livelihoods.

---

## 2. System Architecture

```mermaid
flowchart TB
    subgraph MobileDevice ["Mobile Collector Client (Android 8+, 2GB RAM)"]
        direction TB
        UI["Low-Literacy UI\n(56dp+ targets, Audio Speaker TTS,\nPictorial Cues, Marathi/Hindi/English)"]
        BLOC["State & Sync Manager\n(Riverpod + Network Monitor)"]
        LOCAL_DB[("Drift Local SQLite DB\n- Cached Price Board\n- Pending Lot Queue\n- Immutable Handovers\n- Cash/Credit Ledger")]
        TFLITE["On-Device TFLite\n(E-Waste Category & Grade Classifier)"]
        CAM_GPS["Camera (<200KB compressor)\n& GPS (Geolocator)"]
        
        UI --> BLOC
        BLOC <--> LOCAL_DB
        UI --> TFLITE
        UI --> CAM_GPS
    end

    subgraph SyncEngine ["Edge & Sync Layer (HTTPS / REST)"]
        SYNC_PULL["/api/v1/sync/pull\n(Delta master data, price boards, recycler registry)"]
        SYNC_PUSH["/api/v1/sync/push\n(Idempotent batch transaction upload)"]
        MEDIA_INGEST["/api/v1/lots/photos\n(Compressed photo upload + SHA256 verification)"]
    end

    subgraph BackendSystem ["Backend Platform (FastAPI + Async Workers)"]
        API_GATEWAY["FastAPI API Gateway\n(Pydantic v2 + Auth & Security)"]
        MATCH_ENGINE["Proximity & Match Engine\n(PostGIS spatial distance & recycler capacity)"]
        HANDOVER_SERVICE["Dual-Handover Verification Service\n(Tamper-proof receipt + QR verification)"]
        LEDGER_SERVICE["Audit & EPR Ledger Service\n(Cash-first + EPR Certificate Generator)"]
    end

    subgraph DataStore ["Primary Data Tier"]
        POSTGRES[("PostgreSQL 16 + PostGIS\n- Spatial Recycler Directory\n- Verified Lots & Handover Records\n- EPR Traceability & Price Master")]
        OBJECT_STORAGE[("S3 / MinIO Object Storage\n- Proof-of-handover photos\n- Audio prompt assets")]
    end

    subgraph ML_Services ["ML & Analytics Pipeline (py -3.11)"]
        PRICE_MODEL["Regional Price Prediction Engine\n(LightGBM + Commodity Trends)"]
        TRAIN_PIPELINE["Model Training & TFLite Quantization\n(Float16/INT8 for Mobile APK < 25MB)"]
    end

    subgraph Portals ["Recycler & Admin Portal (Next.js 14 + Tailwind)"]
        RECYCLER_PORTAL["Authorized Recycler Dashboard\n(Lot matching, Handover confirmation, Weight log, EPR claims)"]
        ADMIN_PORTAL["Admin & JNARDDC Oversight\n(Recycler verification, Data quality, Regional pricing, Traceability map)"]
    end

    %% Connections
    BLOC -- "Sync when online (Exponential backoff)" --> SYNC_PUSH
    SYNC_PULL -- "Delta updates" --> BLOC
    CAM_GPS --> MEDIA_INGEST
    
    SYNC_PUSH --> API_GATEWAY
    SYNC_PULL --> API_GATEWAY
    MEDIA_INGEST --> OBJECT_STORAGE
    
    API_GATEWAY --> MATCH_ENGINE
    API_GATEWAY --> HANDOVER_SERVICE
    API_GATEWAY --> LEDGER_SERVICE
    
    MATCH_ENGINE --> POSTGRES
    HANDOVER_SERVICE --> POSTGRES
    LEDGER_SERVICE --> POSTGRES
    
    PRICE_MODEL --> POSTGRES
    
    RECYCLER_PORTAL <--> API_GATEWAY
    ADMIN_PORTAL <--> API_GATEWAY
```

---

## 3. Quickstart & Setup (Under 10 Steps)

Ensure you have **Python 3.11**, **Node.js 18+**, and **Flutter 3.x** installed.

```bash
# 1. Clone the repository
git clone https://github.com/your-org/kabadiwala-connect.git
cd kabadiwala-connect

# 2. Set up Python virtual environment
py -3.11 -m venv .venv
.\.venv\Scripts\activate

# 3. Install backend & ML dependencies
pip install -r backend/requirements.txt
pip install -r ml/requirements.txt

# 4. Seed demo dataset (Recyclers, 60-day price trends, collectors, safety cards)
py -3.11 backend/app/data_pipeline/demo_seed.py

# 5. Run backend server (Runs on port 8000)
cd backend && py -3.11 -m uvicorn app.main:app --reload --port 8000 &
cd ..

# 6. Install portal dependencies & start Next.js web portal (Runs on port 3000)
cd portal && npm install && npm run dev &
cd ..

# 7. Get Flutter mobile dependencies
cd mobile && flutter pub get

# 8. Run Flutter mobile client (Chrome, Emulator, or connected Android phone)
flutter run -d chrome
```

---

## 4. Documentation Links

- **Compliance Matrix**: [docs/PS_COMPLIANCE.md](file:///c:/dev/kabadiwala-connect/docs/PS_COMPLIANCE.md)
- **Architecture**: [docs/ARCHITECTURE.md](file:///c:/dev/kabadiwala-connect/docs/ARCHITECTURE.md)
- **Unit Economics**: [docs/UNIT_ECONOMICS.md](file:///c:/dev/kabadiwala-connect/docs/UNIT_ECONOMICS.md)
- **10-Slide Pitch Outline**: [docs/PITCH_OUTLINE.md](file:///c:/dev/kabadiwala-connect/docs/PITCH_OUTLINE.md)
- **2-Minute Video Script**: [docs/VIDEO_SCRIPT.md](file:///c:/dev/kabadiwala-connect/docs/VIDEO_SCRIPT.md)
- **Performance & Footprint**: [docs/PERF.md](file:///c:/dev/kabadiwala-connect/docs/PERF.md)
- **Known Limitations**: [docs/LIMITATIONS.md](file:///c:/dev/kabadiwala-connect/docs/LIMITATIONS.md)
