# 🧪 Kabadiwala Connect — Complete Ecosystem Testing Guide
**For: External Tester / Friend**
**Project: SIH 2024 PS-26229 | Kabadiwala Connect**

---

> ⚠️ **Before you start**: The backend (API server) is on Render's free tier.
> The **first request after a long idle period may take 30–60 seconds** — this is normal.
> Wait for it to load once, everything will be fast after that.

---

## 📋 What You Are Testing

| Component | What it is | How to access |
|-----------|-----------|---------------|
| **Android App** | Collector (Kabadiwala) mobile app | Install the APK shared with you |
| **Web Portal** | Recycler + Admin + Citizen portal | Open the Vercel URL in any browser |

---

## 📱 PART 1: Android Mobile App (Collector)

> **Install the APK** → Allow "Install from unknown sources" if prompted → Open the app.

---

### 🔹 Step 1: Language Selection
1. Open the app.
2. You will see **3 language options**: Marathi (मराठी), Hindi (हिंदी), English.
3. **Tap the speaker 🔊 button** on the screen — it should read the options aloud.
4. **Select "English"** for easiest testing.
5. Tap **Proceed / Continue**.

✅ *Expected: Language selection screen with big tiles and audio playback works.*

---

### 🔹 Step 2: PIN Setup (First-Time Setup)
1. You will be asked to **create a 4-digit PIN**.
2. Enter any 4 digits (e.g., `1234`).
3. Confirm the PIN.
4. Tap the **speaker button** — it should confirm your PIN in the selected language.

✅ *Expected: PIN created, app proceeds to the main screen.*

---

### 🔹 Step 3: Home Screen (Bottom Navigation)
- You will see **4 bottom tabs**:
  - 📦 **Add Lot** — create a new scrap collection
  - 💰 **Price Board** — current e-waste market rates
  - 📊 **Earnings** — your cash ledger
  - 🛡️ **Safety** — safe handling guide

- Notice the **sync badge** at the top (🟡 Offline / 🟢 Online).

✅ *Expected: Main navigation works, sync badge shows status.*

---

### 🔹 Step 4: Check the Price Board
1. Tap **Price Board** (bottom tab).
2. You will see **rate cards** for categories like PCB, Cables, Batteries, CRT, LCD, Motors.
3. **Tap any category card** (e.g., PCB) to see detailed rates.
4. Tap the **🔊 speaker button** — it should read out the price in the selected language.

✅ *Expected: Price cards visible, audio reads the price aloud.*

---

### 🔹 Step 5: Create a New Scrap Lot (Core Feature)
1. Tap **Add Lot** (📦 bottom tab).
2. **Step A — Category**: Tap a category (e.g., "Cables & Wires").
3. **Step B — Sub-category**: Select a sub-category (e.g., Copper).
4. **Step C — Condition**: Select condition chip (e.g., "Broken").
5. **Step D — Weight**: Enter a weight (e.g., `5.0` kg using the big number pad).
6. Notice the **instant value estimate** at the bottom (e.g., "₹ 1,550 estimated").
7. Tap the **🔊 speaker button** — it reads the estimate aloud.
8. **Step E — Photo**: Tap the camera icon to take a photo (or skip if camera not available).
9. Tap **Save Lot / Submit**.

✅ *Expected: Lot created with a unique ID like `KC-MH-2610-XXXX`. A sync icon (🕐) appears — the lot is queued to sync.*

---

### 🔹 Step 6: Get the Handover QR Code
1. Tap **Earnings** (📊 bottom tab).
2. Switch to the **"My Created Lots"** tab.
3. Find the lot you just created.
4. Tap **"Handover Code / QR"** button on the lot card.
5. A **6-character code** (e.g., `W7DC8J`) and a **QR code** appear.
   - 📝 **Write down this 6-character code** — you'll enter it on the web portal.

✅ *Expected: 6-char code + QR code displayed for the lot.*

---

### 🔹 Step 7: Safety Guide
1. Tap **Safety** (🛡️ bottom tab).
2. Browse the safety cards for handling CRTs, batteries, etc.
3. Tap any speaker button to hear the safety tip.

✅ *Expected: Safety guidance screen with audio works.*

---

## 🌐 PART 2: Web Portal (Recycler / Admin / Citizen)

