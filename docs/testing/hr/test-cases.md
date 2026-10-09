# Velune Carpool Platform - Test Cases Specification: HR Module

**Course:** IT3060 HCI Milestone 03  
**Module:** HR / Corporate & System Integration  
**Owner:** IT23555112 (Amanda Jayawardena)  
**Total Test Cases:** 56 (32 Automated Backend Feature, 28 Automated Mobile Widget, 12 Manual Device Verification)  
**Pass Rate:** 100% Passing  

---

## Group 1: Role-Based Access Control & Privacy Compliance (TC-HR-001 - TC-HR-004)

### TC-HR-001: Unauthenticated Guest Blocked from HR API
- **Endpoint:** `GET /api/hr/dashboard`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** Client does not supply `Authorization: Bearer` header.
- **Test Steps:**
  1. Send HTTP GET request to `/api/hr/dashboard` without credentials.
- **Expected Result:** HTTP 401 Unauthorized returned with unauthenticated JSON message.
- **Status:** **PASS**

### TC-HR-002: Commuter Role Forbidden from Accessing HR Endpoints
- **Endpoint:** `GET /api/hr/dashboard`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** User authenticated with role `commuter`.
- **Test Steps:**
  1. Generate Sanctum token for commuter user.
  2. Send HTTP GET request to `/api/hr/dashboard`.
- **Expected Result:** Middleware `role.hr` intercepts request and returns HTTP 403 Forbidden.
- **Status:** **PASS**

### TC-HR-003: Mechanic Role Forbidden from Accessing HR Endpoints
- **Endpoint:** `GET /api/hr/dashboard`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** User authenticated with role `mechanic`.
- **Test Steps:**
  1. Generate Sanctum token for mechanic user.
  2. Send HTTP GET request to `/api/hr/dashboard`.
- **Expected Result:** Middleware `role.hr` intercepts request and returns HTTP 403 Forbidden.
- **Status:** **PASS**

### TC-HR-004: NFR-04 Aggregated Data Commuter Anonymity Verification
- **Endpoint:** All `/api/hr/*` routes and mobile screens
- **Execution Type:** Automated Feature + Widget Assertions
- **Preconditions:** Authenticated as HR Manager (`amanda@velune.com`).
- **Test Steps:**
  1. Inspect payload JSON responses across `/api/hr/dashboard`, `/api/hr/parking/allocations`, and `/api/hr/reports`.
  2. Assert absence of keys `commuter_name`, `email`, `phone`, `nic`, and individual user IDs.
- **Expected Result:** Data strictly aggregated (e.g. `rider_count`, `group_name`, `total_co2_kg`). Zero PII present.
- **Status:** **PASS**

---

## Group 2: HR Dashboard (TC-HR-005 - TC-HR-012)

### TC-HR-005: HR Dashboard Data Retrieval & Aggregated Metrics
- **Screen:** `DashboardScreen` / `GET /api/hr/dashboard`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** Seeded corporate metrics in database.
- **Test Steps:**
  1. Send GET request with HR Sanctum token.
- **Expected Result:** HTTP 200 returned with JSON keys: `campus_target_pct`, `total_co2_avoided_kg`, `active_carpoolers`, `single_cars_reduced`, and `available_bays`.
- **Status:** **PASS**

### TC-HR-006: HR Dashboard Widget Rendering & KPI Display
- **Screen:** `DashboardScreen`
- **Execution Type:** Automated Mobile Widget Test (`dashboard_widget_test.dart` TC-HR-W01)
- **Preconditions:** Flutter test environment initialized with `HrState`.
- **Test Steps:**
  1. Pump `DashboardScreen`.
  2. Query finding `Amanda Jayawardena`, `Fleet Decarbonization`, and KPI cards.
- **Expected Result:** Hero card, decarbonization percentage, and key mobility metric cards render without layout overflow.
- **Status:** **PASS**

### TC-HR-007: Update Campus Decarbonization Target (CRUD: Update)
- **Endpoint:** `PUT /api/hr/settings/target`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** Existing target value is 78%.
- **Test Steps:**
  1. Send PUT request with payload `{"campus_target_percent": 85}`.
- **Expected Result:** HTTP 200 returned, database column updated to 85.
- **Status:** **PASS**

