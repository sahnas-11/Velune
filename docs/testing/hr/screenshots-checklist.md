# Velune Carpool Platform - Screenshot Checklist & Capture Guide: HR Module

**Course:** IT3060 Human Computer Interaction (Milestone 03)  
**Module:** HR / Corporate & System Integration  
**Lead:** IT23555112 (Amanda Jayawardena)  
**Storage Directory:** `docs/testing/hr/screenshots/`  

---

## 1. Required Screenshots Checklist for Milestone 03 Report

Use this checklist to ensure all essential HR screens and interactive states are documented in your submission report.

| # | Screenshot Filename | Description / Screen State | Captured? |
| :---: | :--- | :--- | :---: |
| **01** | `01_hr_dashboard.png` | HR Dashboard default state showing Amanda Jayawardena header, 78% target hero card, and 4 KPI cards. | [ &nbsp; ] |
| **02** | `02_hr_dashboard_edit_target.png` | HR Dashboard with "Edit Campus Target %" alert dialog open showing target textfield. | [ &nbsp; ] |
| **03** | `03_hr_dashboard_alerts_sheet.png` | HR Dashboard with "Corporate Alerts" bottom sheet open showing notifications and dismiss actions. | [ &nbsp; ] |
| **04** | `04_co2_report_overview.png` | CO2 Reduction Report showing 325 kg avoided, 14 Trees / 1,240 mi equivalents, and weekly records. | [ &nbsp; ] |
| **05** | `05_co2_report_log_modal.png` | CO2 Reduction Report with "Log New CO2 Entry" modal sheet open. | [ &nbsp; ] |
| **06** | `06_parking_allocation_overview.png` | Parking Allocation screen showing Deck B summary (32 assigned / 8 open) and cohort cards. | [ &nbsp; ] |
| **07** | `07_parking_allocate_bay_modal.png` | Parking Allocation with "Allocate Priority Spot" modal sheet open. | [ &nbsp; ] |
| **08** | `08_carpool_statistics_charts.png` | Carpool Statistics showing Commute Modal Share Donut Chart and 6-Month Carpool Adoption Growth Line Chart. | [ &nbsp; ] |
| **09** | `09_carpool_statistics_pin_modal.png` | Carpool Statistics with "Pin Commuter Route" modal open. | [ &nbsp; ] |
| **10** | `10_monthly_reports_overview.png` | Monthly ESG Reports screen showing latest published report hero card and archive list. | [ &nbsp; ] |
| **11** | `11_monthly_reports_generate_modal.png`| Monthly ESG Reports with "Generate ESG Report" modal open. | [ &nbsp; ] |
| **12** | `12_pdf_report_viewer_screen.png` | Native PDF Report Viewer screen displaying ISO 14064-1 verified audit header and metadata table. | [ &nbsp; ] |
| **13** | `13_corporate_incentives_overview.png` | Corporate Incentives screen showing active programs, budget progress, and leaderboard cards. | [ &nbsp; ] |
| **14** | `14_corporate_incentives_add_modal.png`| Corporate Incentives with "New Incentive Program" modal open. | [ &nbsp; ] |

---

## 2. Fast Capture via Android Debug Bridge (ADB)

When running the application on your physical Android device (`R7AWC03MG6H`) or emulator, you can capture full-resolution screenshots directly from your terminal using the following PowerShell one-liners:

### Automated Capture Commands:

1. **Dashboard:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/01_hr_dashboard.png
   ```

2. **Dashboard - Edit Target Dialog:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/02_hr_dashboard_edit_target.png
   ```

3. **Dashboard - Corporate Alerts Sheet:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/03_hr_dashboard_alerts_sheet.png
   ```

4. **CO2 Report Screen:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/04_co2_report_overview.png
   ```

5. **CO2 Report - Log Entry Modal:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/05_co2_report_log_modal.png
   ```

6. **Parking Allocation Screen:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/06_parking_allocation_overview.png
   ```

7. **Parking - Allocate Bay Modal:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/07_parking_allocate_bay_modal.png
   ```

8. **Carpool Statistics Screen:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/08_carpool_statistics_charts.png
   ```

9. **Carpool Statistics - Pin Route Modal:**
   ```powershell
   adb exec-out screencap -p > docs/testing/hr/screenshots/09_carpool_statistics_pin_modal.png
   ```

10. **Monthly ESG Reports Screen:**
    ```powershell
    adb exec-out screencap -p > docs/testing/hr/screenshots/10_monthly_reports_overview.png
    ```

11. **Monthly Reports - Generate Modal:**
    ```powershell
    adb exec-out screencap -p > docs/testing/hr/screenshots/11_monthly_reports_generate_modal.png
    ```

12. **Native PDF Viewer Screen:**
    ```powershell
    adb exec-out screencap -p > docs/testing/hr/screenshots/12_pdf_report_viewer_screen.png
    ```

13. **Corporate Incentives Screen:**
    ```powershell
    adb exec-out screencap -p > docs/testing/hr/screenshots/13_corporate_incentives_overview.png
    ```

14. **Corporate Incentives - Add Program Modal:**
    ```powershell
    adb exec-out screencap -p > docs/testing/hr/screenshots/14_corporate_incentives_add_modal.png
    ```
