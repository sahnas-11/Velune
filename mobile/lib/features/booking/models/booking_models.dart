class BookingDetails {
  final String id;
  String pickupName;
  String dropoffName;
  String pickupTime;
  String dropoffTime;
  String driverName;
  double driverRating;
  String vehicleModel;
  String vehiclePlate;
  int seatsBooked;
  int totalSeats;
  int baseCorporateShare;
  int corporateSubsidyCredit;
  int highwayTollOffset;
  int totalDueLkr;
  String paymentMethod;
  double co2SavedKg;
  String status; // 'confirmed', 'waiting_pickup', 'boarded', 'settled', 'cancelled'

  BookingDetails({
    required this.id,
    required this.pickupName,
    required this.dropoffName,
    required this.pickupTime,
    required this.dropoffTime,
    required this.driverName,
    required this.driverRating,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.seatsBooked,
    required this.totalSeats,
    required this.baseCorporateShare,
    required this.corporateSubsidyCredit,
    required this.highwayTollOffset,
    required this.totalDueLkr,
    required this.paymentMethod,
    required this.co2SavedKg,
    this.status = 'confirmed',
  });
}

class FareSplitItem {
  final String riderName;
  final bool isCurrentUser;
  final int amountLkr;
  final double distanceShareKm;

  FareSplitItem({
    required this.riderName,
    required this.isCurrentUser,
    required this.amountLkr,
    required this.distanceShareKm,
  });
}

class TripSettlement {
  final int totalRouteFareLkr;
  final int baseDepartureRateLkr;
  final int expresswayTollLkr;
  final int operationalFeeLkr;
  final double subsidyPercent;
  final int subsidyAmountLkr;
  int userShareLkr;
  bool isPartialCalibrated;
  String dropoffPoint;
  List<FareSplitItem> splits;
  bool isPaid;

  TripSettlement({
    required this.totalRouteFareLkr,
    required this.baseDepartureRateLkr,
    required this.expresswayTollLkr,
    required this.operationalFeeLkr,
    required this.subsidyPercent,
    required this.subsidyAmountLkr,
    required this.userShareLkr,
    this.isPartialCalibrated = false,
    this.dropoffPoint = 'World Trade Center, Colombo',
    required this.splits,
    this.isPaid = false,
  });
}

class PaymentReceipt {
  final String id;
  final int amountLkr;
  final String date;
  final String cardEnding;
  final double fuelSavedL;
  final double co2AvoidedKg;
  final int carpoolPoints;
  int rating;
  List<String> ratingTags;
  bool isExportedWorkday;

  PaymentReceipt({
    required this.id,
    required this.amountLkr,
    required this.date,
    required this.cardEnding,
    required this.fuelSavedL,
    required this.co2AvoidedKg,
    required this.carpoolPoints,
    this.rating = 5,
    required this.ratingTags,
    this.isExportedWorkday = false,
  });
}
