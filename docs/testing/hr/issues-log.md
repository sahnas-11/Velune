# Velune Carpool Platform - Defect & Issues Log: HR Module

**Course:** IT3060 Human Computer Interaction (Milestone 03)  
**Group:** WE_162  
**Module:** HR / Corporate & System Integration  
**Lead Engineer:** IT23555112 (Amanda Jayawardena)  
**Target Branch:** `feature/hr-corporate`  

---

## 1. Summary of Discovered & Resolved Issues

During the execution of automated backend feature tests (PHPUnit) and mobile widget integration tests (Flutter Test), 4 defects were discovered. All 4 issues were diagnosed, resolved via isolated fix commits, and verified green through automated test regression.

| Issue ID | Severity | Component | Summary | Status | Resolution Commit |
| :--- | :---: | :--- | :--- | :---: | :---: |
| **ISSUE-HR-001** | **Critical (P1)** | Backend Model | `User` model missing `HasApiTokens` trait breaking Sanctum authentication. | **FIXED** | `0368e63` |
| **ISSUE-HR-002** | **Critical (P1)** | Backend Security | `/api/hr` route group unauthenticated and lacked role authorization (`role.hr`). | **FIXED** | `0368e63` |
| **ISSUE-HR-003** | **Major (P2)** | Backend Export | `exportReport()` endpoint returned JSON instead of streaming binary PDF. | **FIXED** | `0368e63` |
| **ISSUE-HR-004** | **Major (P2)** | Mobile UI Layout | `PdfReportViewerScreen` header row overflowed by 46px on mobile viewports. | **FIXED** | `02b13c3` |

---

## 2. Detailed Issue Records

### ISSUE-HR-001: Missing `HasApiTokens` Trait on Laravel User Model
- **Discovered In:** Stage 1 Backend Feature Test Suite Setup
- **Component:** `backend/app/Models/User.php`
- **Severity:** Critical (P1)
- **Description:**  
  When running PHPUnit tests that authenticate users using Sanctum (`$user->createToken('test')->plainTextToken` or `$this->actingAs($user, 'sanctum')`), Laravel threw `BadMethodCallException: Call to undefined method App\Models\User::createToken()`. The User model imported `HasFactory` and `Notifiable`, but omitted Sanctum's `HasApiTokens` trait.
- **Root Cause:**  
  Initial project scaffold created the User model without enabling Sanctum token capabilities.
- **Fix Applied:**  
  Imported `Laravel\Sanctum\HasApiTokens` in `app/Models/User.php` and added `use HasApiTokens, HasFactory, Notifiable;` to the class body.
- **Verification:**  
  Verified by `backend/tests/Feature/Hr/DashboardTest.php` passing all token-authenticated assertions.
- **Commit:** `0368e63`

---

### ISSUE-HR-002: Unauthenticated and Unprotected `/api/hr` Route Group
- **Discovered In:** `backend/tests/Feature/Hr/DashboardTest.php` (TC-HR-001, TC-HR-002)
- **Component:** `backend/routes/api.php` & `backend/bootstrap/app.php`
- **Severity:** Critical (P1)
- **Description:**  
  HTTP GET requests to `/api/hr/dashboard` without credentials returned HTTP 200 instead of HTTP 401. Furthermore, authenticated commuter and mechanic tokens could access HR metrics without restriction, violating role-based access control and `NFR-04` confidentiality.
- **Root Cause:**  
  Route group was defined as `Route::prefix('hr')->group(...)` without Sanctum authentication or role middleware.
- **Fix Applied:**  
  1. Authored `backend/app/Http/Middleware/EnsureHrRole.php` checking `$request->user()->role === 'hr'`, returning HTTP 403 Forbidden on role mismatch.
  2. Registered route alias `'role.hr' => \App\Http\Middleware\EnsureHrRole::class` in `backend/bootstrap/app.php`.
  3. Protected the route group: `Route::prefix('hr')->middleware(['auth:sanctum', 'role.hr'])->group(...)`.
- **Verification:**  
  Verified by test assertions confirming HTTP 401 for guests and HTTP 403 for commuters/mechanics across all 6 test suites.
- **Commit:** `0368e63`

---

### ISSUE-HR-003: `exportReport` Endpoint Returning JSON Instead of Binary PDF
- **Discovered In:** `backend/tests/Feature/Hr/MonthlyReportTest.php` (TC-HR-043)
- **Component:** `backend/app/Http/Controllers/HrController.php`
- **Severity:** Major (P2)
- **Description:**  
  `GET /api/hr/reports/{id}/export` returned a mock JSON payload `{"status": "success", "message": "Report exported"}`. The assignment and mobile client expect a downloadable binary PDF stream (`Content-Type: application/pdf`).
- **Root Cause:**  
  Stub controller method returned `response()->json()` placeholder.
- **Fix Applied:**  
  Refactored `exportReport($id)` to return `response()->streamDownload(...)` with binary headers:
  - `Content-Type: application/pdf`
  - `Content-Disposition: attachment; filename="velune-esg-audit-report-$id.pdf"`
  - Valid `%PDF-1.4` binary stream containing certified audit metadata and timestamps.
- **Verification:**  
  Verified by `MonthlyReportTest.php` asserting HTTP 200, PDF content-type, attachment header, and binary magic bytes.
- **Commit:** `0368e63`

---

### ISSUE-HR-004: RenderFlex Overflow in Native PDF Report Viewer Screen
- **Discovered In:** Stage 2 Mobile Widget Test Suite (`co2_report_widget_test.dart` & `reports_widget_test.dart`)
- **Component:** `mobile/lib/screens/pdf_report_viewer_screen.dart` (Line 154)
- **Severity:** Major (P2)
- **Description:**  
  When testing navigation to `PdfReportViewerScreen` on standard mobile dimensions (width 360-450px), Flutter threw:
  `A RenderFlex overflowed by 46 pixels on the right. The relevant error-causing widget was: Row: file:///.../pdf_report_viewer_screen.dart:154:23`.
- **Root Cause:**  
  The document header row contained an unconstrained inner `Row` with platform branding alongside an `ISO 14064-1` verification badge container. Together, their minimum intrinsic widths exceeded available screen bounds on compact viewports.
- **Fix Applied:**  
  Wrapped the branding container with `Expanded` and the subtitle column with `Flexible` with `overflow: TextOverflow.ellipsis`.
- **Verification:**  
  Verified by `co2_report_widget_test.dart` and `reports_widget_test.dart` passing 100% green without layout overflow warnings.
- **Commit:** `02b13c3`
