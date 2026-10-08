import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/discovery_state.dart';

class CommuterHomeScreen extends StatefulWidget {
  final DiscoveryState state;
  final String userName;
  final VoidCallback onFindRidePressed;
  final Function(int rideId) onRideSelected;

  const CommuterHomeScreen({
    super.key,
    required this.state,
    required this.userName,
    required this.onFindRidePressed,
    required this.onRideSelected,
  });

  @override
  State<CommuterHomeScreen> createState() => _CommuterHomeScreenState();
}

class _CommuterHomeScreenState extends State<CommuterHomeScreen> {
  final _pickupController = TextEditingController(text: 'Matara Town');
  final _destinationController = TextEditingController(text: 'Colombo Office HQ');

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _handleFindRide() {
    widget.state.setSearchCriteria(
      from: _pickupController.text.trim(),
      to: _destinationController.text.trim(),
    );
    widget.onFindRidePressed();
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.state.notice;
    final unread = widget.state.unreadNotifications;
    final firstName = widget.userName.split(' ').first;

    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: VeluneColors.primaryNavy,
              child: Text(
                firstName.isNotEmpty ? firstName[0] : 'J',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, $firstName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary),
                ),
                const Text(
                  'Corporate Commuter • Certified',
                  style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: VeluneColors.textPrimary),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: VeluneColors.danger, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              widget.state.markNotificationsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications marked as read'), backgroundColor: VeluneColors.primaryNavy),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-greeting
            const Text(
              "Ready for today's commute?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
            ),
            const SizedBox(height: 14),

            // Find a Ride Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VeluneColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.search, color: VeluneColors.accentBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Find a ride to work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary)),
                            Text('Book shared corporate transport or carpool', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Departure Field
                  TextField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      labelText: 'Pickup spot',
                      prefixIcon: const Icon(Icons.my_location, size: 18, color: VeluneColors.accentBlue),
                      filled: true,
                      fillColor: VeluneColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VeluneColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VeluneColors.border)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Destination Field
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Work destination',
                      prefixIcon: const Icon(Icons.location_on, size: 18, color: VeluneColors.danger),
                      filled: true,
                      fillColor: VeluneColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VeluneColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VeluneColors.border)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Navy FIND A RIDE Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleFindRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('FIND A RIDE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Upcoming Ride Card
            const Text(
              'UPCOMING RIDE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: VeluneColors.accentBlue),
                          SizedBox(width: 6),
                          Text('Tomorrow 8:00 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: VeluneColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: VeluneColors.success.withValues(alpha: 0.3)),
                        ),
                        child: const Text('Confirmed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Matara -> Colombo Corporate HQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VeluneColors.primaryNavy)),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Text('Pickup at 8:00 AM  •  Est. arrival: 9:30 AM', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Direct Express', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                      ),
                      TextButton(
                        onPressed: () => widget.onRideSelected(1),
                        child: const Text('View Ride Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Daily Notice Card with Dismiss button
            if (!notice.isDismissed)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: VeluneColors.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VeluneColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: VeluneColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daily Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VeluneColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(notice.message, style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary, height: 1.35)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: VeluneColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        widget.state.dismissNotice();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notice dismissed'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Saved Favourite Routes CRUD
            const Text(
              'SAVED COMMUTES',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ActionChip(
                    avatar: const Icon(Icons.star, size: 14, color: Colors.amber),
                    label: const Text('Matara Town -> Colombo HQ', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: VeluneColors.border),
                    onPressed: () {
                      _pickupController.text = 'Matara Town';
                      _destinationController.text = 'Colombo Office HQ';
                      _handleFindRide();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: VeluneColors.accentBlue),
                  tooltip: 'Save Current Route',
                  onPressed: () {
                    widget.state.addSavedSearch(_pickupController.text, _destinationController.text, '08:00 AM');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route saved to favourites!'), backgroundColor: VeluneColors.success),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
