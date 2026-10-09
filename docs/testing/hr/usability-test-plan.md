# Velune Carpool Platform - Usability Testing Plan: HR Module

**Course:** IT3060 Human Computer Interaction (Milestone 03)  
**Group:** WE_162  
**Module:** HR / Corporate & System Integration  
**Lead Evaluator:** IT23555112 (Amanda Jayawardena)  
**Date:** October 2026  

---

## 1. Usability Testing Objectives

The primary objective of this usability evaluation is to determine how efficiently, effectively, and satisfactorily corporate administrators and facilities leads can operate the Velune HR Mobility Hub to manage carpooling programs, allocate priority parking, and generate compliance-grade sustainability reports.

Specific evaluation goals:
1. Measure **Task Completion Rate (TCR)** across core administrative operations without facilitator intervention.
2. Quantify **Time on Task (ToT)** to verify adherence to `NFR-01` (low-friction interface).
3. Identify cognitive friction, layout ambiguities, or input validation roadblocks.
4. Measure subjective usability via post-task **Single Ease Question (SEQ)** and post-test **System Usability Scale (SUS)**.

---

## 2. Participant Profiles & Sample Size

In alignment with Nielsen's usability testing heuristic (5 users discover $> 80\%$ of usability flaws), 5 participants were selected representing target corporate roles:

| Participant ID | Role / Background | Prior Carpooling App Experience | Mobile OS Proficiency |
| :--- | :--- | :--- | :--- |
| **P-01** | Assistant HR Manager (Corporate Facilities) | Moderate (Uber/PickMe Commute) | High (Android 14) |
| **P-02** | Sustainability & ESG Compliance Officer | Low (Enterprise Desktop Tools) | Moderate (iOS) |
| **P-03** | Campus Facilities Coordinator | Low | High (Android 13) |
| **P-04** | People Operations Lead | High | High (Android 14) |
| **P-05** | Administrative Facilities Executive | None | Moderate (Android 12) |

---

## 3. Test Methodology & Environment

- **Format:** In-person moderated usability test.
- **Device:** Real Android smartphone running Velune Flutter mobile application (`velune_app`) connected to local Laravel Sanctum backend.
- **Protocol:**
  - Briefing & consent: 3 minutes.
  - Think-aloud execution of 8 task scenarios: 20-25 minutes.
  - Post-task Single Ease Question (SEQ, 1 to 7) after each scenario.
  - Post-test System Usability Scale (SUS, 10 items) questionnaire: 5 minutes.
  - Debriefing & qualitative feedback: 5 minutes.

---

## 4. Standardized Task Scenarios

### Scenario 1 (TS-01): Dashboard Overview & Key Mobility Metrics
- **Context:** You have just arrived at the office and opened Velune to check corporate commuting performance for the month.
- **Task:** Locate the total kilograms of CO2 avoided this month and the number of active carpoolers on the campus dashboard.
- **Success Criteria:** Participant identifies `325 kg` (or current saved total) and `86` active carpoolers without leaving the screen.

### Scenario 2 (TS-02): Adjust Campus Decarbonization Target
- **Context:** Corporate facilities has raised this quarter's decarbonization target from 78% to 85%.
- **Task:** Update the campus decarbonization target to 85% and confirm that the goal is saved.
- **Success Criteria:** Tap the target badge in the hero card, enter `85` in the dialog, tap `Save Target`, and observe the updated percentage.

### Scenario 3 (TS-03): Review & Dismiss Corporate Alert
- **Context:** A facility maintenance alert has been resolved and should be cleared from your notification feed.
- **Task:** Open the Corporate Alerts drawer from the AppBar and dismiss the first alert item.
- **Success Criteria:** Tap the notification bell, locate the alert, tap the dismiss/delete icon, and confirm the item disappears.

### Scenario 4 (TS-04): Log New Weekly Carbon Offset Entry
- **Context:** Facilities has calculated the carbon savings from last week's campus carpool trips.
- **Task:** Navigate to the CO2 Reduction Report and log a new entry: label "Week 5 Audit", 95 kg saved, period "Oct 22 - Oct 28".
- **Success Criteria:** Tap `CO2 Log` or bottom navigation, tap `Log Entry`, fill all 3 fields, and tap `Add CO2 Record`.

### Scenario 5 (TS-05): Allocate Priority Charging Bay to Carpool Cohort
- **Context:** A new verified 4-person carpooling cohort from Kandy Corridor requires a reserved parking spot in Deck B.
- **Task:** Navigate to Parking Allocation and allocate bay `B-28` to "Group Test QA" with 4 riders.
- **Success Criteria:** Tap `Parking`, tap `Allocate Bay`, enter cohort details and bay code `B-28`, and tap `Confirm Spot Allocation`.

### Scenario 6 (TS-06): Pin High-Adoption Commuter Corridor
- **Context:** A specific commuter route has shown high adoption and needs to be pinned to the executive analytics view.
- **Task:** Open Carpool Statistics and pin route "Panadura Coastal Express" with 50 daily riders and badge "High EV Share".
- **Success Criteria:** Tap `Statistics`, tap `Pin Route`, input corridor details, tap `Pin to Dashboard`, and verify route appears under Top Performing Routes.

### Scenario 7 (TS-07): Generate & Download Monthly ESG Audit Report
- **Context:** The board of directors requires an official ISO 14064-1 compliant monthly ESG carbon audit document.
- **Task:** Navigate to Monthly Reports, generate a report for "November 2026 Audit" (410 kg, 85%), and view the rendered document in the PDF viewer.
- **Success Criteria:** Tap `Reports`, tap `Generate New`, submit details, and confirm the PDF Report Viewer screen displays the verified document seal.

### Scenario 8 (TS-08): Create Corporate Incentive Program
- **Context:** HR is launching an Expressway Toll Grant reimbursing commuters who carpool 3+ times weekly.
- **Task:** Open Corporate Incentives and add program "Expressway Toll Grant" with monthly budget of 40,000 LKR.
- **Success Criteria:** Tap `Incentives`, tap `Add Program`, fill title and budget, and submit.

---

## 5. Metrics & Analysis Plan

1. **Task Completion Rate (TCR):**
   $$\text{TCR} = \frac{\text{Completed Tasks}}{\text{Total Task Attempts}} \times 100\%$$
   *Target: $> 90\%$.*

2. **Time on Task (ToT):**
   Measured from when the facilitator finishes reading the scenario until the participant completes the target action.  
   *Target: Average ToT $< 40$ seconds per scenario.*

3. **Single Ease Question (SEQ):**
   "Overall, how difficult or easy did you find this task?" (1 = Very Difficult, 7 = Very Easy).  
   *Target: Average SEQ $\ge 5.5 / 7$.*

4. **System Usability Scale (SUS):**
   Standard 10-item instrument calculated via `mobile/tool/sus_score.dart`.  
   *Target: Average SUS Score $\ge 68.0$ (Grade C or above; target A/B range $\ge 75.0$).*
