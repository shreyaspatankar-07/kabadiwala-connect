# Kabadiwala Connect: 10-Slide Pitch Deck Outline

**Smart India Hackathon Problem Statement 26229**  
**Ministry of Mines / Jawaharlal Nehru Aluminium Research Development and Design Centre (JNARDDC)**  
**Theme**: Inclusive Technology for Circular Economy & Informal E-Waste Formalization  

---

### Slide 1: The Invisible 90% (Problem)
- **Title**: India's E-Waste Reality: The 90% Operating in the Dark
- **Headline**: 1.7 million tonnes of e-waste generated annually; 90%+ handled by informal kabadiwalas outside the formal chain.
- **Key Visuals**:
  - Infographic comparing informal processing (acid baths, open wire burning) vs formal recycling facilities.
  - Three core pain points:
    1. **Aggregator Exploitation**: Kabadiwalas lose 20-30% of fair value due to zero price transparency.
    2. **Hazardous Exposure**: Severe respiratory and neurological risks from unguided dismantling.
    3. **EPR Compliance Deficit**: Authorized recyclers starve for verified volume while informal scrap bypasses the registry.
- **Presenter Note**: *"E-waste isn't just an environmental hazard—it's a missed economic opportunity for the vulnerable workers at the frontline."*

---

### Slide 2: Solution Overview (Kabadiwala Connect)
- **Title**: Kabadiwala Connect: Bridging Grassroots Scrappers to Formal Recyclers
- **Headline**: A vernacular, low-literacy, offline-tolerant platform connecting informal collectors with SPCB/CPCB-authorized recyclers under E-Waste Rules 2022.
- **Core Pillars**:
  - 🗣️ **Zero-Literacy UX**: Icon-first design, Devanagari typography, full voice narration on every screen.
  - 📡 **Offline-First Resilience**: Local Drift SQLite caching; full transactions work with zero internet.
  - ⚖️ **Fair Price Discovery**: Live commodity-linked price board with min/max benchmark bands.
  - 🤝 **Verifiable Dual Handover**: Tamper-proof 6-character code and QR matching with photo hash integrity.
- **Presenter Note**: *"We designed from the scrap yard up: big buttons, native Marathi and Hindi, zero Aadhaar friction, and 100% offline capability."*

---

### Slide 3: Architecture & System Topology
- **Title**: End-to-End Edge-to-Cloud Architecture
- **Headline**: Lightweight on the edge, robust in the cloud, auditable on the ledger.
- **Key Visuals**:
  - Mermaid system topology diagram (Mobile App $\rightarrow$ Idempotent Sync Layer $\rightarrow$ FastAPI Gateway $\rightarrow$ PostGIS & ML Pipeline $\rightarrow$ Recycler & JNARDDC Portal).
  - Highlight: Target APK < 15 MB, cold start 1.35s on 2GB RAM device, sub-50ms touch latency.
- **Presenter Note**: *"The app operates autonomously in remote scrap yards and seamlessly synchronizes with exponential backoff when a 2G/3G link is found."*

---

### Slide 4: Low-Literacy & Vernacular Design Innovations
- **Title**: Engineering for Low Literacy: Respecting the User's Reality
- **Headline**: Built for users who speak Marathi or Hindi and prefer listening to reading.
- **Feature Highlights**:
  - **Single Primary Action**: Max 1 actionable target per viewport, oversized $\ge 56\text{dp}$ touch targets.
  - **Voice Feedback Engine**: Universal floating speaker button + automatic prompt readout.
  - **Big Numeric Keypad**: Custom Devanagari-enabled keypad eliminating system keyboard confusion.
  - **Visual Weight & Price Feedback**: Real-time slider and pictorial bill preview showing banknote equivalents.
- **Presenter Note**: *"A collector never has to type a single sentence. Audio cues, clear color codes, and pictorial categories guide every step."*

---

### Slide 5: Data Pipeline & Living Datasets
- **Title**: Living Data Architecture & Continuous Provenance
- **Headline**: Synthetic generation, dynamic simulation, and automated drift monitoring.
- **Key Metrics & Pipeline**:
  - Provenance tagging: `source: synthetic | field | scraped_public`.
  - Regional coverage: 6 Maharashtra industrial districts (Palghar, Thane, Mumbai, Pune, Nashik, Nagpur).
  - Automated MLOps drift monitor calculating Population Stability Index (PSI) on incoming lot distributions.
