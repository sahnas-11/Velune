import 'package:flutter/material.dart';
import '../models/booking_models.dart';

class BookingState extends ChangeNotifier {
  // Current Booking
  BookingDetails currentBooking = BookingDetails(
    id: 'BK-1082',
    pickupName: 'Matara Clock Tower',
    dropoffName: 'World Trade Center, Colombo',
    pickupTime: '06:45 AM',
    dropoffTime: '08:30 AM',
    driverName: 'Kasun Silva',
    driverRating: 4.8,
    vehicleModel: 'Silver Toyota Prius (Hybrid)',
    vehiclePlate: 'CAB-4288',
    seatsBooked: 1,
    totalSeats: 3,
    baseCorporateShare: 1800,
    corporateSubsidyCredit: 1200,
    highwayTollOffset: 200,
    totalDueLkr: 800,
    paymentMethod: 'Commercial Bank Corporate Card ending 4082',
    co2SavedKg: 14.6,
    status: 'confirmed',
  );

  // Live Pickup State
  int graceWindowSeconds = 179; // Starts counting down from 3:00
  String driverEta = '2 mins away';
  String driverDistance = '850 meters';
  bool isShareLinkActive = true;
  String shareLinkUrl = 'https://velune.app/live/BK-1082/tracker';

  // Active Ride Telemetry
  double routeProgress = 0.45;
  int speedKmh = 78;
  String trafficState = 'Normal Traffic Flow';
  int liveAccruedFareLkr = 580;
  int maxRouteCapLkr = 800;
  double tripCo2Avoided = 8.4;
  List<String> delayReports = [];

  // Trip Settlement
  TripSettlement settlement = TripSettlement(
    totalRouteFareLkr: 7800,
    baseDepartureRateLkr: 4200,
    expresswayTollLkr: 2400,
    operationalFeeLkr: 1200,
    subsidyPercent: 0.75,
    subsidyAmountLkr: 5850,
    userShareLkr: 800,
    isPartialCalibrated: false,
    splits: [
      FareSplitItem(riderName: 'Amanda C. (You)', isCurrentUser: true, amountLkr: 800, distanceShareKm: 142.0),
      FareSplitItem(riderName: 'Naveen K.', isCurrentUser: false, amountLkr: 575, distanceShareKm: 104.5),
      FareSplitItem(riderName: 'Kirthan S.', isCurrentUser: false, amountLkr: 575, distanceShareKm: 104.5),
    ],
  );

  // Receipt
  PaymentReceipt receipt = PaymentReceipt(
    id: 'RCP-9842',
    amountLkr: 800,
    date: 'Today, 08:32 AM',
    cardEnding: '4082',
    fuelSavedL: 7.8,
    co2AvoidedKg: 14.6,
    carpoolPoints: 120,
    rating: 5,
    ratingTags: ['Punctual', 'Smooth Drive', 'Clean Hybrid'],
    isExportedWorkday: false,
  );

  // === CRUD Operations ===

  // 1. Booking CRUD
  void updateBookingSeats(int seats) {
    currentBooking.seatsBooked = seats;
    currentBooking.totalDueLkr = 800 * seats;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    currentBooking.paymentMethod = method;
    notifyListeners();
  }

  void cancelBooking() {
    currentBooking.status = 'cancelled';
    notifyListeners();
  }

  void confirmBoarding() {
    currentBooking.status = 'boarded';
    notifyListeners();
  }

  // 2. Pickup CRUD
  void toggleShareLink(bool active) {
    isShareLinkActive = active;
    notifyListeners();
  }

  // 3. Active Ride CRUD
  void addDelayReport(String reason) {
    delayReports.add(reason);
    notifyListeners();
  }

  void removeDelayReport(String reason) {
    delayReports.remove(reason);
    notifyListeners();
  }

  // 4. Settlement CRUD
  void togglePartialCalibration(bool enabled, String dropoff) {
    settlement.isPartialCalibrated = enabled;
    settlement.dropoffPoint = dropoff;
    if (enabled) {
      settlement.userShareLkr = 580; // Calibrated down for early exit
    } else {
      settlement.userShareLkr = 800;
    }
    notifyListeners();
  }

  void approvePayment() {
    settlement.isPaid = true;
    currentBooking.status = 'settled';
    notifyListeners();
  }

  // 5. Receipt CRUD
  void updateRating(int stars, List<String> tags) {
    receipt.rating = stars;
    receipt.ratingTags = tags;
    notifyListeners();
  }

  void exportToWorkday() {
    receipt.isExportedWorkday = true;
    notifyListeners();
  }
}