> Open the **Vercel URL** in any browser (Chrome recommended).

---

### 🔹 Step 8: Login Screen
1. Open the portal URL.
2. You will see **3 role cards**: Public/Citizen, Authorized Recycler, Govt Admin.
3. Click on each card to see how the credentials change automatically.

---

### 🔹 Step 9: Login as Authorized Recycler
1. Click the **"Authorized Recycler"** role card.
2. Credentials are shown on screen:
   - **Email**: `recycler@ecorecycle.in`
   - **Password**: `recycler123`
3. Click **"Sign In as Recycler"** (or use **"1-Click Recycler Demo"**).

✅ *Expected: Recycler portal with sidebar tabs: Dashboard, Lot Inbox, Handover, Downstream, Profile.*

---

### 🔹 Step 10: Recycler Dashboard
1. Check the **4 stat cards**: Total Volume, Total Spend, Pending Payments, Active Matches.
2. Look at the **Material Intake bar chart** and **Offered Rates grid**.

✅ *Expected: Dashboard loads with data.*

---

### 🔹 Step 11: Lot Inbox (Real-Time Feed)
1. Click **"Lot Inbox"** in the sidebar.
2. You see **matched scrap lot cards** from collectors.
3. On a card:
   - Click **✅ Accept** — lot status changes to "accepted".
   - Or click **Counter** — enter a new rate per kg and send it.
   - Or click **Decline**.

✅ *Expected: Lot actions work, success message appears.*

---

### 🔹 Step 12: Handover Confirmation ⭐ (Connect App + Portal!)
1. Click **"Handover"** in the sidebar.
2. In the **code input field**, type the **6-character code from Step 6** on the app.
3. The system **auto-fetches** lot details (category, weight, lot ID, integrity hash).
4. Alternatively, click **"QR Scan"** for a pre-filled demo code.
5. Fill in:
   - **Measured Weight** (what your scale shows)
   - **Final Agreed Price**
   - **Payment Mode**: Cash Received or Digital
6. Click **"Confirm Handover & Generate EPR Record"**.
7. The record appears in the **"Settled Transactions"** table below with a cryptographic hash.

✅ *Expected: Lot fetched from app code, handover record created, appears in table.*

---

### 🔹 Step 13: Downstream Tracking
1. Click **"Downstream"** in the sidebar.
2. View the chain: collector → recycler → processing stage.
3. Use the stage dropdown to update processing status.

✅ *Expected: Status update works.*

---

### 🔹 Step 14: Recycler Profile
1. Click **"Profile"** in the sidebar.
2. View authorization number, materials accepted, service area districts, and offered rates.
3. Try editing a rate and saving.

✅ *Expected: Profile loads, rate edit saves.*

---

### 🔹 Step 15: Logout → Login as Government Admin
1. Click **Logout** (top navbar).
2. Select **"Govt Admin"** role card.
3. Credentials:
   - **Email**: `admin@jnarddc.gov.in`
   - **Password**: `admin123`
4. Click **"Sign In as Admin"** (or **"1-Click Admin Demo"**).

✅ *Expected: Admin portal with 5 sidebar tabs.*

---

### 🔹 Step 16: Admin — Recycler Verification Queue
1. Click **"Verification Queue"** in the sidebar.
2. See **pending recycler authorization applications**.
3. Click **✅ Approve** on one → status: Verified.
4. Click **⚠️ Suspend** on another → status: Suspended.

✅ *Expected: Actions work with success notification.*

---

### 🔹 Step 17: Admin — Expiry Alerts
1. Click **"Expiry Alerts"** in the sidebar.
2. View recyclers whose authorization expires within 30/60/90 days.

✅ *Expected: Alert cards visible with expiry countdown.*

---

### 🔹 Step 18: Admin — Price Board Override
1. Click **"Price Board"** in the sidebar.
2. Select a district (e.g., Mumbai).
3. Click **"Edit"** on any category → enter a new rate → **Save Override**.

✅ *Expected: Rate updated. This new rate syncs to the mobile app on next pull.*

---

### 🔹 Step 19: Admin — Anomaly Review (ML Fraud Detection)
1. Click **"Anomalies"** in the sidebar.
2. View **ML-flagged suspicious transactions** with reasons:
   - `IMPLAUSIBLE_WEIGHT` — physically impossible weight
   - `PRICE_OUTSIDE_IQR` — price far outside market range
