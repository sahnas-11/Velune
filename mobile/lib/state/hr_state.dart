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

  // 3. Commute Mode Splits
  final List<CommuteSplit> commuteSplits = [
    CommuteSplit(name: 'Carpool', percentage: 44, color: VeluneColors.accentBlue),
    CommuteSplit(name: 'EV Shuttle', percentage: 28, color: VeluneColors.success),
    CommuteSplit(name: 'Bike & Walk', percentage: 18, color: VeluneColors.warning),
    CommuteSplit(name: 'Solo Drive', percentage: 10, color: const Color(0xFF667085)),
  ];

  // 4. Parking Allocations
  final List<ParkingGroup> parkingGroups = [
    ParkingGroup(id: '1', groupName: 'Group A', route: 'Kottawa Route', commuters: 4, status: 'Arrived', spotCode: 'B-12'),
    ParkingGroup(id: '2', groupName: 'Group B', route: 'Malabe Route', commuters: 3, status: 'En-route', spotCode: 'B-13'),
    ParkingGroup(id: '3', groupName: 'Group C', route: 'Kadawatha Route', commuters: 4, status: 'Reserved', spotCode: 'B-14'),
  ];

  final int totalPrioritySpots = 25;
  int get assignedPrioritySpots => parkingGroups.length;
  int get availablePrioritySpots => totalPrioritySpots - assignedPrioritySpots;

  void allocateSpot(String groupName, String route, int commuters, String spotCode, String status) {
    parkingGroups.add(ParkingGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupName: groupName,
      route: route,
      commuters: commuters,
      status: status,
      spotCode: spotCode,
    ));
    notifyListeners();
  }

  void reassignSpot(String id, String newSpotCode, String newStatus) {
    final idx = parkingGroups.indexWhere((g) => g.id == id);
    if (idx != -1) {
      parkingGroups[idx].spotCode = newSpotCode;
      parkingGroups[idx].status = newStatus;
      notifyListeners();
    }
  }

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

  // 6. Monthly Reports
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

  // 7. Corporate Incentives
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

  void deleteIncentive(String id) {
    incentives.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
