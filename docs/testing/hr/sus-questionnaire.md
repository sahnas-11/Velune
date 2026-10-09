# Velune Carpool Platform - System Usability Scale (SUS) Questionnaire

**Instrument:** System Usability Scale (Brooke, 1996)  
**Target Module:** HR / Corporate & System Integration  
**Evaluation:** HCI Milestone 03 Usability Study  

---

## Instructions for Participants

Please indicate your level of agreement with each of the following 10 statements regarding your experience using the **Velune HR Mobility Hub** application. 

Rate each statement on a 5-point scale:
- **1:** Strongly Disagree
- **2:** Disagree
- **3:** Neutral
- **4:** Agree
- **5:** Strongly Agree

Mark your immediate reaction without overthinking each item.

---

## The 10 Standard SUS Statements

| # | Statement | Rating (1 - 5) |
| :---: | :--- | :---: |
| **Q1** | I think that I would like to use this system frequently. | [ &nbsp; ] |
| **Q2** | I found the system unnecessarily complex. | [ &nbsp; ] |
| **Q3** | I thought the system was easy to use. | [ &nbsp; ] |
| **Q4** | I think that I would need the support of a technical person to be able to use this system. | [ &nbsp; ] |
| **Q5** | I found the various functions in this system were well integrated. | [ &nbsp; ] |
| **Q6** | I thought there was too much inconsistency in this system. | [ &nbsp; ] |
| **Q7** | I would imagine that most people would learn to use this system very quickly. | [ &nbsp; ] |
| **Q8** | I found the system very cumbersome to use. | [ &nbsp; ] |
| **Q9** | I felt very confident using the system. | [ &nbsp; ] |
| **Q10** | I needed to learn a lot of things before I could get going with this system. | [ &nbsp; ] |

---

## Scoring Methodology (Brooke, 1996)

1. For **odd-numbered items** (Q1, Q3, Q5, Q7, Q9):
   $$\text{Score Contribution} = \text{Scale Value} - 1$$
2. For **even-numbered items** (Q2, Q4, Q6, Q8, Q10):
   $$\text{Score Contribution} = 5 - \text{Scale Value}$$
3. Multiply the sum of all score contributions by **2.5** to obtain the overall SUS score ranging from **0 to 100**.

$$\text{SUS Score} = 2.5 \times \left( \sum_{i \in \{1,3,5,7,9\}} (Q_i - 1) + \sum_{j \in \{2,4,6,8,10\}} (5 - Q_j) \right)$$

---

## Interpretation Benchmark

| SUS Score Range | Grade | Adjective Rating | Usability Interpretation |
| :--- | :---: | :--- | :--- |
| **$\ge 84.1$** | **A+** | Best Imaginable | Outstanding user experience; world-class product. |
| **$80.8 - 84.0$** | **A** | Excellent | Highly intuitive and frictionless. |
| **$74.1 - 80.7$** | **B** | Good | Above average; comfortable for regular operation. |
| **$68.0 - 74.0$** | **C** | OK / Average | Industry benchmark threshold (68.0). |
| **$51.7 - 67.9$** | **D** | Poor | Noticeable usability hurdles requiring remediation. |
| **$< 51.7$** | **F** | Worst Imaginable | Unacceptable usability failure. |

---

## Running the Automated Calculator

Once responses are recorded in `docs/testing/hr/sus-responses.csv`, run:

```bash
cd mobile
dart run tool/sus_score.dart
```