3. Click **✅ Resolve** on one anomaly.
4. Click **⬆️ Escalate** on another for formal CPCB audit.

✅ *Expected: Anomaly statuses update.*

---

### 🔹 Step 20: Admin — Analytics Dashboard
1. Click **"Analytics"** in the sidebar.
2. View:
   - **Data Quality Score** (91.7/100)
   - **District-wise intake bar chart** (Mumbai, Pune, Thane, etc.)
   - **Monthly EPR growth chart**
   - **+70% Collector Earnings Lift** metric
3. Click **"Export CSV"** — a CSV file of anonymized e-waste data downloads.

✅ *Expected: Charts render, CSV downloads.*

---

### 🔹 Step 21: Logout → Login as Citizen
1. Logout and select **"Public / Citizen"** role card.
2. Options:
   - **Sign In**: `citizen@mumbai.gov.in` / `citizen123`
   - **Register**: Create a brand new account (your own email)
   - **1-Click Demo**: Fastest login

✅ *Expected: Citizen dashboard opens.*

---

### 🔹 Step 22: Citizen — Book Doorstep E-Waste Pickup
1. On the **"Book Doorstep Pickup"** tab:
2. Select **e-waste categories** (e.g., Cables, Batteries).
3. Enter your **address** or click **"Detect Current Location"** (GPS).
4. Enter a **phone number**.
5. Choose a **time slot**.
6. Click **"Confirm & Book Doorstep Collection"**.
7. A **Tracking ID** (e.g., `PR-MH-2026-F9A12`) appears.
8. Click **"View Live Stepper & Tracking"**.

✅ *Expected: Booking confirmed, tracking ID generated.*

---

### 🔹 Step 23: Citizen — My Bookings & Tracking Stepper
1. Click **"My Bookings & Stepper"** tab.
2. View all pickup requests with the **4-stage tracker**:
   - Stage 1: Requested ✓ (green)
   - Stage 2: Assigned (collector matched)
   - Stage 3: In Transit (pulsing amber when active)
   - Stage 4: Handed Over (green when done)

✅ *Expected: Stepper shows correct progress for each booking.*

---

### 🔹 Step 24: Citizen — Price Board & Green Impact
1. Click **"Transparent Price Board"** tab → see household scrap rate guide.
2. Click **"Green Credits & Impact"** tab → see:
   - kg of e-waste diverted from landfills
   - CO₂ equivalent prevented
   - Fair cash earned

✅ *Expected: Both tabs render with data.*

---

## ✅ Final Checklist

| # | Feature | Tick when done |
|---|---------|---------------|
| 1 | App: language selection + audio | ☐ |
| 2 | App: PIN setup | ☐ |
| 3 | App: price board + audio readout | ☐ |
| 4 | App: add scrap lot + value estimate | ☐ |
| 5 | App: handover QR code generated | ☐ |
| 6 | App: earnings ledger + my lots | ☐ |
| 7 | App: safety guide audio | ☐ |
| 8 | Portal: 3-role login screen | ☐ |
| 9 | Recycler: accept/counter/decline lot | ☐ |
| 10 | Recycler: handover with app's 6-char code | ☐ |
| 11 | Recycler: downstream status update | ☐ |
| 12 | Admin: approve/suspend recycler | ☐ |
| 13 | Admin: price board override | ☐ |
| 14 | Admin: ML anomaly resolve/escalate | ☐ |
| 15 | Admin: analytics + CSV export | ☐ |
| 16 | Citizen: book doorstep pickup | ☐ |
| 17 | Citizen: tracking stepper | ☐ |
| 18 | Citizen: create new account (register) | ☐ |

---

## 🐛 Found a Bug? Report With:
1. **Which step** you were on
2. **What happened** (error / blank / wrong behavior)
3. **Screenshot** if possible
4. **Device & browser** (e.g., Samsung Galaxy A32, Chrome 120)

---

*Built for Smart India Hackathon 2024 | PS-26229 | Ministry of Mines / JNARDDC*
*Kabadiwala Connect — Formalizing India's Informal E-Waste Economy* 🌱
