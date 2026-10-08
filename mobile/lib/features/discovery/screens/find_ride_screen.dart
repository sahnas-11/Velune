import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/discovery_state.dart';

class FindRideScreen extends StatefulWidget {
  final DiscoveryState state;
  final VoidCallback onBack;
  final VoidCallback onSearchSubmitted;

  const FindRideScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSearchSubmitted,
  });

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  late String _fromLocation;
  late String _toLocation;
  late String _selectedTime;
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _fromLocation = widget.state.selectedFrom;
    _toLocation = widget.state.selectedTo;
    _selectedTime = widget.state.selectedTime;
    _selectedDate = widget.state.selectedDate;
  }

  void _submitSearch() {
    widget.state.setSearchCriteria(
      from: _fromLocation,
      to: _toLocation,
      time: _selectedTime,
      date: _selectedDate,
    );
    widget.onSearchSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    final locations = widget.state.locations;

    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeluneColors.textPrimary),
          onPressed: widget.onBack,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMUTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue, letterSpacing: 1.1)),
            Text('Find a Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_outlined, color: VeluneColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where are you going?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Book certified high-occupancy corporate commutes',
              style: TextStyle(fontSize: 13, color: VeluneColors.textSecondary),
            ),

            const SizedBox(height: 20),

            // Main Booking Criteria Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VeluneColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Departure Point
                  const Text('Departure point', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: locations.contains(_fromLocation) ? _fromLocation : locations.first,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.my_location, color: VeluneColors.accentBlue, size: 20),
                      filled: true,
                      fillColor: VeluneColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                    ),
                    items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _fromLocation = val);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Destination with "HQ Zone" badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Office destination', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(6)),
                        child: const Text('HQ Zone', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: locations.contains(_toLocation) ? _toLocation : locations[3],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: VeluneColors.danger, size: 20),
                      filled: true,
                      fillColor: VeluneColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                    ),
                    items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _toLocation = val);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date & Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Travel date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: VeluneColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: VeluneColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: VeluneColors.textMuted),
                                  const SizedBox(width: 8),
                                  Text(_selectedDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pickup time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: VeluneColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: VeluneColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: VeluneColors.textMuted),
                                  const SizedBox(width: 8),
                                  Text(_selectedTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Navy FIND RIDES Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('FIND RIDES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Direct route chip
            ActionChip(
              avatar: const Icon(Icons.route, size: 14, color: VeluneColors.accentBlue),
              label: const Text('Matara Expressway Hub -> Colombo (Direct Route)', style: TextStyle(fontSize: 11)),
              backgroundColor: VeluneColors.skyBlue,
              side: BorderSide(color: VeluneColors.accentBlue.withValues(alpha: 0.3)),
              onPressed: () {
                setState(() {
                  _fromLocation = 'Matara Expressway Hub';
                  _toLocation = 'Colombo Office HQ';
                });
                _submitSearch();
              },
            ),

            const SizedBox(height: 16),

            // Corporate Fleet Assignment Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VeluneColors.successBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_outlined, color: VeluneColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Corporate Fleet Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                        SizedBox(height: 4),
                        Text(
                          'Rides are operated by enterprise-certified drivers. Seat assignments close 60 minutes prior to scheduled departure.',
                          style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
