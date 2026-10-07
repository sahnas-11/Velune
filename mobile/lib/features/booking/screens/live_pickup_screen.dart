import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/booking_state.dart';

class LivePickupScreen extends StatefulWidget {
  final BookingState state;
  final VoidCallback onBoardedRide;

  const LivePickupScreen({
    super.key,
    required this.state,
    required this.onBoardedRide,
  });

  @override
  State<LivePickupScreen> createState() => _LivePickupScreenState();
}

class _LivePickupScreenState extends State<LivePickupScreen> {
  Timer? _timer;
  int _secondsRemaining = 175; // 2:55

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showSafetyToolkit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Carpool Safety Toolkit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.share_location, color: VeluneColors.accentBlue),
              title: const Text('Share Live Location with Family/Colleague'),
              subtitle: const Text('Active tracking link generated'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live tracking link copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: VeluneColors.danger),
              title: const Text('Emergency Security Hotline (1990)'),
              subtitle: const Text('Direct expressway emergency dispatcher'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.state.currentBooking;
    final progress = _secondsRemaining / 180.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Live Pickup Tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: VeluneColors.primaryNavy),
            onPressed: () => _showSafetyToolkit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Map
            const VeluneMapCanvas(
              pickupLabel: 'Matara Clock Tower',
              dropoffLabel: 'WTC Colombo',
              statusText: 'Driver approaching pickup curb • 850m away',
              progress: 0.28,
              height: 180,
            ),
            const SizedBox(height: 20),

            // Grace Window Circular Countdown Ring
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VeluneColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VeluneColors.warningBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: VeluneColors.warning),
                        SizedBox(width: 4),
                        Text(
                          '3-Minute Grace Window',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.warning),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          backgroundColor: const Color(0xFFF2F4F7),
                          valueColor: const AlwaysStoppedAnimation<Color>(VeluneColors.accentBlue),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTimer(_secondsRemaining),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                          ),
                          const Text('Remaining', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kasun is arriving at Matara Clock Tower curb.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: VeluneColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Approaching Driver Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: VeluneColors.skyBlue,
                    child: const Text('KS', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${b.vehicleModel} • ${b.vehiclePlate}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: VeluneColors.success, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('ETA: ${widget.state.driverEta} (${widget.state.driverDistance})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: VeluneColors.accentBlue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing driver Kasun Silva (077-***4288)...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Share Live Trip Link Row (CRUD)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.share, size: 16, color: widget.state.isShareLinkActive ? VeluneColors.accentBlue : VeluneColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        widget.state.isShareLinkActive ? 'Live Trip Link Shared' : 'Share Link Revoked',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.state.isShareLinkActive ? VeluneColors.textPrimary : VeluneColors.textMuted),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      final newVal = !widget.state.isShareLinkActive;
                      widget.state.toggleShareLink(newVal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(newVal ? 'Live share link activated' : 'Live share link revoked')),
                      );
                    },
                    child: Text(widget.state.isShareLinkActive ? 'Revoke' : 'Share', style: TextStyle(fontSize: 12, color: widget.state.isShareLinkActive ? VeluneColors.danger : VeluneColors.accentBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Button: Confirm Boarding
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.state.confirmBoarding();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Boarding confirmed! Active Carpool Trip started.')),
                  );
                  widget.onBoardedRide();
                },
                child: const Text('Confirm Boarding & Start Ride', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
