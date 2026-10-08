class DiscoveryRideItem {
  final int id;
  final String driverName;
  final double driverRating;
  final String driverPhoneMasked;
  final String vehicleModel;
  final String vehiclePlate;
  final String fromLocation;
  final String toLocation;
  final String pickupSpot;
  final String dropoffSpot;
  final String departureTime;
  final String arrivalTime;
  final String date;
  final int seatsTotal;
  final int seatsLeft;
  final double price;
  final String tag;
  final bool verifiedOnly;
  bool isBookmarked;

  DiscoveryRideItem({
    required this.id,
    required this.driverName,
    required this.driverRating,
    this.driverPhoneMasked = '+94 77 ••• •288',
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.fromLocation,
    required this.toLocation,
    required this.pickupSpot,
    required this.dropoffSpot,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
    required this.seatsTotal,
    required this.seatsLeft,
    required this.price,
    required this.tag,
    this.verifiedOnly = true,
    this.isBookmarked = false,
  });
}

class DiscoverySavedSearchItem {
  final int id;
  final String fromLocation;
  final String toLocation;
  final String preferredTime;

  DiscoverySavedSearchItem({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    this.preferredTime = '08:00 AM',
  });
}

class DiscoveryNoticeItem {
  final int id;
  final String title;
  final String message;
  bool isDismissed;

  DiscoveryNoticeItem({
    required this.id,
    required this.title,
    required this.message,
    this.isDismissed = false,
  });
}
