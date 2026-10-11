import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/emergency_state.dart';

class ActiveRideScreen extends StatelessWidget {
  final EmergencyState state;
  final VoidCallback onRequestEmergency;
  final Function(int index)? onNavigateTab;

  const ActiveRideScreen({
    super.key,
    required this.state,
    required this.onRequestEmergency,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final ride = state.activeRide;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          // 1. Header / AppBar
          appBar: _buildHeaderAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Top Map Section with Overlays
                _buildTopMapSection(context, ride),
                const SizedBox(height: 14),

                // 3. Estimated Arrival Card
                _buildEstimatedArrivalCard(ride),
                const SizedBox(height: 14),

                // 4. Consolidated Trip & Driver Card
                _buildConsolidatedTripAndDriverCard(ride),
                const SizedBox(height: 14),

                // 5. Action Buttons (Share Route & Rider Chat)
                _buildActionButtons(context, ride),
                const SizedBox(height: 14),

                // 6. Emergency Assistance Banner
                _buildEmergencyAssistanceBanner(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // 7. Bottom Navigation Bar matching 1st UI page
          bottomNavigationBar: _buildBottomNavBar(context),
        );
      },
    );
  }

  // =========================================================================
  // 1. Header / AppBar
  // =========================================================================
  PreferredSizeWidget _buildHeaderAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2B48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
      title: const Text(
        'Active Rides',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.4,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: InkWell(
              onTap: () {
                if (onNavigateTab != null) onNavigateTab!(4);
              },
              borderRadius: BorderRadius.circular(21),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2B48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. Top Map Section (Realistic Map Canvas + 3 Overlays)
  // =========================================================================
  Widget _buildTopMapSection(BuildContext context, dynamic ride) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDE5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Realistic vector map painter
            Positioned.fill(
              child: CustomPaint(
                painter: _HighFidelityMapPainter(),
              ),
            ),

            // Top-left overlay: Expressway Corridor Pill Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Expressway Corridor • Normal Traffic',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-right overlay: Circular floating GPS / Crosshair Button
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-centering vehicle GPS on Southern Expressway E01...')),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    size: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            // Bottom-left overlay: Dark Translucent Speedometer & Distance Pill
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B48).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed, size: 16, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      '${ride.speedKmh}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const Text(
                      ' km/h',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 11),
                    ),
                    Container(
                      height: 14,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white30,
                    ),
                    Transform.rotate(
                      angle: 0.5,
                      child: const Icon(Icons.navigation, size: 13, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '14 km left',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. Estimated Arrival Card
  // =========================================================================
  Widget _buildEstimatedArrivalCard(dynamic ride) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        children: [
          // Left: Light blue squircle with timer icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Center: Estimated arrival text & On Schedule badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ESTIMATED ARRIVAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Arriving in ${ride.remainingMinutes} mins',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Center badge: Dark green pill badge (ON SCHEDULE)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ON',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                Text(
                  'SCHEDULE',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right: Target arrival time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Target',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              RichText(
                textAlign: TextAlign.end,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '08:42\n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: 'AM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. Consolidated Trip & Driver Card
  // =========================================================================
  Widget _buildConsolidatedTripAndDriverCard(dynamic ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Route Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical timeline dots & line
              Column(
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    color: const Color(0xFFBFDBFE),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F2B48),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Departure & Drop-off descriptions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Departure Point
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Departure Point',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Matara Interchange',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Gate 01',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Final Corporate Drop-off
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Final Corporate Drop-off',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Colombo World Trade Center',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'West Tower',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          ),

          // Driver Section
          Row(
            children: [
              // Driver Avatar with Verified Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Text(
                      'KS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 13,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Driver Name, Driver Pill, Onboard count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ride.driverName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: const [
                        Icon(Icons.groups_rounded, size: 15, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'Jay M. & 2 others onboard',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Overlapping Stacked Passenger Avatars +1
              SizedBox(
                width: 68,
                height: 30,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Positioned(
                      right: 38,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: const Color(0xFF1E3A8A),
                        ),
                        child: const Center(
                          child: Text(
                            'JM',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 19,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: const Color(0xFF0284C7),
                        ),
                        child: const Center(
                          child: Text(
                            'SK',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: const Color(0xFFDBEAFE),
                        ),
                        child: const Center(
                          child: Text(
                            '+1',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. Action Buttons (Share Route & Rider Chat)
  // =========================================================================
  Widget _buildActionButtons(BuildContext context, dynamic ride) {
    return Row(
      children: [
        // Left: Share Route Button
        Expanded(
          child: InkWell(
            onTap: () {
              state.toggleRouteSharing(!ride.isRouteShared);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ride.isRouteShared ? 'Live route sharing active' : 'Route sharing paused'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore_outlined, size: 18, color: Color(0xFF1E40AF)),
                  SizedBox(width: 8),
                  Text(
                    'Share Route',
                    style: TextStyle(
                      color: Color(0xFF1E40AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right: Rider Chat Button
        Expanded(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Rider Chat with Kasun & passengers...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF1E40AF)),
                  SizedBox(width: 8),
                  Text(
                    'Rider Chat',
                    style: TextStyle(
                      color: Color(0xFF1E40AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 6. Emergency Assistance Banner
  // =========================================================================
  Widget _buildEmergencyAssistanceBanner(BuildContext context) {
    return InkWell(
      onTap: onRequestEmergency,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFB91C1C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB91C1C).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Lighter red rounded squircle with warning triangle icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Assistance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Report vehicle breakdown or roadside danger',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Right: White chevron icon
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 7. Bottom Navigation Bar matching 1st UI page
  // =========================================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(0);
                },
              ),
              // 2. Find Rides
              _buildNavItem(
                icon: Icons.search,
                label: 'Find Rides',
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(1);
                },
              ),
              // 3. My Trips
              _buildNavItem(
                icon: Icons.directions_car_outlined,
                label: 'My Trips',
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(2);
                },
              ),
              // 4. Safety SOS (Active with Light-Blue Pill and Red Asterisk)
              _buildSafetySosNavItem(
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(3);
                },
              ),
              // 5. Profile
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(4);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF64748B)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySosNavItem({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0EDFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.emergency,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Safety SOS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// High-Fidelity Vector Map Painter (matching Image 2)
// =========================================================================
class _HighFidelityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base terrain background (soft map sage green)
    final bgPaint = Paint()..color = const Color(0xFFDCECE1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Coastal water line / Bay in the bottom area (soft coastal blue)
    final waterPaint = Paint()
      ..color = const Color(0xFFB8D8F8)
      ..style = PaintingStyle.fill;
    final waterPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.82, size.width * 0.45, size.height * 0.95)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Grid & secondary road network (thin white/grey lines)
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Longitudinal and transversal local routes
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.28, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.68, 0), Offset(size.width * 0.76, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.42), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.60), thinRoadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.45, size.height * 0.5), thinRoadPaint);
    canvas.drawLine(Offset(size.width * 0.85, size.height * 0.2), Offset(size.width * 0.5, size.height), thinRoadPaint);

    // 4. Pale arterial highway (yellowish highway E01 connecting road)
    final arterialPaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final arterialPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.30, size.width * 0.95, size.height * 0.55);
    canvas.drawPath(arterialPath, arterialPaint);

    // 5. Town / Landmark labels
    _drawLabel(canvas, 'Mulgirigala', Offset(size.width * 0.22, size.height * 0.38));
    _drawLabel(canvas, 'Weeraketiya', Offset(size.width * 0.38, size.height * 0.22));
    _drawLabel(canvas, 'Agrahara', Offset(size.width * 0.52, size.height * 0.18));
    _drawLabel(canvas, 'Netolpitiya', Offset(size.width * 0.64, size.height * 0.70));
    _drawLabel(canvas, 'Ranna', Offset(size.width * 0.82, size.height * 0.58));

    // Little expressway shield pill E01
    _drawShield(canvas, 'E01', Offset(size.width * 0.66, size.height * 0.36));

    // 6. The Active Route Curve (Bold vibrant blue)
    final startPt = Offset(size.width * 0.10, size.height * 0.85);
    final ctrlPt = Offset(size.width * 0.45, size.height * 0.48);
    final endPt = Offset(size.width * 0.88, size.height * 0.12);

    final routeGlowPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..quadraticBezierTo(ctrlPt.dx, ctrlPt.dy, endPt.dx, endPt.dy);

    canvas.drawPath(routePath, routeGlowPaint);
    canvas.drawPath(routePath, routePaint);

    // 7. Start Pin (Matara) & End Pin (Colombo)
    // Start pin
    final startPinOuter = Paint()..color = const Color(0xFFF59E0B);
    final startPinInner = Paint()..color = Colors.white;
    canvas.drawCircle(startPt, 6, startPinOuter);
    canvas.drawCircle(startPt, 3.5, startPinInner);

    // End pin
    final endPinOuter = Paint()..color = const Color(0xFFEF4444);
    final endPinInner = Paint()..color = Colors.white;
    canvas.drawCircle(endPt, 6, endPinOuter);
    canvas.drawCircle(endPt, 3.5, endPinInner);

    // 8. Vehicle Position Marker (~55% along curve)
    // Bezier point formula: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
    const t = 0.54;
    final carX = pow(1 - t, 2) * startPt.dx + 2 * (1 - t) * t * ctrlPt.dx + pow(t, 2) * endPt.dx;
    final carY = pow(1 - t, 2) * startPt.dy + 2 * (1 - t) * t * ctrlPt.dy + pow(t, 2) * endPt.dy;
    final carPos = Offset(carX, carY);

    // Radar pulse aura
    final auraPaint = Paint()..color = const Color(0xFF3B82F6).withOpacity(0.24);
    canvas.drawCircle(carPos, 20, auraPaint);

    // Outer dark navy ring
    final outerRing = Paint()..color = const Color(0xFF0F2B48);
    canvas.drawCircle(carPos, 9, outerRing);

    // Inner white border
    final midRing = Paint()..color = Colors.white;
    canvas.drawCircle(carPos, 6.5, midRing);

    // Core car dot
    final coreDot = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(carPos, 3.8, coreDot);
  }

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  void _drawShield(Canvas canvas, String text, Offset position) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: 22, height: 13),
      const Radius.circular(4),
    );
    final bgPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(rect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(position.dx - (tp.width / 2), position.dy - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