### TC-HR-008: Campus Decarbonization Target Range Validation
- **Endpoint:** `PUT /api/hr/settings/target`
- **Execution Type:** Automated Backend Feature Test (`DashboardTest.php`)
- **Preconditions:** Authenticated HR user.
- **Test Steps:**
  1. Send PUT request with payload `{"campus_target_percent": 150}` (> 100%).
- **Expected Result:** HTTP 422 Unprocessable Entity returned with validation errors.
- **Status:** **PASS**

### TC-HR-009: In-App Dialog Campus Target Update Flow
- **Screen:** `DashboardScreen`
- **Execution Type:** Automated Mobile Widget Test (`dashboard_widget_test.dart` TC-HR-W04)
- **Preconditions:** `DashboardScreen` mounted.
- **Test Steps:**
  1. Tap on target percentage card.
  2. Verify dialog `Edit Campus Target %` opens.
  3. Enter `85` in text field and tap `Save Target`.
- **Expected Result:** Dialog dismisses, state updates to 85%, and SnackBar confirms update.
- **Status:** **PASS**

### TC-HR-010: Dismiss Corporate Notification Alert (CRUD: Delete)
- **Screen:** `DashboardScreen` (Notification Bottom Sheet)
- **Execution Type:** Automated Mobile Widget Test (`dashboard_widget_test.dart` TC-HR-W02)
- **Preconditions:** 3 active corporate alerts present in state.
- **Test Steps:**
  1. Tap notification bell icon in AppBar.
  2. Bottom sheet `Corporate Alerts` opens.
  3. Tap delete trash icon on first alert.
- **Expected Result:** Notification deleted from state (`notifications.length` decrements by 1).
- **Status:** **PASS**

### TC-HR-011: Mark All Notifications Read
- **Screen:** `DashboardScreen`
- **Execution Type:** Automated Widget + Manual Device Test
- **Preconditions:** Multiple unread alerts in state.
- **Test Steps:**
  1. Open notification bottom sheet.
  2. Tap `Mark All Read`.
- **Expected Result:** Unread badge counter in AppBar disappears; notification backgrounds transition to read state.
- **Status:** **PASS**

### TC-HR-012: Dashboard Quick Action Navigation
- **Screen:** `DashboardScreen`
- **Execution Type:** Automated Mobile Widget Test (`dashboard_widget_test.dart` TC-HR-W03)
- **Preconditions:** `DashboardScreen` initialized with callback tracker.
- **Test Steps:**
  1. Tap quick action button `CO2 Log`.
- **Expected Result:** Callback `onNavigateTab(1)` fired, switching active tab to CO2 Reduction Report.
- **Status:** **PASS**

---

## Group 3: CO2 Reduction Report (TC-HR-013 - TC-HR-020)

### TC-HR-013: Retrieve CO2 Offset Records & Equivalencies
- **Endpoint:** `GET /api/hr/co2/summary`
- **Execution Type:** Automated Backend Feature Test (`Co2ReportTest.php`)
- **Preconditions:** Database contains monthly carpool trip logs.
- **Test Steps:**
  1. Send GET request to `/api/hr/co2/summary`.
- **Expected Result:** HTTP 200 returned containing cumulative kg saved, tree equivalent count, and gasoline gallon offsets.
- **Status:** **PASS**

### TC-HR-014: CO2 Report Screen Rendering & Environmental Badges
- **Screen:** `Co2ReportScreen`
- **Execution Type:** Automated Mobile Widget Test (`co2_report_widget_test.dart` TC-HR-W21)
- **Preconditions:** `HrState` initialized with sample records.
- **Test Steps:**
  1. Pump `Co2ReportScreen`.
- **Expected Result:** Displays `CO2 Reduction Report`, `14 Trees`, `1,240 mi`, and circular progress arc.
- **Status:** **PASS**

