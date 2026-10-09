# Velune Carpool Platform - Test Plan: HR / Corporate & System Integration Module

**Course:** IT3060 Human Computer Interaction  
**Milestone:** 03 - Implementation, Functional & Usability Evaluation  
**Group:** WE_162  
**Module:** HR / Corporate & System Integration  
**Lead Developer & Evaluator:** IT23555112 (Amanda Jayawardena)  
**Target Branch:** `feature/hr-corporate`  
**Date:** October 2026  

---

## 1. Introduction and Objectives

This test plan defines the testing strategy, environment specification, test cases, and evaluation protocols for the **HR / Corporate & System Integration** module of the **Velune** enterprise carpooling system. 

The primary objectives are:
1. Verify functional compliance of all corporate mobility, parking allocation, and sustainability management operations against architectural specifications.
2. Ensure strict adherence to non-functional security and data privacy mandates (specifically `NFR-04` regarding commuter anonymity).
3. Confirm end-to-end integration across Laravel Sanctum backend endpoints and Flutter client interfaces.
4. Establish usability baselines using standard task completion metrics and the System Usability Scale (SUS) with 5+ test participants.

---

## 2. Requirements in Scope

| Req ID | Requirement Description | Success Verification Metric |
| :--- | :--- | :--- |
| **FR-05** | Monthly CO2 reduction reports and verified parking allocation for corporate carpool cohorts. | Exportable ISO 14064-1 compliant monthly audits and real-time Deck B bay assignment/reassignment. |
| **NFR-04** | Privacy & Anonymity: HR screens display aggregated and anonymized metrics only. No commuter names, emails, phone numbers, or personal identifying tokens are surfaced. | Zero commuter PII rendered in API payloads, logs, or UI views. Cohorts referenced only by aggregate titles (e.g., "Group Alpha"). |
| **NFR-01** | Low-friction UI: Efficient navigation flow requiring minimal taps to perform critical managerial actions. | Single Ease Question (SEQ) score $\ge 5.5 / 7$; average task duration under 45 seconds. |

---

## 3. System Architecture & Test Environments

### 3.1 Backend Test Environment
- **Framework:** Laravel 11.x on PHP 8.2+
- **Test Runner:** PHPUnit 11.5 / Artisan Test Runner
- **Authentication:** Laravel Sanctum Token Authentication & Role-Based Access Control (`role.hr`)
- **Database:** MySQL `velune_test` (port 3306, utf8mb4) running in isolation from development database `velune_db`
- **Configuration:** Dedicated `backend/phpunit.xml` configuring `DB_DATABASE=velune_test` with transactional rollbacks (`RefreshDatabase`)

### 3.2 Mobile Client Test Environment
- **Framework:** Flutter 3.x / Dart 3.x
- **App Package:** `velune_app`
- **State Architecture:** Reactive ChangeNotifier (`HrState`) & Riverpod state isolation
- **Test Harness:** `flutter_test` widget testing engine with simulated responsive viewport (1080x2400 mobile aspect ratio)
- **Physical Device:** Real Android 14 handset (`R7AWC03MG6H`) connected over USB with ADB reverse bridge (`adb reverse tcp:8000 tcp:8000`)

---

## 4. Role-Based Access Control (RBAC) Matrix

All HR endpoints under `/api/hr/*` are guarded by `auth:sanctum` and `EnsureHrRole` middleware (`role.hr`).

| User Persona | Email / Identity | Assigned Role | Access to `/api/hr/*` | Expected HTTP Response |
| :--- | :--- | :--- | :--- | :--- |
| **Amanda Jayawardena** | `amanda@velune.com` | `hr` | **Authorized** | `200 OK` / `201 Created` |
| **Corporate Commuter** | `commuter@velune.com` | `commuter` | **Forbidden** | `403 Forbidden` |
| **Fleet Mechanic** | `mechanic@velune.com` | `mechanic` | **Forbidden** | `403 Forbidden` |
| **Unauthenticated Guest** | None | None | **Unauthorized** | `401 Unauthorized` |

---

## 5. Scope of Screen Implementations

The module encompasses 6 dedicated mobile screens and associated RESTful controllers:

