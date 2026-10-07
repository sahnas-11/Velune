import 'package:flutter/material.dart';
import '../models/emergency_models.dart';

class EmergencyState extends ChangeNotifier {
  // Current Active Ride (Commuter view)
  ActiveRide activeRide = ActiveRide(
    id: 'RD-4402',
    routeName: 'Southern Expressway Corridor (E01)',
    trafficState: 'Normal Traffic Flow',
    speedKmh: 82,
    remainingMinutes: 12,
    targetArrivalTime: '08:42 AM',
    departurePoint: 'Matara Interchange',
    dropoffPoint: 'Colombo World Trade Center',
    driverName: 'Kasun Silva',
    passengersCount: 3,
    isRouteShared: true,
  );

  // Active Incident
  EmergencyIncident currentIncident = EmergencyIncident(
    id: 'EM-9042',
    status: 'En Route', // 'Pending', 'Accepted', 'En Route', 'Arrived', 'Resolved'
    priority: 'Critical Priority',
    locationText: 'Southern Expressway, KM 74.2 (near Welipenna Service Area)',
    kmMarker: 'KM 74.2 Southbound',
    vehiclePlate: 'WP CAB-8492',
    vehicleModel: 'Toyota Prius (Hybrid)',
    issueType: 'EV/Battery',
    description: 'Vehicle lost propulsion, emergency hazards active on hard shoulder.',
    reporterName: 'Kaveen Perera',
    assignedMechanic: 'Nalin Silva',
    mechanicPhone: '077-***9842',
    mechanicRating: 4.9,
    etaMinutes: 8,
    distanceKm: 4.2,
    diagnosticCode: 'DTC-P0A80',
    technicianNote: 'Mobile Unit #04 dispatched with high-voltage jumper kit.',
    passengersSafe: true,
    reportedAt: '08:42 AM',
  );

  // Mechanic Job Queue List
  final List<EmergencyIncident> queue = [
    EmergencyIncident(
      id: 'EM-9042',
      status: 'En Route',
      priority: 'Critical Priority',
      locationText: 'Southern Expressway, KM 74.2',
      kmMarker: 'KM 74.2 Southbound',
      vehiclePlate: 'WP CAB-8492',
      vehicleModel: 'Toyota Prius Hybrid',
      issueType: 'EV/Battery',
      description: 'Hybrid propulsion loss on expressway shoulder.',
      reporterName: 'Kaveen Perera',
      assignedMechanic: 'Nalin Silva',
      mechanicPhone: '077-***9842',
      mechanicRating: 4.9,
      etaMinutes: 8,
      distanceKm: 4.2,
      reportedAt: '3m ago',
    ),
    EmergencyIncident(
      id: 'EM-8821',
      status: 'Pending',
      priority: 'Roadside Assist',
      locationText: 'Kottawa Interchange Exit 2',
      kmMarker: 'KM 2.1 Ramp',
      vehiclePlate: 'WP CAD-1102',
      vehicleModel: 'Nissan Leaf EV',
      issueType: 'Flat Tire',
      description: 'Right rear tire puncture during ramp ascent.',
      reporterName: 'Priya Fernando',
      assignedMechanic: 'Unassigned',
      mechanicPhone: '',
      mechanicRating: 0.0,
      etaMinutes: 15,
      distanceKm: 8.5,
      reportedAt: '7m ago',
    ),
    EmergencyIncident(
      id: 'EM-7419',
      status: 'Accepted',
      priority: 'Patrol',
      locationText: 'Dodangoda Service Plaza',
      kmMarker: 'KM 34.0',
      vehiclePlate: 'WP CAC-6629',
      vehicleModel: 'Honda Grace Hybrid',
      issueType: 'Overheating',
      description: 'Coolant warning light flashing at service parking.',
      reporterName: 'Rohan Jayathilake',
      assignedMechanic: 'Nalin Silva',
      mechanicPhone: '077-***9842',
      mechanicRating: 4.9,
      etaMinutes: 20,
      distanceKm: 14.0,
      reportedAt: '12m ago',
    ),
  ];

  // === CRUD Operations ===

  // 1. Commuter CRUD
  void toggleRouteSharing(bool shared) {
    activeRide.isRouteShared = shared;
    notifyListeners();
  }

  void createBreakdownIncident(String issue, String notes, String km) {
    currentIncident.issueType = issue;
    currentIncident.description = notes;
    currentIncident.kmMarker = km;
    currentIncident.status = 'Pending';
    currentIncident.assignedMechanic = 'Mobile Unit #04 (Searching)';
    currentIncident.etaMinutes = 10;
    notifyListeners();
  }

  void cancelIncident() {
    currentIncident.status = 'Resolved';
    notifyListeners();
  }

  // 2. Mechanic CRUD
  void acceptIncident(String id) {
    final idx = queue.indexWhere((i) => i.id == id);
    if (idx != -1) {
      queue[idx].status = 'Accepted';
      queue[idx].assignedMechanic = 'Nalin Silva (You)';
      notifyListeners();
    }
  }

  void updateIncidentStatus(String id, String newStatus) {
    final idx = queue.indexWhere((i) => i.id == id);
    if (idx != -1) {
      queue[idx].status = newStatus;
      notifyListeners();
    }
    if (currentIncident.id == id) {
      currentIncident.status = newStatus;
      notifyListeners();
    }
  }

  void updateDiagnosticCode(String code, String note) {
    currentIncident.diagnosticCode = code;
    currentIncident.technicianNote = note;
    notifyListeners();
  }

  void archiveResolvedIncident(String id) {
    queue.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
