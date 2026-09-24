# OpenAPI 3.1 Specification Outline: Kabadiwala Connect

**Base URL:** `https://api.kabadiwala-connect.in/api/v1`  
**Protocol:** HTTPS  
**Authentication:** Bearer JWT (`Authorization: Bearer <token>`)

---

## 1. Authentication (`/auth`)

Collector authentication minimizes data collection: no Aadhaar, no full legal names required. Collectors authenticate via generated Collector ID + OTP or 4-digit PIN.

### `POST /auth/otp/request`
- **Description:** Request an SMS OTP for collector login or initial registration.
- **Request Body:**
  ```json
  {
    "phone": "+919876543210",
    "language_preference": "mr"
  }
  ```
- **Response 200 OK:**
  ```json
  {
    "status": "otp_sent",
    "retry_after_seconds": 60,
    "mock_otp": "123456" // Returned only in non-production/demo mode
  }
  ```

### `POST /auth/otp/verify`
- **Description:** Verify OTP and receive JWT access token.
- **Request Body:**
  ```json
  {
    "phone": "+919876543210",
    "otp": "123456"
  }
  ```
- **Response 200 OK:**
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "collector_id": "KC-C-7821",
    "role": "collector",
    "has_pin": false
  }
  ```

### `POST /auth/pin/setup`
- **Description:** Set up a quick 4-digit PIN for offline/fast device unlock.
- **Request Body:**
  ```json
  {
    "pin": "1234"
  }
  ```
- **Response 200 OK:** `{"status": "pin_set"}`

---

## 2. E-Waste Lots Management (`/lots`)

### `POST /lots`
- **Description:** Create or upload an e-waste lot (accepts offline-generated `client_lot_id`).
- **Request Body:**
  ```json
  {
    "client_lot_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    "category": "pcb_grade_a",
    "estimated_weight_kg": 15.5,
    "created_at_utc": "2026-09-24T18:30:00Z",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "photo_hashes": ["e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"]
  }
  ```
- **Response 201 Created:**
  ```json
  {
    "lot_id": "KAB-202609-8F2A",
    "client_lot_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    "status": "listed",
    "estimated_value_inr": 2325.00
  }
  ```

### `GET /lots/{lot_id}`
- **Description:** Retrieve lot details, current status, and handover progress.

### `POST /lots/{lot_id}/photos`
- **Description:** Upload compressed photo proof ($\le 200$ KB) with SHA256 verification.
- **Request:** Multipart form with file content and sha256 checksum header.

---

## 3. Benchmark Pricing Engine (`/prices`)

### `GET /prices/board`
- **Description:** Retrieve the current authorized e-waste price benchmarks with vernacular descriptions.
- **Query Params:** `region=MH_MUMBAI&language=mr`
- **Response 200 OK:**
  ```json
  {
    "valid_until": "2026-09-25T18:29:59Z",
    "region": "MH_MUMBAI",
    "categories": [
      {
        "code": "pcb_grade_a",
        "name_vernacular": "चांगल्या प्रतीचे संगणक बोर्ड (PCB A)",
        "unit": "kg",
        "min_rate_inr": 140.0,
        "max_rate_inr": 165.0,
        "pictogram_url": "/assets/icons/pcb_a.webp"
      },
      {
        "code": "lithium_ion_battery",
        "name_vernacular": "मोबाईल व लॅपटॉप बॅटरी (Li-ion)",
        "unit": "kg",
        "min_rate_inr": 180.0,
        "max_rate_inr": 220.0,
        "pictogram_url": "/assets/icons/battery.webp"
      }
    ]
  }
  ```

---

## 4. Recycler Registry & Matching (`/recyclers` & `/matching`)

### `GET /recyclers/nearby`
- **Description:** PostGIS spatial query for authorized recyclers/aggregators within radius.
- **Query Params:** `lat=19.0760&lon=72.8777&radius_km=25`
- **Response 200 OK:**
  ```json
  [
    {
      "recycler_id": "REC-MH-042",
      "legal_name": "E-Scrap Eco Solutions Ltd",
      "distance_km": 4.2,
      "address": "Goregaon East Industrial Area",
      "cpcb_auth_valid_until": "2027-12-31",
      "accepted_categories": ["pcb_grade_a", "lithium_ion_battery", "crt_glass"],
      "contact_phone": "+912228001122"
    }
  ]
  ```

### `POST /matching/request`
- **Description:** Match a collector lot with optimal nearby authorized recyclers based on accepted materials, capacity, and benchmark pricing.

---

## 5. Dual-Handover Verification (`/handover`)

Implements tamper-evident audit handover required under E-Waste Rules 2022.

### `POST /handover/initiate`
- **Description:** Generate an immutable handover session with unique QR payload.
- **Request Body:**
  ```json
  {
    "lot_id": "KAB-202609-8F2A",
    "collector_id": "KC-C-7821"
  }
  ```
- **Response 200 OK:**
  ```json
  {
    "handover_token": "HND-TOKEN-9941-SECURE",
    "qr_payload": "kc://handover?token=HND-TOKEN-9941-SECURE&lot=KAB-202609-8F2A",
    "expires_at": "2026-09-24T20:30:00Z"
  }
  ```

### `POST /handover/confirm`
- **Description:** Recycler confirms receipt with scale weight, grade verification, and payment mode.
- **Request Body:**
  ```json
  {
    "handover_token": "HND-TOKEN-9941-SECURE",
    "recycler_id": "REC-MH-042",
    "actual_weight_kg": 15.2,
    "agreed_rate_per_kg": 155.0,
    "total_amount_inr": 2356.0,
    "payment_mode": "cash_received",
    "latitude": 19.1645,
    "longitude": 72.8522,
    "digital_signature_hash": "a4f89d..."
  }
  ```
- **Response 200 OK:**
  ```json
  {
    "status": "completed",
    "handover_id": "HND-REC-2026-00481",
    "epr_traceability_hash": "37bc902c418..."
  }
  ```

---

## 6. Cash-First Ledger & Financial Records (`/ledger`)

Per rule: *"Digital payment is optional and never a prerequisite. Payment status can be `cash_received`, `pending`, `digital_paid`."*

### `GET /ledger/summary`
- **Description:** Collector's running ledger summary.
- **Response 200 OK:**
  ```json
  {
    "collector_id": "KC-C-7821",
    "total_earned_inr": 34500.0,
    "cash_received_inr": 32144.0,
    "pending_inr": 2356.0,
    "total_lots_transacted": 18
  }
  ```

### `POST /ledger/entry`
- **Description:** Create or acknowledge a cash receipt entry.

---

## 7. Bidirectional Synchronization (`/sync`)

### `POST /sync/push`
- **Description:** Upload queued offline transactions in a single atomic batch.
- **Headers:** `X-Client-Transaction-ID: <UUID>`
- **Request Body:**
  ```json
  {
    "device_timestamp": "2026-09-24T18:45:00Z",
    "operations": [
      {
        "op_id": "op_01",
        "action": "create_lot",
        "payload": { ... }
      },
      {
        "op_id": "op_02",
        "action": "record_cash_payment",
        "payload": { ... }
      }
    ]
  }
  ```
- **Response 200 OK:**
  ```json
  {
    "processed": ["op_01", "op_02"],
    "conflicts": [],
    "synced_at": "2026-09-24T18:45:02Z"
  }
  ```

### `GET /sync/pull`
- **Description:** Fetch server delta updates since `last_synced_at`.
- **Query Params:** `since=2026-09-24T00:00:00Z&lat=19.076&lon=72.877`
- **Response 200 OK:**
  ```json
  {
    "price_board": { ... },
    "recyclers_delta": { "added": [], "updated": [], "removed": [] },
    "lot_status_updates": [ ... ],
    "server_time": "2026-09-24T18:45:05Z"
  }
  ```

---

## 8. Safety Content & Precautions (`/safety`)

Vernacular, pictorial safety and hazard instructions for dismantling e-waste.

### `GET /safety/cards`
- **Description:** Retrieve pictorial dismantling and hazard warning cards.
- **Query Params:** `category=lithium_ion_battery&language=mr`
- **Response 200 OK:**
  ```json
  [
    {
      "id": "SAFE-BATT-01",
      "hazard_level": "danger",
      "pictogram_url": "/assets/safety/do_not_puncture.webp",
      "audio_prompt_url": "/assets/audio/mr/do_not_puncture.mp3",
      "text_vernacular": "बॅटरीला कापू किंवा टोचू नका - आग लागू शकते!"
    }
  ]
  ```

---

## 9. Analytics & Compliance Oversight (`/analytics`)

### `GET /analytics/recycler/summary`
- **Description:** For authorized recyclers—mass balance, received material by category, EPR credit generation.

### `GET /analytics/admin/overview`
- **Description:** For JNARDDC & Ministry of Mines—geographical collection density, formalization rate of informal collectors, pricing stability index.