- **Presenter Note**: *"Our datasets are not static CSVs; they are active, reproducible pipelines that ingest live field reports and adapt to commodity price fluctuations."*

---

### Slide 6: On-Device ML & Fair Valuation Engine
- **Title**: AI at the Edge: Real-Time Classification & Pricing
- **Headline**: Dual ML modules putting transparent valuation directly into scrapper hands.
- **Module Details**:
  - **Material Classifier**: MobileNetV3-Small INT8 quantized TFLite (<5 MB) classifying 8 e-waste categories (PCB, CRT, LCD, Cables, Batteries, Motors, Plastics, Other). Confidence threshold (<0.55) triggers intuitive manual override.
  - **Valuation Engine**: LightGBM regressor predicting fair value based on weight, subcategory grade, physical condition, and local demand indices ($R^2 = 0.999$, RMSE $\approx ₹2.84$).
  - **Anomaly Engine**: Isolation Forest detecting rapid burst fraud, implausible weights, and price outliers.
- **Presenter Note**: *"With one snap, our lightweight neural network identifies high-value PCB grades and calculates a fair price floor instantly offline."*

---

### Slide 7: Verifiable Handover & EPR Traceability
- **Title**: Tamper-Proof Chain of Custody for E-Waste Rules 2022
- **Headline**: Eliminating paper leaks and phantom recycling credits.
- **Traceability Flow**:
  1. **Lot Creation**: Collector locks lot with photo SHA-256 hash and GPS coordinate.
  2. **Matching & Code**: System generates a unique 6-character transfer token and QR code.
  3. **Dual Confirmation**: Authorized recycler scans code, logs verified weight on portal, triggers instant weight mismatch warning if $>10\%$.
  4. **Downstream Mass Balance**: Tracks lot through dismantling, sorting, and final EPR certificate issuance.
- **Presenter Note**: *"Every kilogram collected at grassroots is cryptographically locked and tracked until certified mass balance processing."*

---

### Slide 8: Collector Unit Economics & Income Lift
- **Title**: Empowering Grassroots Kabadiwalas: $+19.5\%$ Daily Income
- **Headline**: Moving from informal exploitation to verified formal pricing.
- **Key Financial Takeaways**:
  - **Informal Baseline**: ₹430 daily net margin (aggregator takes 20-30% haircut).
  - **With Kabadiwala Connect**: **₹514 daily net margin** (+₹84/day, +₹2,184/month).
  - **Formal Premium**: Transparent price board eliminates arbitrary down-grading.
  - **Documented Ledger**: Unlocks creditworthiness and micro-finance eligibility without Aadhaar invasion.
- **Presenter Note**: *"A ₹2,100+ monthly lift represents a 20% increase in household income, achieved simply by removing opaque middlemen."*

---

### Slide 9: Field Research & Safety Hazard Mitigation
- **Title**: Protecting Human Lives: Vernacular Safety Nudges
- **Headline**: Replacing toxic extraction practices with dignified handling.
- **Key Innovations**:
  - **8 Comic-Style Vernacular Guides**: Visual DOs and DONTs (Battery explosion prevention, toxic acid avoidance, personal protective gear).
  - **Contextual In-App Alerts**: CRT selection triggers an instant implosion and phosphor warning; burnt wire selection triggers toxic inhalation alerts.
  - **Field Research Framework**: Complete 20-collector interview guide and pilot validation kit ready for deployment.
- **Presenter Note**: *"We don't just facilitate transactions; we proactively prevent deadly practices like backyard CRT smashing and wire burning."*

---

### Slide 10: Scalability, Roadmap & Ministry Impact
- **Title**: Scalability Roadmap: Scaling Across India's Mineral Supply Chain
- **Headline**: From Maharashtra pilot to national circular economy standard.
- **Phase Milestones**:
  - **Phase 1 (Months 1–3)**: Pilot in Mumbai/Thane informal clusters (Dharavi, Kurla, Ulhasnagar) with 100 collectors & 10 authorized recyclers.
  - **Phase 2 (Months 4–6)**: Full SPCB EPR portal API integration and multi-state language rollout (Gujarati, Tamil, Telugu, Kannada, Bengali).
  - **Phase 3 (Months 7–12)**: Direct integration with JNARDDC critical mineral recovery initiatives (Lithium, Rare Earth Elements, Cobalt).
- **Call to Action**: *"Join us in bringing dignity, safety, and transparency to India's informal recycling champions."*
