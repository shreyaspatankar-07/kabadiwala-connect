# Kabadiwala Connect: 5–7 Minute Live Demonstration Script

**Smart India Hackathon 2024 / Problem Statement 26229 (Ministry of Mines / JNARDDC)**  
**Demonstration Target**: SIH Evaluation Jury & Technical Assessors  
**Total Duration**: 5–7 Minutes  
**Primary Persona**: Ramesh (Informal Collector in Thane, Maharashtra, 2GB Android Phone, Low Literacy, Marathi speaker).

---

## ⏱️ Presentation & Live Action Roadmap

| Minute | Module | What to Tap (Action) | What to Say (Verbal Pitch) | Offline Capable? |
| :---: | :--- | :--- | :--- | :---: |
| **0:00 - 0:45** | **1. Vernacular Onboarding & Zero-PII Auth** | Select Marathi tile, enter 4-digit PIN (`1234`), confirm PIN | *"Under India's E-Waste Rules 2022, 95% of e-waste is processed informally by low-literacy collectors. We eliminate friction with zero text typing, zero Aadhaar/PII collection, and immediate Marathi voice guidance."* | ✅ **100% Offline** |
| **0:45 - 1:45** | **2. Offline Lot Creation & Edge ML Valuation** | Tap **Add Lot**, snap/select PCB photo, select condition (Broken), tap weight pad `14.5 kg` | *"Ramesh creates an e-waste lot in a remote scrap yard with zero network. Edge TFLite classifies the circuit board, calculates instant value at government benchmark rates (₹205/kg = ₹2,972), and reads it aloud."* | ✅ **100% Offline** |
| **1:45 - 2:45** | **3. Contextual Safety Nudge & Hazard Alert** | Tap Category: **CRT Monitor** or Condition: **Burnt** | *"When a dangerous item like a CRT monitor or burnt cable is picked, the app immediately intercepts with an illustrated comic hazard card and vernacular audio: 'Never break CRT tubes—implosion and toxic lead hazard!' Ramesh taps 'I Understood' to proceed safely."* | ✅ **100% Offline** |
| **2:45 - 3:45** | **4. Fair Benchmark Pricing & Recycler Discovery** | Open **Price Board** tab, tap **Best Buyers** | *"Instead of being exploited by local middlemen at ₹120/kg, Ramesh sees the live regional government rate of ₹205/kg and discovers 3 nearby verified EPR recyclers ranked by fair price, distance, and pickup availability."* | ✅ **100% Offline** |
| **3:45 - 4:45** | **5. Verifiable Handover & Signed QR Code** | Tap **Generate Handover QR** on mobile; open Recycler Portal on laptop | *"At handover, the mobile app generates a tamper-evident QR with HMAC-SHA256 signature, GPS, timestamp, and photo hashes. The authorized recycler scans the QR, confirms measured scale weight (14.5 kg), and selects Cash Payment."* | ⚡ **QR Generated Offline / Confirmed by Recycler** |
| **4:45 - 5:45** | **6. Cash-First Ledger & Formal vs Informal Lift** | Open **Earnings Ledger** on mobile; show Statement export | *"Ramesh's cash-first ledger immediately updates with ₹2,972 credited in cash. Comparing against the informal middleman baseline of ₹1,740, Kabadiwala Connect generated a **+70.8% direct earnings lift** for the collector while bringing the material into formal EPR traceability!"* | ✅ **100% Offline** |
| **5:45 - 6:30** | **7. Admin Portal & Anomaly Detection** | Open Admin Portal `Anomaly Review Queue` | *"On the admin portal, our ML Isolation Forest and rule engines automatically catch and flag fraud—such as a 4.5-ton CRT typo or an extreme price spike—protecting EPR credit integrity for the Ministry."* | 🌐 **Web Portal** |

---

## 🎬 Step-by-Step Walkthrough Guide

### Step 1: Zero-PII Vernacular Onboarding (0:00 – 0:45)
- **Visual Action**: Launch the mobile app from cold start. The app immediately greets in Marathi audio. Tap the large green **मराठी (Marathi)** tile.
- **Keypad**: On the 72dp keypad, enter `1 2 3 4` and re-enter `1 2 3 4`.
- **Narrative**:
  > *"Notice that cold start took less than 1.4 seconds on our 2GB RAM test profile. There is no Aadhaar form, no phone number mandate, and no typing required. A secure anonymous collector ID (`KC-C-7821`) is generated locally on device."*

---

