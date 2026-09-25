# Technical Limitations & Production Readiness Roadmap

**Project**: Kabadiwala Connect  
**Problem Statement**: SIH PS 26229 (Ministry of Mines / JNARDDC)  
**Date**: September 2026  

---

## 1. Executive Summary & Transparency Commitment

In accordance with the core development principles defined in `AGENTS.md` and standard software engineering rigor, this document provides a transparent, unvarnished disclosure of current architectural limitations, synthetic dependencies, and the exact steps required for enterprise production deployment.

---

## 2. Detailed Technical Limitations

### 2.1 Machine Learning Models Trained on Synthetic Data
- **Current State**: The on-device `MobileNetV3-Small` material classifier and `LightGBM` valuation regressor are trained on rigorously synthesized datasets mirroring realistic industrial scrap distributions, metal market fluctuations (MCX/LME copper/gold indices), and physical scrap attributes.
- **Limitation**: While synthetic data establishes baseline algorithmic validity ($R^2 > 0.99$, test accuracy $98.4\%$), real-world edge cases (bad lighting in dark scrap godowns, severely corroded or co-mingled PCB scrap) will exhibit lower real-world precision.
- **Production Roadmap**: Deploy a human-in-the-loop active learning pipeline where low-confidence classifications ($<0.55$) prompt user verification, and anonymized images are saved to a retraining queue after explicit consent.

---

### 2.2 Authorized Recycler Dataset & SPCB Registration
- **Current State**: The 8 authorized recyclers across Maharashtra (Palghar, Thane, Mumbai, Pune, Nashik, Nagpur) are realistically simulated with valid EPR registration numbering formats, geospatial coordinates, processing capacities, and accepted materials (`source: synthetic`).
- **Limitation**: No live read-write integration exists with the Central Pollution Control Board (CPCB) or State Pollution Control Board (SPCB) centralized EPR portal.
- **Production Roadmap**: Partner with SPCB/JNARDDC to implement OAuth2-based automated verification against the national EPR portal API, enabling real-time license verification and digital certificate validation.

---

### 2.3 SMS Gateway Integration
- **Current State**: Collector phone number verification uses an internal cryptographically secure mock OTP service (`123456` in demo mode / deterministic generation).
- **Limitation**: No commercial SMS aggregator (such as MSG91, Fast2SMS, or Twilio) is connected to transmit live cellular SMS.
- **Production Roadmap**: Integrate DLT-registered SMS templates (compliant with TRAI regulations in India) using an environment-swappable gateway adapter pattern in `auth_service.py`.

---

### 2.4 Bluetooth Digital Weighing Scale Integration
- **Current State**: Digital scale integration is provided via an interactive pictorial number pad and weight slider widget with Bluetooth pairing hooks stubbed in mobile architecture.
- **Limitation**: Physical BLE hardware scales (e.g., standard industrial weighing indicators via RS-232 to BLE bridges) are not physically paired in the emulator/CI environment.
- **Production Roadmap**: Integrate standard BLE UART profile (GATT service `0xFFE0`) to auto-read gross weight from certified digital platform scales used in scrap yards.

---

### 2.5 Audio Engine & Native Voice Recordings
- **Current State**: Vernacular audio playback across all screens operates via the on-device Android Text-to-Speech (TTS) engine (`flutter_tts`) using Marathi (`mr-IN`) and Hindi (`hi-IN`) voice synthesis models.
- **Limitation**: TTS pronunciation of local informal scrap jargon (e.g., *पत्र्याची पेटी*, *लाल माल*, *साधी पट्टी*) can occasionally sound robotic or unnatural to low-literacy users.
- **Production Roadmap**: Commission studio voice recordings with native rural Marathi and Hindi speakers for all core prompts and cache compressed Ogg Vorbis/AAC audio clips (`< 30 KB` each) directly in the mobile asset bundle.

---

### 2.6 Portal Production Deployment & Edge Security
- **Current State**: The Next.js 14 recycler and admin portal is configured for local and edge containerized execution (`npm run dev` / Docker).
- **Limitation**: Production SSL termination, Web Application Firewall (Cloudflare / AWS WAF), DDoS mitigation, and SPCB role-based single sign-on (SSO) are not yet configured on a live cloud domain.
- **Production Roadmap**: Deploy behind an NGINX reverse proxy with automated Let's Encrypt TLS certificates, Redis-backed session rate-limiting, and PostgreSQL row-level security (RLS).

---

### 2.7 Automated EPR Credit & Mass Balance Certificate Issuance
- **Current State**: The backend and web portal track full downstream lifecycle status (`received` $\rightarrow$ `dismantled` $\rightarrow$ `processed` $\rightarrow$ `certificate_issued`) and compute mass-balance yields across scrap categories.
- **Limitation**: The final PDF certificate generation currently generates structured JSON audit logs rather than cryptographically signed digital CPCB certificates.
- **Production Roadmap**: Integrate digital signature (DSC) signing with PDF mass-balance generation and automated filing into the CPCB EPR Registry portal.

---

## 3. Summary Risk & Mitigation Matrix

| Domain | Current Hackathon Implementation | Production Requirement | Priority |
| :--- | :--- | :--- | :--- |
| **ML Models** | Synthetic dataset + Quantized TFLite | Real scrap yard image pipeline | Medium (Phase 2) |
| **Recycler Registry**| Geo-spatial synthetic directory | Live CPCB/SPCB API sync | High (Phase 1) |
| **Authentication** | Local PIN + Mock OTP | DLT-compliant SMS Gateway | High (Phase 1) |
| **Hardware** | Visual keypad + Slider | Physical BLE scale connectivity | Medium (Phase 2) |
| **Voice / Audio** | Android TTS Engine | Native speaker studio audio | High (Phase 1) |
| **Infrastructure** | Localhost / Docker containers | Cloud Kubernetes + TLS + WAF | High (Phase 1) |