```
[HR Mobility Hub]
   │
   ├── 1. HR Dashboard (dashboard_screen.dart)
   │      - Fleet Decarbonization KPI progress & campus target editing (CRUD: Update)
   │      - Corporate Alert dismiss & notification clear (CRUD: Delete)
   │      - Direct module navigation shortcuts
   │
   ├── 2. CO2 Reduction Report (co2_report_screen.dart)
   │      - Weekly carbon savings records (CRUD: Create, Read)
   │      - Validation against non-positive offsets
   │      - ISO 14064-1 verification banner & PDF preview launch
   │
   ├── 3. Parking Allocation (parking_screen.dart)
   │      - Deck B Priority Charging Bay assignments (CRUD: Create, Read)
   │      - Bay code reassignments (CRUD: Update)
   │      - Confirmation dialog & spot release (CRUD: Delete)
   │
   ├── 4. Carpool Statistics (statistics_screen.dart)
   │      - Commuter Modal Split Donut Visualizer (44% Carpool, 28% Transit, 18% Single, 10% Active)
   │      - 6-Month Carpool Adoption Growth line visualizer (+24% MoM)
   │      - Route corridor pinning & unpinning (CRUD: Create, Read, Delete)
   │
   ├── 5. Monthly ESG Reports (reports_screen.dart)
   │      - Generated audit report history (CRUD: Read)
   │      - New monthly audit generation modal (CRUD: Create)
   │      - Audit archive purge with reactive UI update (CRUD: Delete)
   │      - Automated corporate dispatch email toggle (CRUD: Update)
   │      - Native PDF Report Viewer (pdf_report_viewer_screen.dart)
   │
   └── 6. Corporate Incentives (incentives_screen.dart)
          - Active fleet incentive programs (CRUD: Read)
          - Program creation modal with budget validation (CRUD: Create)
          - Budget & description update dialog (CRUD: Update)
          - Active/Paused lifecycle state toggles (CRUD: Update)
          - Program decommissioning (CRUD: Delete)
```

---

## 6. Test Levels & Methodology

### 6.1 Automated Backend Feature Tests
PHPUnit tests reside in `backend/tests/Feature/Hr/` and cover:
- HTTP status codes (200, 201, 401, 403, 422).
- Request validation rules (e.g. required fields, integer constraints, non-negative numbers).
- Database persistence and attribute mutation in `velune_test`.
- `NFR-04` compliance assertions confirming absence of user names, emails, and phone numbers in response payloads.
- Binary stream verification for PDF report exports (`application/pdf`).

### 6.2 Automated Mobile Widget Tests
Flutter widget tests in `mobile/test/hr_corporate/` evaluate:
- Full widget tree layout and typography rendering.
- State mutation responsiveness via `ListenableBuilder` and `HrState`.
- Modal dialog opening, form field entry, and input rejection on invalid data.
- User confirmation flows before destructive deletions.
- Stack navigation and parameter passing to `PdfReportViewerScreen`.

### 6.3 Usability Testing (HCI)
Conducted in accordance with ISO 9241-11 guidelines:
- 5 participants executing 8 standardized task scenarios.
- Quantified by Task Completion Rate (TCR), Time on Task (ToT), Single Ease Question (SEQ), and System Usability Scale (SUS).

---

## 7. Pass / Fail and Defect Severity Criteria

### 7.1 Pass Criteria
- **100% of automated tests pass:** 32/32 PHPUnit tests and 28/28 Flutter widget tests green.
- **Zero static analysis warnings:** `flutter analyze` reports 0 issues.
- **Average SUS Score $\ge 68.0$:** Exceeds the accepted industry usability benchmark.
- **Strict Privacy Compliance:** Zero PII leakage detected across any HR view or response.

### 7.2 Defect Severity Classification
- **Critical (P1):** Security vulnerability, role bypass, crash on startup, or commuter PII leakage (`NFR-04` violation).
- **Major (P2):** CRUD operation fails to persist, UI overflow blocking user interaction, or unhandled 500 error.
- **Moderate (P3):** Validation message wording unclear, layout clipping on extreme aspect ratios, or minor styling deviation.
- **Minor (P4):** Cosmetic padding anomaly, minor typography weight inconsistency.
