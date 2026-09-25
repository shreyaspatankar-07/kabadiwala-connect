# Field Research Findings & Design Iterations Template

**Research Session**: ____________________ &nbsp;&nbsp;&nbsp;&nbsp; **Cluster Location**: ____________________  
**Facilitator(s)**: ____________________ &nbsp;&nbsp;&nbsp;&nbsp; **Sample Size ($N$)**: ______ Collectors / Aggregators

---

## 1. Executive Summary & Participant Demographics

| Participant ID | Age / Exp | Primary Scrap Focus | Daily Volume (kg) | Phone Type & RAM | Literacy Level |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `PART-001` | 38 yrs (12y exp) | Copper cables, PC boards, brass | 30–50 kg/day | Realme C11 (2GB RAM) | Low (Devanagari numerals only) |
| `PART-002` | 45 yrs (20y exp) | CRT TV scrap, appliance plastics | 60–100 kg/day | Samsung Galaxy J2 (2GB RAM) | Moderate Marathi literacy |
| `PART-003` | 29 yrs (6y exp) | Mobile batteries, laptops, PCBs | 20–35 kg/day | Redmi 9A (2GB RAM) | Moderate Hindi / Hindi oral |

---

## 2. Key Qualitative Insights & Behavioral Friction Points

### 2.1 Price Discovery & Middleman Exploitation
- **Observation**: 100% of participants reported that local middlemen deduct ₹15–₹40 per kg under vague claims of "dust, dirt, and moisture weight".
- **Reaction to Price Board**: Participants responded strongly to the 30-day sparkline and government rate indicator; hearing the price read aloud in Marathi gave them bargaining power when talking to buyers.

### 2.2 Audio & Low-Literacy Behavior
- **Observation**: Participants tapped the `SpeakerButton` multiple times (average 2.8 times per screen) before committing to button presses.
- **Audio Feedback**: Rapid speech speeds caused confusion. A speech rate of `0.45` with native Marathi intonation was found to be optimal.

### 2.3 Mistrust of Official Identification (Aadhaar / KYC)
- **Observation**: Participants explicitly stated they would uninstall any app that demands an Aadhaar card or PAN card due to fears of tax inspections or municipal harassment.
- **Validation of Data Minimization**: The 4-digit PIN with anonymous generated collector ID (`KC-C-XXXX`) received 100% approval in oral interviews.

---

## 3. Task Performance & Usability Metrics

| Usability Task | Completion Rate ($N=3$) | Avg Time-on-Task | Common Friction / Mis-taps Observed |
| :--- | :---: | :---: | :--- |
| **Task 1: Add E-Waste Lot** | 100% (3/3) | 48 sec | Initially tapped keyboard instead of number pad; reference weight cues (5kg bag icon) helped resolve confusion. |
| **Task 2: Check Price Board** | 100% (3/3) | 24 sec | Easily identified category pictorial icons (PCB, Cable, Battery). |
| **Task 3: Best Buyer Matching** | 100% (3/3) | 32 sec | Gold border on ranked #1 buyer made selection instantaneous. |
| **Task 4: View Earnings Ledger** | 100% (3/3) | 18 sec | Large green rupee font (`₹`) was immediately recognized. |
| **Task 5: View Safety Card** | 100% (3/3) | 36 sec | CRT implosion graphic was immediately understood without reading text. |

---

## 4. Design & Engineering Iterations Implemented

| # | Feedback from Field Session | Design / Code Change Implemented | Target File / Module |
| :---: | :--- | :--- | :--- |
| **1** | Collectors with calloused hands struggled with small buttons. | Increased minimum touch target on all category cards and buttons to **$\ge 56$dp** with tactile haptic response. | `mobile/lib/core/theme/app_theme.dart` |
| **2** | Default TTS speech rate was too fast for elderly collectors. | Reduced TTS speech rate from `0.55` to `0.45` for Marathi (`mr-IN`) and Hindi (`hi-IN`). | `mobile/lib/core/audio/audio_service.dart` |
| **3** | Collectors wanted visual reassurance that offline lots won't vanish. | Added a prominent clock icon badge on offline items that automatically switches to a green tick upon sync. | `mobile/lib/ui/widgets/sync_status_badge.dart` |
| **4** | Fear of accidental data sharing with outsiders. | Built a 1-tap plain language Privacy Card with spoken explanation and a complete local data purge button. | `mobile/lib/ui/screens/privacy_screen.dart` |

---

## 5. Next Steps & Ongoing Longitudinal Field Plan
1. Conduct follow-up usability evaluations with 10 additional scrap collectors in Thane and Pune scrap clusters.
2. Distribute laminated pictorial quick-reference flash cards with QR codes linking to the vernacular safety audio guides.
3. Track average earnings lift over a 30-day pilot deployment with 3 authorized recyclers.
