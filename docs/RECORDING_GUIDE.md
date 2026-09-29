
# Kabadiwala Connect: Demo Recording & Video Production Guide

Authoritative production guide for recording high-fidelity demonstration videos of the **Kabadiwala Connect** platform — showcasing seamless synchronization between the offline vernacular Android mobile app and the EPR Recycler/Admin web portal under India's E-Waste (Management) Rules 2022 (Smart India Hackathon PS 26229 / JNARDDC).

---

## 1. System Setup & Prerequisites

Before running the recording scripts, ensure all three tiers of the system are operational:

| Tier | Component | Address | Verification Command |
|---|---|---|---|
| **Backend API** | FastAPI + SQLite/PostGIS | `http://localhost:8000` | `curl http://localhost:8000/health` |
| **Recycler Portal** | Next.js 14 + Tailwind | `http://localhost:3000` | Open browser at `http://localhost:3000` |
| **Collector App** | Flutter Android Mobile | `emulator-5554` | `adb devices` shows `emulator-5554 device` |

### Environment Verification:
```bash
# 1. Verify Emulator is running and visible
adb devices
# Expected: emulator-5554   device

# 2. Check Backend Server (in terminal / background)
cd c:\dev\kabadiwala-connect\backend
py -3.11 -m uvicorn app.main:app --workers 1 --port 8000

# 3. Check Web Portal (in terminal / background)
cd c:\dev\kabadiwala-connect\portal
npm run dev
```

---

## 2. Automated Recording Scripts

Two fully automated end-to-end recording scripts are available in the repository. Both scripts run at a human-paced, deliberate speed (2–3 second pauses between actions) specifically tuned for video recording:

### Script 1: Mobile App Walkthrough (Flutter Integration Test)
- **Script Location**: `mobile/scripts/record_demo.bat`
- **Underlying Test**: `mobile/integration_test/demo_walkthrough_test.dart`
- **Execution Command**:
  ```cmd
  cd c:\dev\kabadiwala-connect\mobile
  scripts\record_demo.bat
  ```
- **Automated Sequence (52 steps)**:
  1. **Language & PIN Setup**: Selection of Marathi (`lang_tile_mr`), PIN keypad entry (1-2-3-4), confirmation to shell.
  2. **Add Lot Flow**: PCB category selection (`category_tile_PCB`), Broken condition (`condition_broken`), weight 5.00 kg keypad entry, value estimation, speaker narration, offline lot save (`btn_save_lot`).
  3. **Best Buyers**: 3 ranked CPCB/MPCB authorized recyclers, spoken audio readout, top buyer selection (`btn_select_buyer_0`).
  4. **Handover**: Auto-generated HMAC-SHA256 QR code, 6-character code `A7K9P2`, spoken read-aloud.
  5. **Price Board**: Regional rate cards (`category_tile_PCB`), sparkline chart, trend arrow, audio readout.
  6. **Safety Rules**: Visual safety guide, comic pictograms, dos/donts, spoken guidance, "I Understood" acknowledgment (`btn_understood`).
  7. **Earnings**: Today/week/month financial tiles, transaction read-aloud, pending dues audit.

---

### Script 2: Recycler & Admin Web Portal (Playwright Test)
- **Script Location**: `portal/scripts/run_demo.bat`
- **Underlying Test**: `portal/scripts/demo_walkthrough.spec.ts`
- **Execution Command**:
  ```cmd
  cd c:\dev\kabadiwala-connect\portal
  scripts\run_demo.bat
  ```
- **Automated Video Output**: Playwright automatically records a 1280x720 video with smooth 500ms slowMo to:
  `portal/test-results/` (playable `.webm` file).
- **Automated Sequence (48 steps)**:
  1. **Recycler Login**: Clean sign-in with `recycler@demo.com`.
  2. **Inbox Acceptance**: View real-time incoming lots, accept first lot.
  3. **Handover Verification**: Enter code `A7K9P2`, measured weight `5.2 kg`, final price `₹2100`, mismatch check, Cash payment confirmation.
  4. **Downstream Lifecycle**: Update stage to "Dismantled", verified 4-step EPR timeline.
  5. **Recycler Dashboard**: Metric cards for volume, spend, rates, pending dues.
  6. **Role Switch**: One-click switcher to JNARDDC Compliance Admin.
  7. **Recycler Verification Queue**: Review authorization document and click Approve.
  8. **Anomaly Audit**: Flagged outlier review (`price_outlier`, `weight_implausible`) and resolution.
  9. **Analytics**: Data quality scorecard (91.7/100), formal channel inflow, +70% direct earnings lift.
  10. **Price Override**: Manually override PCB Mumbai rate to ₹480/kg.

---

## 3. Simultaneous Execution Workflow

To record live real-time interaction between mobile and portal:

```
[ Terminal 1: Mobile ]                       [ Terminal 2: Web Portal ]
-------------------------                    --------------------------
cd mobile                                    cd portal
scripts\record_demo.bat                      scripts\run_demo.bat
```

