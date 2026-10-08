import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/discovery_state.dart';
import '../models/discovery_models.dart';

class RideDetailsScreen extends StatefulWidget {
  final DiscoveryState state;
  final int rideId;
  final VoidCallback onBack;
  final Function(int rideId) onContinueToBook;

  const RideDetailsScreen({
    super.key,
    required this.state,
    required this.rideId,
    required this.onBack,
    required this.onContinueToBook,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  String? _activeReportReason;

  void _openReportModal(DiscoveryRideItem ride) {
    final reasonController = TextEditingController(text: _activeReportReason ?? 'Schedule Conflict');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Ride / Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reporting driver: ${ride.driverName}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for report',
                hintText: 'e.g. Schedule issue, improper route',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (_activeReportReason != null)
            TextButton(
              onPressed: () {
                setState(() => _activeReportReason = null);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report withdrawn'), backgroundColor: VeluneColors.primaryNavy),
                );
              },
              child: const Text('Withdraw Report', style: TextStyle(color: VeluneColors.danger)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _activeReportReason = reasonController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted to Corporate Fleet Safety'), backgroundColor: VeluneColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy, foregroundColor: Colors.white),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.state.rides.firstWhere(
      (r) => r.id == widget.rideId,
      orElse: () => widget.state.rides.first,
    );

    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeluneColors.textPrimary),
          onPressed: widget.onBack,
        ),
        title: const Text('Ride Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: VeluneColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(ride.isBookmarked ? Icons.bookmark : Icons.bookmark_outline, color: VeluneColors.accentBlue),
            tooltip: 'Bookmark',
            onPressed: () {
              widget.state.toggleBookmark(ride.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ride.isBookmarked ? 'Ride bookmarked' : 'Bookmark removed'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: VeluneColors.danger),
            tooltip: 'Report Ride',
            onPressed: () => _openReportModal(ride),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DRIVER INFORMATION Card
            const Text(
              'DRIVER INFORMATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VeluneColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: VeluneColors.skyBlue,
                        child: Text(
                          ride.driverName.split(' ').map((e) => e[0]).take(2).join(),
                          style: const TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle, color: VeluneColors.success, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VeluneColors.textPrimary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(8)),
                              child: Text('${ride.seatsLeft} seats available', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('${ride.driverRating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Text(ride.vehicleModel, style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Phone: ${ride.driverPhoneMasked}', style: const TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. JOURNEY & RIDE DETAILS Card
            const Text(
              'JOURNEY & RIDE DETAILS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Route Timeline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, color: VeluneColors.accentBlue, size: 12),
                          Container(width: 2, height: 38, color: VeluneColors.border),
                          const Icon(Icons.location_on, color: VeluneColors.danger, size: 14),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Pickup Point', style: TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                                Text(ride.departureTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                              ],
                            ),
                            Text(ride.pickupSpot, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Drop-off Point', style: TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                                Text(ride.arrivalTime, style: const TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                              ],
                            ),
                            Text(ride.dropoffSpot, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  // Three mini tiles: Date, Departure, Availability
                  Row(
                    children: [
                      Expanded(child: _buildMiniDetailTile('Date', ride.date, Icons.calendar_today, VeluneColors.textPrimary)),
                      Expanded(child: _buildMiniDetailTile('Departure', ride.departureTime, Icons.access_time, VeluneColors.accentBlue)),
                      Expanded(child: _buildMiniDetailTile('Availability', '${ride.seatsLeft} Seats', Icons.event_seat, VeluneColors.success)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Estimated Fare Navy Gradient Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: VeluneColors.navyGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VeluneColors.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMATED FARE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      SizedBox(height: 2),
                      Text('Per passenger share', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  Text(
                    'Rs. ${ride.price.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Active Report indicator
            if (_activeReportReason != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VeluneColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: VeluneColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: VeluneColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Active report submitted: $_activeReportReason', style: const TextStyle(fontSize: 11, color: VeluneColors.danger, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            // 4. Navy CONTINUE TO BOOK Button -> Navigates to /booking/confirm/:rideId!
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onContinueToBook(ride.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CONTINUE TO BOOK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDetailTile(String label, String value, IconData icon, Color valColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: VeluneColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: VeluneColors.textMuted),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }
}
