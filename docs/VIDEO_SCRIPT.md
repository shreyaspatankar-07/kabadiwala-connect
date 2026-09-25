# Kabadiwala Connect: 2-Minute Demo Video Script

**Smart India Hackathon Problem Statement 26229**  
**Total Runtime**: 2 Minutes (120 Seconds)  
**Format**: Split Screen / Live Demonstration with Vernacular Audio Overlay  

---

### [0:00 – 0:20] Problem Statement: The Invisible 90%
- **Visual**:
  - Dramatic split screen: Left side shows footage/stills of informal scrap yards, open burning of cables, and crude acid baths. Right side shows a certified high-tech e-waste recycling plant with empty conveyor belts.
  - Onscreen text: *"1.7M Tonnes E-Waste. 90% Processed Informally. 0% Traceability."*
- **Voiceover (Authoritative, empathetic)**:
  > *"Over 90% of India's electronic waste is collected by informal kabadiwalas. Exploited by middlemen with 30% price cuts, exposed to toxic fumes, and cut off from formal recyclers who desperately need volume for EPR compliance. Welcome to **Kabadiwala Connect**—the vernacular, offline-first bridge transforming India's e-waste ecosystem."*

---

### [0:20 – 0:50] Mobile App Live Demo (Collector Flow)
- **Visual**:
  - **Screen 1 (0:20 - 0:25)**: `LanguageSelectionScreen` with large Devanagari buttons (*मराठी / हिंदी*). Collector taps speaker button; clear Marathi voice speaks aloud. Tap मराठी $\rightarrow$ quick 4-digit PIN setup.
  - **Screen 2 (0:25 - 0:33)**: `PriceBoardScreen` showing pictorial category grid (PCB, CRT, LCD, Cables). Voice reads: *"सर्किट बोर्ड: आजचा सरकारी भाव ₹420 प्रति किलो."* Sparkline shows 30-day fair price trend.
  - **Screen 3 (0:33 - 0:42)**: `AddLotScreen` — Collector snaps a photo of a circuit board. On-device MobileNetV3 AI instantly classifies it as **PCB - Grade A (Confidence 94%)**. Slider adjusts weight to 5.0 kg; estimated value ₹2,100 appears dynamically.
  - **Screen 4 (0:42 - 0:50)**: Contextual safety alert pops up (*"केबल कधीही जाळू नका!"*). Collector taps *नियम समजला* and generates a 6-character Handover Code (`KW98A2`) and QR code.
- **Voiceover (Fast-paced, energetic)**:
  > *"Built for low-literacy users on 2GB Android phones. Big 56-dp touch targets, full voice guidance, zero typing. Our on-device neural network classifies scrap grades in milliseconds, checks live fair prices, and works 100% offline in remote yards with zero internet!"*

---

### [0:50 – 1:20] Recycler & Admin Web Portal Demo
- **Visual**:
  - **Screen 5 (0:50 - 0:58)**: Authorized Recycler Dashboard on Next.js portal. Shows live volume collected (4,850 kg), monthly spend, and matched incoming lots inbox.
  - **Screen 6 (0:58 - 1:08)**: Handover Verification screen (`/handover`). Recycler enters 6-character token `KW98A2` or scans QR. Recycler enters measured weight (5.2 kg). Portal verifies against collector estimate; green match confirmation triggers.
  - **Screen 7 (1:08 - 1:20)**: Downstream EPR lifecycle tracker: Recycler updates status from `received` $\rightarrow$ `dismantled` $\rightarrow$ `processed` $\rightarrow$ `certificate_issued`. Admin portal shows fraud-detection anomaly review flagging suspicious burst uploads.
- **Voiceover (Professional, clear)**:
  > *"On the web portal, authorized recyclers receive verified local leads, verify weights with instant mismatch alerts, and log payments. Every kilogram is cryptographically hashed and tracked all the way to final EPR certificate issuance—giving the Ministry of Mines 100% auditable mass-balance traceability."*

---

### [1:20 – 1:40] Data Pipeline, ML & Anomaly Detection
- **Visual**:
  - Animated screen capture showing `LightGBM` valuation regression curve, `Isolation Forest` multi-factor anomaly detector, and automated drift monitor (PSI).
  - Quick terminal cut showing all 73 backend tests, 60 mobile tests, and 5 E2E Playwright tests passing with 0 errors.
- **Voiceover (Technical, precise)**:
  > *"Under the hood: FastAPI and PostgreSQL PostGIS power spatial matching. LightGBM models fair regional valuations, while an Isolation Forest catches fraud and weight tampering. Our living data pipeline monitors data drift continuously, ensuring robust compliance."*

---

### [1:40 – 2:00] Unit Economics & Call to Action
- **Visual**:
  - Clean infographic bar chart showing daily collector earnings jump from **₹430 (Informal)** to **₹514 (Kabadiwala Connect)**: **+19.5% income lift (+₹2,184/month)**.
  - Final splash card with logos: Smart India Hackathon, Ministry of Mines, JNARDDC, and Kabadiwala Connect.
- **Voiceover (Inspiring, impactful)**:
  > *"The result? A 20% direct income increase for grassroots kabadiwalas, zero toxic backyard processing, and a predictable, verified supply chain for India's circular economy. Kabadiwala Connect: Empowering collectors, formalizing recycling, protecting our environment."*
