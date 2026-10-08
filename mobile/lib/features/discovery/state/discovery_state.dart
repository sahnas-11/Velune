import 'package:flutter/material.dart';
import '../models/discovery_models.dart';

class DiscoveryState extends ChangeNotifier {
  final List<DiscoveryRideItem> _rides = [];
  final List<DiscoverySavedSearchItem> _savedSearches = [];
  final List<String> _locations = [
    'Matara Town',
    'Matara Clock Tower',
    'Matara Expressway Hub',
    'Colombo Office HQ',
    'World Trade Center',
    'Colombo Fort',
    'Kottawa Interchange',
    'Malabe Cyber Center',
    'Kadawatha Exit',
  ];

  final DiscoveryNoticeItem _notice = DiscoveryNoticeItem(
    id: 1,
    title: 'Daily Notice',
    message: 'Book executive rides by 6:00 PM today for priority assignment on peak morning routes.',
  );

  int _unreadNotifications = 2;
  String _selectedFrom = 'Matara Town';
  String _selectedTo = 'Colombo Office HQ';
  String _selectedTime = '08:00 AM';
  String _selectedDate = 'Tomorrow';

  DiscoveryState() {
    _initDemoData();
  }

  void _initDemoData() {
    // 1. Kasun Silva (id 1, primary demo matching Tissera's booking module)
    _rides.add(DiscoveryRideItem(
      id: 1,
      driverName: 'Kasun Silva',
      driverRating: 4.8,
      driverPhoneMasked: '+94 77 ••• •288',
      vehicleModel: 'Silver Toyota Prius (Hybrid)',
      vehiclePlate: 'CAB-4288',
      fromLocation: 'Matara Town',
      toLocation: 'Colombo Office HQ',
      pickupSpot: 'Matara Town / Gate 2 Hub',
      dropoffSpot: 'Colombo Office / Main Tower',
      departureTime: '08:00 AM',
      arrivalTime: '09:30 AM',
      date: 'Tomorrow',
      seatsTotal: 4,
      seatsLeft: 2,
      price: 450.00,
      tag: 'Direct Route',
      verifiedOnly: true,
      isBookmarked: false,
    ));

    // 2. Nimal Perera
    _rides.add(DiscoveryRideItem(
      id: 2,
      driverName: 'Nimal Perera',
      driverRating: 4.9,
      driverPhoneMasked: '+94 71 ••• •512',
      vehicleModel: 'Honda Vezel (Hybrid)',
      vehiclePlate: 'WP CAD-1902',
      fromLocation: 'Matara Clock Tower',
      toLocation: 'World Trade Center',
      pickupSpot: 'Matara Clock Tower Hub',
      dropoffSpot: 'WTC West Tower Lobby',
      departureTime: '08:15 AM',
      arrivalTime: '09:45 AM',
      date: 'Tomorrow',
      seatsTotal: 4,
      seatsLeft: 3,
      price: 500.00,
      tag: 'On-time 99%',
      verifiedOnly: true,
      isBookmarked: true,
    ));

    // 3. Chaminda Dias
    _rides.add(DiscoveryRideItem(
      id: 3,
      driverName: 'Chaminda Dias',
      driverRating: 4.7,
      driverPhoneMasked: '+94 76 ••• •991',
      vehicleModel: 'Nissan Note e-Power',
      vehiclePlate: 'WP CAJ-8812',
      fromLocation: 'Matara Express Hub',
      toLocation: 'Colombo Fort',
      pickupSpot: 'Expressway Southern Gate',
      dropoffSpot: 'Fort Station Plaza',
      departureTime: '08:30 AM',
      arrivalTime: '10:00 AM',
      date: 'Tomorrow',
      seatsTotal: 3,
      seatsLeft: 1,
      price: 450.00,
      tag: 'Express Route',
      verifiedOnly: true,
      isBookmarked: false,
    ));

    _savedSearches.add(DiscoverySavedSearchItem(
      id: 1,
      fromLocation: 'Matara Town',
      toLocation: 'Colombo Office HQ',
      preferredTime: '08:00 AM',
    ));
  }

  List<DiscoveryRideItem> get rides => List.unmodifiable(_rides);
  List<DiscoverySavedSearchItem> get savedSearches => List.unmodifiable(_savedSearches);
  List<String> get locations => List.unmodifiable(_locations);
  DiscoveryNoticeItem get notice => _notice;
  int get unreadNotifications => _unreadNotifications;

  String get selectedFrom => _selectedFrom;
  String get selectedTo => _selectedTo;
  String get selectedTime => _selectedTime;
  String get selectedDate => _selectedDate;

  void setSearchCriteria({required String from, required String to, String? time, String? date}) {
    _selectedFrom = from;
    _selectedTo = to;
    if (time != null) _selectedTime = time;
    if (date != null) _selectedDate = date;
    notifyListeners();
  }

  void toggleBookmark(int rideId) {
    final idx = _rides.indexWhere((r) => r.id == rideId);
    if (idx != -1) {
      _rides[idx].isBookmarked = !_rides[idx].isBookmarked;
      notifyListeners();
    }
  }

  void addSavedSearch(String from, String to, String time) {
    _savedSearches.add(DiscoverySavedSearchItem(
      id: DateTime.now().millisecondsSinceEpoch,
      fromLocation: from,
      toLocation: to,
      preferredTime: time,
    ));
    notifyListeners();
  }

  void removeSavedSearch(int id) {
    _savedSearches.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void dismissNotice() {
    _notice.isDismissed = true;
    notifyListeners();
  }

  void markNotificationsRead() {
    _unreadNotifications = 0;
    notifyListeners();
  }
}
