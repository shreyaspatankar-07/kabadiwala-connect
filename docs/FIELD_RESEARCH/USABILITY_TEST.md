# Usability Testing Protocol: Kabadiwala Connect

**Target Participants**: Informal Scrap Collectors with Low-to-Moderate Text Literacy  
**Hardware Environment**: Android 8.0+ smartphone (2GB RAM), patchy/offline network  
**Facilitator Role**: Silent Observer (give task orally in Marathi/Hindi, assist only if participant is stuck $> 45$ seconds).

---

## 🎯 1. Task-Based Testing Protocol (5 Core Tasks)

| Task # | Goal & Oral Prompt (मराठी / हिंदी) | Success Criteria | Time Target | Max Error Limit |
| :---: | :--- | :--- | :---: | :---: |
| **Task 1: Create a Lot** | *"तुमच्याकडे १० किलो तांब्याची वायर आहे. अ‍ॅपमध्ये फोटो काढून आणि १० किलो वजन टाकून नवीन माल नोंदवा."*  <br>*"10 kg copper wire ka photo lekar aur vajan daalkar naya maal jodiye."* | Photo taken, category selected, `10.0` entered on number pad, offline lot saved. | $< 60$ sec | $\le 1$ mistake |
| **Task 2: Check Price Board** | *"आज सर्किट बोर्डचा (PCB) सरकारी भाव काय आहे ते तपासा आणि स्पीकरवर ऐका."*  <br>*"Aaj circuit board ka bhav check kijiye aur speaker par suniye."* | Navigates to Price Board, taps PCB card, triggers audio read-out. | $< 35$ sec | $0$ mistakes |
| **Task 3: Find Best Buyer** | *"जवळचा अधिकृत रिसायकलर / खरेदीदार शोधा जो चांगला भाव देतो."*  <br>*"Paas ka authorized buyer dhundhiye jo achha rate deta hai."* | Opens Best Buyers list, selects ranked #1 verified recycler card. | $< 40$ sec | $\le 1$ mistake |
| **Task 4: View Earnings** | *"आजपर्यंत किती रुपयांची एकूण कमाई झाली आहे ते हिशोबात पहा."*  <br>*"Ab tak kitne rupaye ki kul kamai hui hai, hisab me dekhiye."* | Opens Earnings tab, locates large green balance digits. | $< 25$ sec | $0$ mistakes |
| **Task 5: View Safety Card** | *"बॅटरी हाताळताना काय धोका आहे आणि काय काळजी घ्यावी ते तपासा."*  <br>*"Battery sambhalne ka khatra aur niyam dekhiye."* | Opens Safety tab, opens Battery card, views DOs/DONTs, taps 'I Understood'. | $< 45$ sec | $\le 1$ mistake |

---

## 📝 2. Field Observation Sheet Template

**Participant ID**: `PART-00___` &nbsp;&nbsp;&nbsp;&nbsp; **Date**: __________________ &nbsp;&nbsp;&nbsp;&nbsp; **Location**: __________________  
**Primary Language**: [ ] Marathi / [ ] Hindi / [ ] Other &nbsp;&nbsp;&nbsp;&nbsp; **Smartphone Experience**: [ ] Daily / [ ] Occasional / [ ] None

| Task # | Completed Independently? | Time Taken (sec) | # of Mis-taps / Errors | Verbal Comments / Audio Usage |
| :--- | :---: | :---: | :---: | :--- |
| **Task 1 (Add Lot)** | [ ] Yes / [ ] Assisted / [ ] Failed | ______ s | ______ | |
| **Task 2 (Price Board)** | [ ] Yes / [ ] Assisted / [ ] Failed | ______ s | ______ | |
| **Task 3 (Best Buyers)** | [ ] Yes / [ ] Assisted / [ ] Failed | ______ s | ______ | |
| **Task 4 (Earnings Ledger)** | [ ] Yes / [ ] Assisted / [ ] Failed | ______ s | ______ | |
| **Task 5 (Safety Card)** | [ ] Yes / [ ] Assisted / [ ] Failed | ______ s | ______ | |

---

## 😊 3. Pictorial SUS Questionnaire (चित्रात्मक समाधान प्रश्नावली)

*Note: Instead of complex Likert text scales, show 3 distinct visual face cards (😃 आनंदी / 😐 मध्यम / 🙁 कठीण) to the participant.*

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. हे अ‍ॅप वापरणे किती सोपे वाटले? (App kitna aasan laga?)                  │
│    [ 😃 खूप सोपे / Easy ]       [ 😐 मध्यम / OK ]        [ 🙁 कठीण / Hard ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ 2. स्पीकरवरील आवाज आणि सूचना समजल्या का? (Speaker ki aawaz samajh aayi?)    │
│    [ 😃 १००% स्पष्ट / Clear ]   [ 😐 थोडे समजले / OK ]   [ 🙁 नाही / Unclear]│
├─────────────────────────────────────────────────────────────────────────────┤
│ 3. बटणे आणि अक्षरे व्यवस्थित दिसली का? (Buttons & symbols clear?)           │
│    [ 😃 छान / Clear ]           [ 😐 ठीक / Average ]     [ 🙁 लहान / Small ]│
├─────────────────────────────────────────────────────────────────────────────┤
│ 4. दररोज भंगार विकण्यासाठी हे वापराल का? (Will you use this daily?)         │
│    [ 😃 नक्की वापरणार / Yes ]  [ 😐 विचार करेन / Maybe ] [ 🙁 नाही / No ]   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 4. Usability Benchmark Evaluation Criteria
- **Task Completion Rate (TCR)**: $\ge 85\%$ across all 5 tasks.
- **Average Time-on-Task (ATT)**: $\le 45$ seconds per workflow.
- **Audio Reliance Metric**: Measured percentage of taps preceded by Speaker Button usage ($\ge 60\%$ in low-literacy cohort).
- **Zero-Reading Capability**: Can a participant complete the Add Lot flow relying solely on icons and audio feedback? (Pass/Fail).
