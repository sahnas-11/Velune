# Velune - Carpooling Mobile Application for Office Commuters

A University Project for **SLIIT**, module **IT3060 Human Computer Interaction**, Milestone 03 (Group **WE_162**).

Velune is designed to help office employees find and book carpools, track pickups, split fares automatically, request breakdown assistance, and enable corporate HR managers to track CO2 savings, campus parking allocation, and sustainability incentives to reduce peak-hour traffic congestion.

---

## Project Structure (Monorepo)

```
velune_carpoolapp/
├── backend/          # Laravel REST API (PHP 8.3, Sanctum Auth, DomPDF, MySQL)
└── mobile/           # Flutter Mobile Application (Riverpod, go_router, Dio, fl_chart)
```

---

## Modules & Group Distribution

1. **Corporate Verification & Ride Discovery**: Login, OTP verification, Home, Ride search.
2. **Booking & Live Tracking**: Ride booking, live pickup navigation, automatic fare settlement.
3. **Emergency Breakdown Assistance**: On-demand mechanic assistance and fleet dispatch.
4. **HR / Corporate & System Integration (Owner: IT23555112)**:
   - **Persona**: Amanda Jayawardena (Head of HR and Corporate Facilities).
   - **FR-05**: Monthly downloadable CO2 ESG reports and verified parking spot allocation.
   - **NFR-04**: Corporate screens expose strictly aggregated, anonymized commuter data.
   - **6 Dedicated Screens**:
     1. HR Dashboard
     2. CO2 Reduction Report
     3. Parking Allocation
     4. Carpool Statistics
     5. Monthly Report (DomPDF export & email automation)
     6. Corporate Incentives

---

## Tech Stack

- **Backend**:
  - Laravel 11/12 (PHP 8.3)
  - Sanctum token authentication (`auth:sanctum`)
  - Role-based authorization (`role:hr_manager`)
  - Barryvdh Laravel DomPDF for automated ESG report generation
  - Database: MySQL `velune_db` (Host: `127.0.0.1:3306`, User: `root`, Empty password)
- **Mobile**:
  - Flutter 3.47+ (Dart 3.13+)
  - State Management: `flutter_riverpod`
  - Routing: `go_router`
  - Networking: `dio`
  - Charts: `fl_chart`
  - Typography: `google_fonts` (Inter)
  - PDF Viewing: `open_filex`, `path_provider`

---

## Getting Started

### 1. Backend Setup
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=127.0.0.1 --port=8000
```

### 2. Mobile Setup
```bash
cd mobile
flutter pub get
flutter run
```
*Note: When running on an Android emulator, API endpoints connect at `http://10.0.2.2:8000/api`.*