### TC-HR-015: Log Weekly Carbon Offset Entry (CRUD: Create)
- **Endpoint:** `POST /api/hr/co2/records`
- **Execution Type:** Automated Backend Feature Test (`Co2ReportTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"label": "Week 4 Fleet Audit", "kg_saved": 92.5, "period_range": "Oct 22 - Oct 28"}`.
- **Expected Result:** HTTP 201 Created returned; record persisted in `velune_test`.
- **Status:** **PASS**

### TC-HR-016: Reject Zero or Negative Carbon Offset Values
- **Endpoint:** `POST /api/hr/co2/records`
- **Execution Type:** Automated Backend Feature Test (`Co2ReportTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"kg_saved": -10.0}`.
- **Expected Result:** HTTP 422 Unprocessable Entity returned with validation error on `kg_saved`.
- **Status:** **PASS**

### TC-HR-017: Mobile Modal Validation on Zero CO2 Input
- **Screen:** `Co2ReportScreen`
- **Execution Type:** Automated Mobile Widget Test (`co2_report_widget_test.dart` TC-HR-W22)
- **Preconditions:** `Co2ReportScreen` mounted.
- **Test Steps:**
  1. Tap `Log Entry`.
  2. Enter `0` in kg offset field and tap `Add CO2 Record`.
- **Expected Result:** Form rejected; state record count does not increase.
- **Status:** **PASS**

### TC-HR-018: Add Weekly CO2 Record In-App
- **Screen:** `Co2ReportScreen`
- **Execution Type:** Automated Mobile Widget Test (`co2_report_widget_test.dart` TC-HR-W23)
- **Preconditions:** `Co2ReportScreen` mounted.
- **Test Steps:**
  1. Tap `Log Entry`.
  2. Input label `Week 5 Test`, kg `95`, date range `Oct 22 - Oct 28`.
  3. Tap `Add CO2 Record`.
- **Expected Result:** Bottom sheet closes, new entry renders in weekly audit list, state total updates.
- **Status:** **PASS**

### TC-HR-019: Launch PDF Viewer from CO2 Banner
- **Screen:** `Co2ReportScreen` -> `PdfReportViewerScreen`
- **Execution Type:** Automated Mobile Widget Test (`co2_report_widget_test.dart` TC-HR-W24)
- **Preconditions:** Device initialized.
- **Test Steps:**
  1. Tap banner `Download Official ESG Report (PDF)`.
- **Expected Result:** Screen pushes `PdfReportViewerScreen`, displaying verified ISO 14064-1 badge and audit header.
- **Status:** **PASS**

### TC-HR-020: Return Navigation from PDF Viewer
- **Screen:** `PdfReportViewerScreen` -> `Co2ReportScreen`
- **Execution Type:** Automated Mobile Widget Test (`co2_report_widget_test.dart` TC-HR-W24)
- **Preconditions:** `PdfReportViewerScreen` active.
- **Test Steps:**
  1. Tap back arrow icon in AppBar.
- **Expected Result:** Pops navigator stack and returns seamlessly to `Co2ReportScreen`.
- **Status:** **PASS**

---

## Group 4: Parking Allocation (TC-HR-021 - TC-HR-030)

### TC-HR-021: Retrieve Deck B Priority Bay Allocations
- **Endpoint:** `GET /api/hr/parking/allocations`
- **Execution Type:** Automated Backend Feature Test (`ParkingAllocationTest.php`)
- **Preconditions:** Seeded parking bay records in database.
- **Test Steps:**
  1. Send GET request with HR token.
- **Expected Result:** HTTP 200 returned with list of allocated bays and capacity counts (Assigned: 32, Available: 8, Total: 40).
- **Status:** **PASS**

### TC-HR-022: Parking Screen Rendering & Bay Capacity Headers
- **Screen:** `ParkingScreen`
- **Execution Type:** Automated Mobile Widget Test (`parking_widget_test.dart` TC-HR-W11)
- **Preconditions:** `HrState` loaded with default parking cohorts.
- **Test Steps:**
  1. Pump `ParkingScreen`.
- **Expected Result:** Renders `Parking Allocation`, `Corporate Deck B`, `Assigned Spots`, and cohort cards.
- **Status:** **PASS**

### TC-HR-023: Allocate New Carpool Bay (CRUD: Create)
- **Endpoint:** `POST /api/hr/parking/allocations`
- **Execution Type:** Automated Backend Feature Test (`ParkingAllocationTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"group_name": "Group Delta", "route": "Galle Road Corridor", "commuters": 4, "spot_code": "B-22"}`.
- **Expected Result:** HTTP 201 Created returned; spot persisted.
- **Status:** **PASS**

### TC-HR-024: Reject Duplicate Bay Code Assignment
- **Endpoint:** `POST /api/hr/parking/allocations`
- **Execution Type:** Automated Backend Feature Test (`ParkingAllocationTest.php`)
- **Preconditions:** Bay `B-01` is already allocated.
- **Test Steps:**
  1. Send POST request attempting to assign `B-01` to another group.
- **Expected Result:** HTTP 422 returned with error stating bay is already occupied.
- **Status:** **PASS**

### TC-HR-025: In-App Allocate Priority Spot Flow
- **Screen:** `ParkingScreen`
- **Execution Type:** Automated Mobile Widget Test (`parking_widget_test.dart` TC-HR-W13)
- **Preconditions:** `ParkingScreen` mounted.
- **Test Steps:**
  1. Tap `Allocate Bay`.
  2. Input group `Group Test QA`, route `Kandy Corridor`, riders `4`, bay `B-28`.
  3. Tap `Confirm Spot Allocation`.
- **Expected Result:** Modal dismisses, state increments by 1, and new cohort card renders in list.
- **Status:** **PASS**

### TC-HR-026: Allocate Spot Modal Validation Rejects Empty Spot Code
- **Screen:** `ParkingScreen`
- **Execution Type:** Automated Mobile Widget Test (`parking_widget_test.dart` TC-HR-W12)
- **Preconditions:** `ParkingScreen` mounted.
- **Test Steps:**
  1. Tap `Allocate Bay`.
  2. Clear bay code field and tap `Confirm Spot Allocation`.
- **Expected Result:** Submission blocked; state length remains unchanged.
- **Status:** **PASS**

### TC-HR-027: Reassign Existing Parking Spot (CRUD: Update)
- **Endpoint:** `PUT /api/hr/parking/allocations/{id}`
- **Execution Type:** Automated Backend Feature Test (`ParkingAllocationTest.php`)
- **Preconditions:** Cohort exists at bay `B-05`.
- **Test Steps:**
  1. Send PUT request with new spot code `B-19`.
- **Expected Result:** HTTP 200 returned; bay code updated in database.
- **Status:** **PASS**

### TC-HR-028: Release Assigned Priority Spot (CRUD: Delete)
- **Endpoint:** `DELETE /api/hr/parking/allocations/{id}`
- **Execution Type:** Automated Backend Feature Test (`ParkingAllocationTest.php`)
- **Preconditions:** Existing allocated spot ID.
- **Test Steps:**
  1. Send DELETE request to endpoint.
- **Expected Result:** HTTP 200 returned; record removed from database.
- **Status:** **PASS**

### TC-HR-029: In-App Confirmation Dialog on Spot Release
- **Screen:** `ParkingScreen`
- **Execution Type:** Automated Mobile Widget Test (`parking_widget_test.dart` TC-HR-W14)
- **Preconditions:** `ParkingScreen` mounted with active cohorts.
- **Test Steps:**
  1. Tap `Release` button on first cohort card.
  2. Verify confirmation dialog `Release Bay` appears.
  3. Tap `Release Bay` confirm action.
- **Expected Result:** Dialog closes, cohort removed from list, available bay counter increments.
- **Status:** **PASS**

### TC-HR-030: Cross-Tab Link to Corporate Incentives
- **Screen:** `ParkingScreen`
- **Execution Type:** Automated Mobile Widget Test (`parking_widget_test.dart` TC-HR-W15)
- **Preconditions:** `ParkingScreen` mounted.
- **Test Steps:**
  1. Tap `View Corporate Incentive Programs` bottom banner.
- **Expected Result:** Fires `onNavigateTab(5)`, seamlessly transitioning to Incentives screen.
- **Status:** **PASS**

---

## Group 5: Carpool Statistics (TC-HR-031 - TC-HR-038)

### TC-HR-031: Retrieve Commute Modal Split & Route Analytics
- **Endpoint:** `GET /api/hr/statistics/commute`
- **Execution Type:** Automated Backend Feature Test (`StatisticsTest.php`)
- **Preconditions:** Historical commuting trip data logged.
- **Test Steps:**
  1. Send GET request to `/api/hr/statistics/commute`.
- **Expected Result:** HTTP 200 returned with modal share percentages (Carpool: 44%, Public Transit: 28%, Solo Driving: 18%, Active Mobility: 10%).
- **Status:** **PASS**

### TC-HR-032: Statistics Screen Charts & Donut Painter Rendering
- **Screen:** `StatisticsScreen`
- **Execution Type:** Automated Mobile Widget Test (`statistics_widget_test.dart` TC-HR-W31, TC-HR-W34)
- **Preconditions:** `StatisticsScreen` mounted.
- **Test Steps:**
  1. Assert Donut chart custom painter renders with modal split percentages.
  2. Verify Line chart custom painter displays 6-month growth curve.
- **Expected Result:** Visual charts render smoothly without repaint errors.
- **Status:** **PASS**

### TC-HR-033: Pin Commuter Route Corridor (CRUD: Create)
- **Endpoint:** `POST /api/hr/statistics/pinned-routes`
- **Execution Type:** Automated Backend Feature Test (`StatisticsTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"name": "Negombo Express", "riders": 42, "tag": "Peak Corridor"}`.
- **Expected Result:** HTTP 201 Created returned; route pinned.
- **Status:** **PASS**

### TC-HR-034: In-App Pin Route Flow
- **Screen:** `StatisticsScreen`
- **Execution Type:** Automated Mobile Widget Test (`statistics_widget_test.dart` TC-HR-W32)
- **Preconditions:** `StatisticsScreen` mounted.
- **Test Steps:**
  1. Tap `Pin Route`.
  2. Enter route name `Panadura Coastal Express`, riders `50`, tag `High EV Share`.
  3. Tap `Pin to Dashboard`.
- **Expected Result:** Bottom sheet closes, route appears in Top Performing Routes list.
- **Status:** **PASS**

### TC-HR-035: Unpin Commuter Route (CRUD: Delete)
- **Endpoint:** `DELETE /api/hr/statistics/pinned-routes/{id}`
- **Execution Type:** Automated Backend Feature Test (`StatisticsTest.php`)
- **Preconditions:** Seeded pinned route in database.
- **Test Steps:**
  1. Send DELETE request with route ID.
- **Expected Result:** HTTP 200 returned; route removed from pinned list.
- **Status:** **PASS**

### TC-HR-036: In-App Unpin Route Action
- **Screen:** `StatisticsScreen`
- **Execution Type:** Automated Mobile Widget Test (`statistics_widget_test.dart` TC-HR-W33)
- **Preconditions:** Pinned routes present in list.
- **Test Steps:**
  1. Tap close icon `Icons.close` on first route row.
- **Expected Result:** Route removed from state; SnackBar confirms unpinning.
- **Status:** **PASS**

### TC-HR-037: Average Carpool Occupancy Metric Check
- **Screen:** `StatisticsScreen`
- **Execution Type:** Manual Device Verification
- **Preconditions:** Commute data seeded.
- **Test Steps:**
  1. Inspect Analytics Highlights section.
- **Expected Result:** Displays `3.2 Commuters` average pool group size and `Wednesday` peak commuting day.
- **Status:** **PASS**

### TC-HR-038: Modal Split Percentage Sum Invariant (100%)
- **Screen:** `StatisticsScreen`
- **Execution Type:** Automated Unit / State Test
- **Preconditions:** `HrState.commuteSplits` initialized.
- **Test Steps:**
  1. Sum all split percentages.
- **Expected Result:** Cumulative total strictly equals 100%.
- **Status:** **PASS**

---

## Group 6: Monthly ESG Reports & Native PDF Viewer (TC-HR-039 - TC-HR-048)

### TC-HR-039: Retrieve Published ESG Reports Archive (CRUD: Read)
- **Endpoint:** `GET /api/hr/reports`
- **Execution Type:** Automated Backend Feature Test (`MonthlyReportTest.php`)
- **Preconditions:** Stored monthly report records.
- **Test Steps:**
  1. Send GET request with HR token.
- **Expected Result:** HTTP 200 returned with list of monthly reports including audit hash and date.
- **Status:** **PASS**

### TC-HR-040: Reports Screen Layout & Archive Listing
- **Screen:** `ReportsScreen`
- **Execution Type:** Automated Mobile Widget Test (`reports_widget_test.dart` TC-HR-W41)
- **Preconditions:** `ReportsScreen` mounted.
- **Test Steps:**
  1. Check rendering of `ESG Monthly Reports`, `Latest Published`, and action buttons.
- **Expected Result:** Displays latest report card with `Preview` and `Download & View` triggers.
- **Status:** **PASS**

### TC-HR-041: Generate New Monthly Audit Entry (CRUD: Create)
- **Endpoint:** `POST /api/hr/reports`
- **Execution Type:** Automated Backend Feature Test (`MonthlyReportTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"title": "November 2026 Audit", "co2_kg": 420.0, "completion_rate": 88.5}`.
- **Expected Result:** HTTP 201 Created returned; report persisted.
- **Status:** **PASS**

### TC-HR-042: In-App Generate ESG Report Modal Flow
- **Screen:** `ReportsScreen`
- **Execution Type:** Automated Mobile Widget Test (`reports_widget_test.dart` TC-HR-W43)
- **Preconditions:** `ReportsScreen` mounted.
- **Test Steps:**
  1. Tap `Generate New`.
  2. Fill audit title `November 2026 Special Audit`, CO2 `410`, compliance `85.0%`.
  3. Tap `Generate PDF`.
- **Expected Result:** New report added to state, immediately pushed to `PdfReportViewerScreen`.
- **Status:** **PASS**

### TC-HR-043: Binary PDF Stream Export
- **Endpoint:** `GET /api/hr/reports/{id}/export`
- **Execution Type:** Automated Backend Feature Test (`MonthlyReportTest.php`)
- **Preconditions:** Valid report ID.
- **Test Steps:**
  1. Send GET request to export endpoint.
- **Expected Result:** HTTP 200 returned with `Content-Type: application/pdf`, `Content-Disposition: attachment; filename="velune-esg-audit-report.pdf"`, and valid `%PDF-` binary magic bytes.
- **Status:** **PASS**

### TC-HR-044: Delete Report from Archive (CRUD: Delete)
- **Endpoint:** `DELETE /api/hr/reports/{id}`
- **Execution Type:** Automated Backend Feature Test (`MonthlyReportTest.php`)
- **Preconditions:** Valid report ID.
- **Test Steps:**
  1. Send DELETE request.
- **Expected Result:** HTTP 200 returned; record removed from database.
- **Status:** **PASS**

### TC-HR-045: In-App Archive Deletion Flow
- **Screen:** `ReportsScreen`
- **Execution Type:** Automated Mobile Widget Test (`reports_widget_test.dart` TC-HR-W44)
- **Preconditions:** At least 2 reports in archive.
- **Test Steps:**
  1. Tap trash icon on second archive row.
- **Expected Result:** State report list decrements by 1; UI reacts immediately.
- **Status:** **PASS**

### TC-HR-046: Toggle Automated Corporate Email Delivery (CRUD: Update)
- **Screen:** `ReportsScreen`
- **Execution Type:** Automated Mobile Widget Test (`reports_widget_test.dart` TC-HR-W45)
- **Preconditions:** `ReportsScreen` mounted.
- **Test Steps:**
  1. Tap Switch widget for `Auto-Email to Facilities`.
- **Expected Result:** Switch flips state; `state.autoEmailReports` toggles between true and false.
- **Status:** **PASS**

### TC-HR-047: Native PDF Report Viewer Rendering & Audit Table
- **Screen:** `PdfReportViewerScreen`
- **Execution Type:** Automated Mobile Widget Test (`reports_widget_test.dart` TC-HR-W42)
- **Preconditions:** Tapped `Download & View` from hero card.
- **Test Steps:**
  1. Assert `PdfReportViewerScreen` is mounted.
  2. Verify document title, ISO 14064-1 verification seal, audit metadata table, and compliance stamps.
- **Expected Result:** Document renders in authentic corporate styling without viewport overflow.
- **Status:** **PASS**

### TC-HR-048: Real Device PDF File Download & Intent Launch
- **Screen:** `PdfReportViewerScreen`
- **Execution Type:** Manual Device Verification on Android
- **Preconditions:** Real Android phone connected.
- **Test Steps:**
  1. Tap `Download PDF Document` bottom button.
- **Expected Result:** System generates `.pdf` in application documents directory, displays confirmation SnackBar, and launches system document viewer / share sheet.
- **Status:** **PASS**

---

## Group 7: Corporate Incentives (TC-HR-049 - TC-HR-056)

### TC-HR-049: Retrieve Corporate Incentive Programs List
- **Endpoint:** `GET /api/hr/incentives`
- **Execution Type:** Automated Backend Feature Test (`IncentivesTest.php`)
- **Preconditions:** Seeded corporate incentive programs.
- **Test Steps:**
  1. Send GET request with HR token.
- **Expected Result:** HTTP 200 returned with array of programs, allocated budgets, and disbursal amounts.
- **Status:** **PASS**

### TC-HR-050: Incentives Screen Layout & Leaderboard Cards
- **Screen:** `IncentivesScreen`
- **Execution Type:** Automated Mobile Widget Test (`incentives_widget_test.dart` TC-HR-W51)
- **Preconditions:** `IncentivesScreen` mounted.
- **Test Steps:**
  1. Check headers `Corporate Incentives`, `Active Corporate Programs`, and program cards.
- **Expected Result:** Renders budget progress bar and action triggers.
- **Status:** **PASS**

### TC-HR-051: Create Incentive Program (CRUD: Create)
- **Endpoint:** `POST /api/hr/incentives`
- **Execution Type:** Automated Backend Feature Test (`IncentivesTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"title": "EV Charging Subsidy", "budget_lkr": 50000, "description": "Free charging at Deck B"}`.
- **Expected Result:** HTTP 201 Created returned; program stored.
- **Status:** **PASS**

### TC-HR-052: Reject Negative Budget Value
- **Endpoint:** `POST /api/hr/incentives`
- **Execution Type:** Automated Backend Feature Test (`IncentivesTest.php`)
- **Preconditions:** Valid HR credentials.
- **Test Steps:**
  1. Send POST request with `{"budget_lkr": -10000}`.
- **Expected Result:** HTTP 422 Unprocessable Entity returned.
- **Status:** **PASS**

### TC-HR-053: In-App Add Incentive Modal Flow
- **Screen:** `IncentivesScreen`
- **Execution Type:** Automated Mobile Widget Test (`incentives_widget_test.dart` TC-HR-W53)
- **Preconditions:** `IncentivesScreen` mounted.
- **Test Steps:**
  1. Tap `Add Program`.
  2. Input title `Expressway Toll Grant`, description `Reimbursement for 3+ carpools`, budget `40000`, disbursed `15000`.
  3. Tap `Add Incentive Program`.
- **Expected Result:** Modal closes, new program card appears with linear progress bar.
- **Status:** **PASS**

### TC-HR-054: Reject Empty Title in Modal
- **Screen:** `IncentivesScreen`
- **Execution Type:** Automated Mobile Widget Test (`incentives_widget_test.dart` TC-HR-W52)
- **Preconditions:** `IncentivesScreen` mounted.
- **Test Steps:**
  1. Tap `Add Program`.
  2. Leave title empty and tap `Add Incentive Program`.
- **Expected Result:** Submission rejected; state count unchanged.
- **Status:** **PASS**

### TC-HR-055: Toggle Program Status (Pause / Resume) (CRUD: Update)
- **Screen:** `IncentivesScreen`
- **Execution Type:** Automated Mobile Widget Test (`incentives_widget_test.dart` TC-HR-W55)
- **Preconditions:** Active program in state.
- **Test Steps:**
  1. Tap `Pause` on first program card.
- **Expected Result:** Program status toggles to paused (`isActive = false`); button label updates to `Resume`.
- **Status:** **PASS**

### TC-HR-056: Delete Incentive Program (CRUD: Delete)
- **Endpoint:** `DELETE /api/hr/incentives/{id}`
- **Execution Type:** Automated Backend Feature Test + Widget Test (`incentives_widget_test.dart` TC-HR-W54)
- **Preconditions:** Existing program in state.
- **Test Steps:**
  1. Tap `Delete` button on program card.
- **Expected Result:** Program permanently removed from state and database.
- **Status:** **PASS**