### Step 2: Offline E-Waste Lot Creation & Spoken Estimate (0:45 – 1:45)
- **Visual Action**: Switch Demo Mode's simulated connection to **"📵 Offline"** via the top yellow Demo Banner. Tap the first tab: **माल जोडा (Add Lot)**.
- **Action**: Tap camera, pick photo. Edge TFLite model detects `PCB (mid grade)`. Select condition `तुटलेला (Broken)`.
- **Action**: Tap `1`, `4`, `.`, `5` kg on the numeric pad.
- **Audio Output**: Tap the Speaker icon. App announces: *"अंदाजे सरकारी भाव सुमारे २,९७२ रुपये आहे."*
- **Action**: Tap **माल सुरक्षित जतन करा (Save Lot)**.
- **Narrative**:
  > *"Even with simulated airplane mode active, the lot is instantaneously saved into local Drift SQLite with photo hashes and enqueued into our sync queue. Zero network required."*

---

### Step 3: Contextual Safety Guidance (1:45 – 2:45)
- **Visual Action**: Switch category to **CRT Monitor**.
- **Result**: An illustrated red warning banner immediately pops up: *"सीआरटी मॉनिटर कधीही फोडू नका!" (Never break CRT monitors)*.
- **Action**: Tap the banner to view 4 illustrated steps, green DOs and red DONTs. Tap **"मला नियम समजला" (I Understood)**.
- **Narrative**:
  > *"Informal dismantling in backyards causes lead poisoning and severe injuries. Kabadiwala Connect actively educates collectors with comic-style safety cards and audio prompts before hazardous material is handled."*

---

### Step 4: Fair Benchmark Pricing & Discovery (2:45 – 3:45)
- **Visual Action**: Tap **दर फलक (Price Board)**.
- **Result**: Displays live regional scrap rates across Maharashtra districts (Mumbai, Thane, Pune, Palghar, Nashik, Nagpur) with 30-day sparklines.
- **Action**: Tap **सर्वोत्तम खरेदीदार (Best Buyers)**.
- **Result**: Ranks top 3 authorized recyclers. Gold highlighted #1: *Maharashtra Green E-Solutions (12 km away, ₹210/kg, Pickup truck available)*.
- **Narrative**:
  > *"Middlemen traditionally exploit collectors with arbitrary rates. Our offline matching engine computes proximity, verified EPR accreditation, and fair rates to connect collectors with verified buyers."*

---

### Step 5: Signed QR Handover & Recycler Verification (3:45 – 4:45)
- **Visual Action**: Tap **हस्तांतरण QR कोड (Generate Handover QR)** on phone.
- **Visual Action**: On laptop browser, open Recycler Portal at `http://localhost:3000` -> **Handover Confirmation**.
- **Action**: Recycler enters 6-character reference code (e.g. `REF7821`), enters measured weight `14.5 kg`, price `₹2,972.50`, selects **"Cash Received"**, and clicks **Confirm Handover**.
- **Result**: Green verification hash chain receipt created: `record_hash = SHA256(...)`.
- **Narrative**:
  > *"Handover is cryptographically sealed. If there is a weight discrepancy greater than 10%, the system flags it as disputed to prevent EPR quota falsification."*

---

### Step 6: Cash-First Ledger & Earnings Lift (4:45 – 5:45)
- **Visual Action**: Switch back to mobile app, tap **कमाई (Earnings)** tab.
- **Result**: Total earnings display updates to `₹11,338.50`. Latest transaction shows `₹2,972.50 (Cash Received)`.
- **Narrative**:
  > *"Let's examine the economic impact: In the informal sector, Ramesh would have received ₹120/kg = ₹1,740 for this PCB scrap. Through Kabadiwala Connect's direct verified channel, he received ₹2,972.50—a **+70.8% income boost directly in cash**, while securing an audited EPR certificate for downstream recycling."*

---

### Step 7: Ministry / Admin Anomaly Detection (5:45 – 6:30)
- **Visual Action**: On portal, switch to **Admin Portal -> Anomaly Review Queue**.
- **Result**: Shows 3 flagged anomalies:
  1. `KC-MH-2609-ANOM1`: Rate ₹1,850/kg exceeds 2.5x IQR threshold.
  2. `KC-MH-2609-ANOM2`: Single unit weight 4,500 kg exceeds sanity ceiling.
  3. `KC-MH-2609-ANOM3`: Rapid burst of 5 submissions in 180 seconds.
- **Narrative**:
  > *"For the Ministry of Mines and JNARDDC, our machine learning isolation forest filters fraudulent data entries before mass balance aggregation and compliance certificates are issued."*

---

## 🏆 Key Takeaways for Judges
1. **100% Offline-First Core**: Creation, pricing, matching, safety, and ledger function completely without cellular connectivity.
2. **True Low-Literacy Vernacular UX**: Spoken audio on every screen, min 56dp targets, 44 ARB strings in Marathi and Hindi with zero English fallback.
3. **Formalization without Friction**: No Aadhaar or real name required; cash-first payments with verifiable hash chains.
4. **Lightweight & High Performance**: Under 15 MB APK footprint, cold start under 1.5 seconds on 2GB RAM device.
