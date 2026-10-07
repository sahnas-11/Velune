class ActiveRide {
  final String id;
  final String routeName;
  final String trafficState;
  final int speedKmh;
  final int remainingMinutes;
  final String targetArrivalTime;
  final String departurePoint;
  final String dropoffPoint;
  final String driverName;
  final int passengersCount;
  bool isRouteShared;

  ActiveRide({
    required this.id,
    required this.routeName,
    required this.trafficState,
    required this.speedKmh,
    required this.remainingMinutes,
    required this.targetArrivalTime,
    required this.departurePoint,
    required this.dropoffPoint,
    required this.driverName,
    required this.passengersCount,
    this.isRouteShared = true,
  });
}

class EmergencyIncident {
  final String id;
  String status; // 'Pending', 'Accepted', 'En Route', 'Arrived', 'Resolved'
  String priority; // 'Critical Priority', 'Roadside Assist', 'Patrol'
  String locationText;
  String kmMarker;
  String vehiclePlate;
  String vehicleModel;
  String issueType;
  String description;
  String reporterName;
  String assignedMechanic;
  String mechanicPhone;
  double mechanicRating;
  int etaMinutes;
  double distanceKm;
  String diagnosticCode;
  String technicianNote;
  bool passengersSafe;
  String reportedAt;

  EmergencyIncident({
    required this.id,
    required this.status,
    required this.priority,
    required this.locationText,
    required this.kmMarker,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.issueType,
    required this.description,
    required this.reporterName,
    required this.assignedMechanic,
    required this.mechanicPhone,
    required this.mechanicRating,
    required this.etaMinutes,
    required this.distanceKm,
    this.diagnosticCode = 'DTC-P0A80',
    this.technicianNote = 'Hybrid battery relay safety lockout detected.',
    this.passengersSafe = true,
    required this.reportedAt,
  });
}
