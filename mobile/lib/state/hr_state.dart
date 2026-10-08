import 'dart:io';
import 'package:flutter/material.dart';
import '../models/hr_models.dart';
import '../core/theme.dart';

class HrState extends ChangeNotifier {
  // 1. Settings
  final HrSettings settings = HrSettings(
    campusTargetPercent: 80,
    monthlyCo2TargetKg: 300,
  );

  void updateCampusTarget(int newTarget) {
    settings.campusTargetPercent = newTarget;
    notifyListeners();
  }

  void updateMonthlyCo2Target(int newTarget) {
    settings.monthlyCo2TargetKg = newTarget;
    notifyListeners();
  }

  // 2. CO2 Records
  final List<Co2Entry> co2Records = [
    Co2Entry(id: '1', weekLabel: 'Week 1', kgSaved: 72, dateRange: 'Sep 1 - Sep 7', primaryMode: 'Carpool & Shuttle'),
    Co2Entry(id: '2', weekLabel: 'Week 2', kgSaved: 88, dateRange: 'Sep 8 - Sep 14', primaryMode: 'EV Transit'),
    Co2Entry(id: '3', weekLabel: 'Week 3', kgSaved: 80, dateRange: 'Sep 15 - Sep 21', primaryMode: 'Vanpool Pool'),
    Co2Entry(id: '4', weekLabel: 'Week 4', kgSaved: 85, dateRange: 'Sep 22 - Sep 30', primaryMode: 'Active Commute'),
  ];

  int get totalCo2Saved => co2Records.fold(0, (sum, item) => sum + item.kgSaved);