1. Start **Terminal 1** (`record_demo.bat`).
2. Once the app launches on the emulator (around Part 2 - Add Lot), start **Terminal 2** (`run_demo.bat`).
3. Both run concurrently with deliberate 2–3s pauses so the viewer can clearly see actions taking effect on both ends.

---

## 4. OBS Studio Setup (Split-Screen Recording)

OBS Studio is recommended to capture both the Android Emulator and the Web Browser side-by-side in high definition (1080p or 4K):

### Step 1: Canvas Settings
- Open **Settings > Video**:
  - **Base (Canvas) Resolution**: `1920x1080` (or `3840x2160` for 4K)
  - **Output (Scaled) Resolution**: `1920x1080`
  - **Downscale Filter**: Lanczos (sharpened scaling, 36 samples)
  - **Common FPS Values**: `60` fps (or `30` fps)

### Step 2: Audio Settings
- **Settings > Audio**:
  - **Desktop Audio**: Default audio output (captures Flutter TTS and speaker readouts).
  - **Sample Rate**: `48 kHz`.
  - **Channels**: Stereo.

### Step 3: Layout Composition (Side-by-Side Split Screen)
Create a new Scene titled `Kabadiwala Demo`:

1. **Source 1: Mobile App (Left Column, ~38% width)**
   - Click `+` > **Window Capture**.
   - Window: `[emulator64-arm64.exe]: Android Emulator - Pixel_...`
   - Transform: Scale to height `1000px`, align on the left (X: `60`, Y: `40`).
   - Add a subtle drop shadow or phone border filter.

2. **Source 2: Web Portal (Right Column, ~62% width)**
   - Click `+` > **Window Capture**.
   - Window: `[chrome.exe]: Kabadiwala Connect | JNARDDC EPR Portal`
   - Transform: Scale to fit remaining space (X: `560`, Y: `40`, width: `1300`, height: `1000`).

3. **Source 3: Background & Branding**
   - Click `+` > **Color Source** (dark slate `#020617`).
   - Add top banner text: `Kabadiwala Connect — JNARDDC / Ministry of Mines (SIH 26229)`

---

## 5. Merging & Editing in CapCut

If recording separate footage from Playwright (`portal/test-results/`) and the Android Emulator:

### Step 1: Project Setup
1. Launch CapCut Desktop.
2. Create **New Project**.
3. Set **Aspect Ratio** to `16:9` (`1920x1080`).

### Step 2: Timeline Synchronization
1. Import both video files:
   - `mobile_walkthrough.mp4` (or emulator screen record).
   - `demo_walkthrough_video.webm` (from `portal/test-results/`).
2. Place the Portal video on Track 1 (Base).
3. Place the Mobile video on Track 2 (Overlay / PIP).
4. **Anchor Sync Point**:
   - In Mobile footage: Find the exact timestamp where the Handover QR Code with code **`A7K9P2`** is displayed on screen.
   - In Portal footage: Find the timestamp where **`A7K9P2`** is entered into the Handover Confirmation form.
   - Align these two timeline points so the handover verification happens simultaneously in real time.

### Step 3: Visual Polish & Annotations
1. **Side-by-Side Layout**:
   - Crop / scale Portal video to fill the right 60% of the canvas.
   - Scale Mobile video to fill the left 40% inside a smartphone frame asset.
2. **Key Callouts (Lower Thirds)**:
   - *Language Setup*: "Vernacular Low-Literacy Interface: Marathi, Hindi & Icon-First"
   - *Add Lot*: "On-Device Offline Classification & Fair Value Benchmark Rates"
   - *Handover*: "HMAC-SHA256 Tamper-Proof Cryptographic QR Audit Chain"
   - *Portal Verification*: "CPCB / SPCB Registered Recycler ERP Confirmation"
   - *Analytics*: "91.7/100 Data Quality Score & +70% Direct Payout Lift for Collectors"

---

## 6. Recommended Export Settings

For the final hackathon submission video:

| Parameter | Recommended Setting | Alternate (Fast Upload) |
|---|---|---|
| **Format** | MP4 | MP4 |
| **Resolution** | **1080p (1920x1080)** | 1080p (1920x1080) |
| **Codec** | **H.264 / AVC** | H.264 |
| **Bitrate** | **CBR 16,000 kbps (16 Mbps)** | VBR 10,000 kbps |
| **Frame Rate** | **60 fps** | 30 fps |
| **Audio Format** | **AAC Stereo** | AAC Stereo |
| **Audio Bitrate** | **320 kbps, 48 kHz** | 192 kbps, 44.1 kHz |
| **Total Duration** | **2m 30s – 3m 30s** | Under 3 minutes |

These settings ensure crystal-clear text readability on mobile and desktop screens, zero audio distortion on voice readouts, and compliance with hackathon submission portals.