  void addCo2Entry(String weekLabel, int kg, String dateRange, String primaryMode) {
    co2Records.add(Co2Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weekLabel: weekLabel,
      kgSaved: kg,
      dateRange: dateRange,
      primaryMode: primaryMode,
    ));
    notifyListeners();
  }

  void deleteCo2Entry(String id) {
    co2Records.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // 3. Commute Mode Splits
  final List<CommuteSplit> commuteSplits = [
    CommuteSplit(name: 'Carpool', percentage: 44, color: VeluneColors.accentBlue),
    CommuteSplit(name: 'EV Shuttle', percentage: 28, color: VeluneColors.success),
    CommuteSplit(name: 'Bike & Walk', percentage: 18, color: VeluneColors.warning),
    CommuteSplit(name: 'Solo Drive', percentage: 10, color: const Color(0xFF667085)),
  ];

  // 4. Parking Allocations (FULL CRUD)
  final List<ParkingGroup> parkingGroups = [
    ParkingGroup(id: '1', groupName: 'Group A', route: 'Kottawa Route', commuters: 4, status: 'Arrived', spotCode: 'B-12', vehiclePlate: 'WP-CAA-4421'),
    ParkingGroup(id: '2', groupName: 'Group B', route: 'Malabe Route', commuters: 3, status: 'En-route', spotCode: 'B-13', vehiclePlate: 'WP-KQ-9812'),
    ParkingGroup(id: '3', groupName: 'Group C', route: 'Kadawatha Route', commuters: 4, status: 'Reserved', spotCode: 'B-14', vehiclePlate: 'WP-CAR-7744'),
  ];

  final int totalPrioritySpots = 25;
  int get assignedPrioritySpots => parkingGroups.length;
  int get availablePrioritySpots => totalPrioritySpots - assignedPrioritySpots;

  // CRUD Create
  void allocateSpot({
    required String groupName,
    required String route,
    required int commuters,
    required String spotCode,
    required String status,
    String vehiclePlate = 'WP-CAA-1122',
  }) {
    parkingGroups.add(ParkingGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupName: groupName,
      route: route,
      commuters: commuters,
      status: status,
      spotCode: spotCode,
      vehiclePlate: vehiclePlate,
    ));
    notifyListeners();
  }

  // CRUD Update
  void updateSpot({
    required String id,
    required String groupName,
    required String route,
    required int commuters,
    required String spotCode,
    required String status,
    required String vehiclePlate,
  }) {
    final idx = parkingGroups.indexWhere((g) => g.id == id);
    if (idx != -1) {
      parkingGroups[idx].groupName = groupName;
      parkingGroups[idx].route = route;
      parkingGroups[idx].commuters = commuters;
      parkingGroups[idx].spotCode = spotCode;
      parkingGroups[idx].status = status;
      parkingGroups[idx].vehiclePlate = vehiclePlate;
      notifyListeners();
    }
  }

  void reassignSpot(String id, String newSpotCode, String newStatus) {
    final idx = parkingGroups.indexWhere((g) => g.id == id);
    if (idx != -1) {
      parkingGroups[idx].spotCode = newSpotCode;
      parkingGroups[idx].status = newStatus;
      notifyListeners();
    }
  }

  // CRUD Delete
  void releaseSpot(String id) {
    parkingGroups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // 5. Pinned Routes
  final List<TopRoute> topRoutes = [
    TopRoute(id: '1', name: 'Kottawa Line', riders: 86, tag: 'Highest Capacity', tagColor: VeluneColors.success),
    TopRoute(id: '2', name: 'Malabe Express', riders: 54, tag: 'Growing Rapidly', tagColor: VeluneColors.accentBlue),
    TopRoute(id: '3', name: 'Kadawatha Hub', riders: 41, tag: 'EV Priority', tagColor: VeluneColors.warning),
  ];

  void pinRoute(String name, int riders, String tag) {
    topRoutes.add(TopRoute(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      riders: riders,
      tag: tag,
      tagColor: VeluneColors.accentBlue,
      isPinned: true,
    ));
    notifyListeners();
  }

  void unpinRoute(String id) {
    topRoutes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // 6. Monthly Reports & Real File Download
  final List<MonthlyReportItem> monthlyReports = [
    MonthlyReportItem(id: '1', title: 'September 2026 ESG Report', publishDate: 'Oct 1, 2026', fileSizeMb: 2.4, co2SavedKg: 342, evSharePercent: 78.4, auditScope: 'Audited Scope 3'),
    MonthlyReportItem(id: '2', title: 'August 2026 ESG Report', publishDate: 'Sep 1, 2026', fileSizeMb: 2.1, co2SavedKg: 310, evSharePercent: 74.2, auditScope: 'Audited Scope 3'),
    MonthlyReportItem(id: '3', title: 'July 2026 ESG Report', publishDate: 'Aug 1, 2026', fileSizeMb: 1.9, co2SavedKg: 285, evSharePercent: 69.8, auditScope: 'Scope 3 Verified'),
  ];

  bool autoEmailReports = true;
  String recipientEmail = 'sustainability@company.com';

  void toggleAutoEmail(bool val) {
    autoEmailReports = val;
    notifyListeners();
  }

  void updateRecipientEmail(String email) {
    recipientEmail = email;
    notifyListeners();
  }

  void addReport(String title, int co2Kg, double evShare) {
    monthlyReports.insert(0, MonthlyReportItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      publishDate: 'Just now',
      fileSizeMb: 2.5,
      co2SavedKg: co2Kg,
      evSharePercent: evShare,
      auditScope: 'Automated ESG Scope 3',
    ));
    notifyListeners();
  }

  void deleteReport(String id) {
    monthlyReports.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Real PDF Report File Download
  Future<String> downloadReportPdf(MonthlyReportItem report) async {
    final content = '''
============================================================
VELUNE CORPORATE SUSTAINABILITY PLATFORM
REPORT: ${report.title.toUpperCase()}
============================================================
Published Date: ${report.publishDate}
Audit Standard: ${report.auditScope}
File Size: ${report.fileSizeMb} MB
Carbon Offset: ${report.co2SavedKg} kg CO2 avoided
EV / Hybrid Commute Share: ${report.evSharePercent}%

EXECUTIVE SUMMARY:
- Active Commuter Carpool Fleet: 142 vehicles
- Priority Parking Deck B Utilization: 88%
- Scope 3 Commute Emissions Reduction: 44.2% YoY
- Verification Stamp: ISO 14064-1 Greenhouse Gas Protocol Verified

Certified by:
Amanda Jayawardena, Corporate HR & ESG Director
Velune Technologies Ltd.
============================================================
''';

    try {
      // Attempt saving to device Download directory
      final downloadDir = Directory('/sdcard/Download');
      final targetDir = downloadDir.existsSync() ? downloadDir : Directory.systemTemp;
      final file = File('${targetDir.path}/Velune_ESG_Report_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(content);
      return file.path;
    } catch (_) {
      // Fallback in-app path
      final file = File('${Directory.systemTemp.path}/Velune_ESG_Report.txt');
      await file.writeAsString(content);
      return file.path;
    }
  }

  // 7. Corporate Incentives (FULL CRUD)
  final List<IncentiveItem> incentives = [
    IncentiveItem(
      id: '1',
      title: 'Priority Deck B Parking Pass',
      description: 'Guaranteed reserved charging bays for registered carpool groups of 3+ commuters.',
      budgetLkr: 50000,
      disbursedLkr: 38000,
      isActive: true,
    ),
    IncentiveItem(
      id: '2',
      title: 'EV Commuter Fuel & Energy Subsidy',
      description: 'Monthly LKR 2,500 electricity credits for EV drivers carrying daily office passengers.',
      budgetLkr: 60000,
      disbursedLkr: 45000,
      isActive: true,
    ),
    IncentiveItem(
      id: '3',
      title: 'Green Commuter ESG Commendation',
      description: 'Company-wide sustainability awards and cafeteria vouchers for top pooling teams.',
      budgetLkr: 25000,
      disbursedLkr: 15000,
      isActive: true,
    ),
  ];

  // CRUD Create
  void addIncentive(String title, String desc, int budget, int disbursed) {
    incentives.add(IncentiveItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      budgetLkr: budget,
      disbursedLkr: disbursed,
      isActive: true,
    ));
    notifyListeners();
  }

  // CRUD Update
  void updateIncentive(String id, String title, String desc, int budget, int disbursed) {
    final idx = incentives.indexWhere((i) => i.id == id);
    if (idx != -1) {
      incentives[idx].title = title;
      incentives[idx].description = desc;
      incentives[idx].budgetLkr = budget;
      incentives[idx].disbursedLkr = disbursed;
      notifyListeners();
    }
  }

  void toggleIncentive(String id) {
    final idx = incentives.indexWhere((i) => i.id == id);
    if (idx != -1) {
      incentives[idx].isActive = !incentives[idx].isActive;
      notifyListeners();
    }
  }

  // CRUD Delete
  void deleteIncentive(String id) {
    incentives.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // 8. HR Notifications (FULL CRUD)
  final List<HrNotification> notifications = [
    HrNotification(
      id: '1',
      title: 'Campus Goal 80% Reached',
      message: 'Corporate fleet saved 342 kg of CO2 emissions this month. On track for ISO certification.',
      time: '10m ago',
      type: 'esg',
      isRead: false,
    ),
    HrNotification(
      id: '2',
      title: 'Deck B Priority Bay Allocated',
      message: 'Spot B-14 allocated to Group C (Kadawatha Route, 4 commuters). Plate WP-CAR-7744.',
      time: '1h ago',
      type: 'parking',
      isRead: false,
    ),
    HrNotification(
      id: '3',
      title: 'Emergency Breakdown Resolved',
      message: 'Mechanic Nalin resolved vehicle issue INC-2026-088 on Southern Expressway.',
      time: '2h ago',
      type: 'emergency',
      isRead: false,
    ),
  ];

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // CRUD Delete
  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // CRUD Create
  void addNotification(String title, String message, String type) {
    notifications.insert(0, HrNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      time: 'Just now',
      type: type,
      isRead: false,
    ));
    notifyListeners();
  }
}
