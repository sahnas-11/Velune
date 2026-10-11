import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/emergency_models.dart';
import '../state/emergency_state.dart';

class MechanicRequestDetailsScreen extends StatefulWidget {
  final EmergencyState state;
  final EmergencyIncident incident;
  final VoidCallback onAccepted;
  final VoidCallback? onBack;
  final Function(int index)? onNavigateTab;

  const MechanicRequestDetailsScreen({
    super.key,
    required this.state,
    required this.incident,
    required this.onAccepted,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<MechanicRequestDetailsScreen> createState() => _MechanicRequestDetailsScreenState();
}

class _MechanicRequestDetailsScreenState extends State<MechanicRequestDetailsScreen> {
  final TextEditingController _noteCtrl = TextEditingController(
    text: 'Assigned Unit #04 high-voltage bypass kit.',
  );

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.incident;

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
            // 2. Top Status Tags Banner
            _buildTopStatusBanner(),
            const SizedBox(height: 14),

            // 3. Live Highway Incident Map
            _buildLiveHighwayMap(),
            const SizedBox(height: 14),

            // 4. Commuter & Vehicle Details Container
            _buildCommuterAndVehicleContainer(inc),
            const SizedBox(height: 16),

            // 5. Action Buttons (Call Driver & Accept Request)
            _buildActionButtons(context, inc),
            const SizedBox(height: 14),

            // 6. Safety Guideline Banner
            _buildSafetyGuidelineBanner(),
            const SizedBox(height: 18),
          ],
        ),
      ),
      // 7. Persistent 5-Tab Bottom Navigation Bar (Safety SOS Active)
      bottomNavigationBar: _buildBottomNavBar(context),
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
          child: InkWell(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF0F2B48),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Mechanic Incident Diagnostic',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: InkWell(
              onTap: () {
                if (widget.onNavigateTab != null) widget.onNavigateTab!(4);
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
  // 2. Top Status Tags Banner
  // =========================================================================
  Widget _buildTopStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left pill badge: Red dot + PRIORITY INCIDENT
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'PRIORITY INCIDENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Right pill badge: Pending Acceptance with hourglass
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFDC2626),
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'Pending Acceptance',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. Live Highway Incident Map
  // =========================================================================
  Widget _buildLiveHighwayMap() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDE5),
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Custom Painter of Colombo-Kottawa Highway Map
            Positioned.fill(
              child: CustomPaint(
                painter: _ColomboHighwayMapPainter(),
              ),
            ),

            // Top-left overlay: Highway icon + "Colombo-Kottawa HWY • KM 14.8 | 4.2 km away"
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      color: Color(0xFF2563EB),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Colombo-Kottawa HWY • KM 14.8',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      color: const Color(0xFFCBD5E1),
                    ),
                    Transform.rotate(
                      angle: 0.6,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF0F172A),
                        size: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.2 km away',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-left overlay: Red circle warning + Emergency Shoulder Stop
            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Emergency Shoulder Stop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                      ),
                      Text(
                        'Vehicle safely halted',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom-right overlay: Dark pill badge "GPS Active"
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B48).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GPS Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. Commuter & Vehicle Details Container
  // =========================================================================
  Widget _buildCommuterAndVehicleContainer(EmergencyIncident inc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF).withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Column(
        children: [
          // Commuter Profile Header
          Row(
            children: [
              // Circular driver/commuter profile image / initials
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Text(
                      'KP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name with verified badge + phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Kaveen Perera',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.verified,
                          size: 15,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+94 77 234 5678',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing badge: White pill with blue outline "Verified Fleet"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF93C5FD), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified Fleet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle & Plate Row (2 equal rounded cards side-by-side)
          Row(
            children: [
              // Card 1: Vehicle
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 16,
                            color: Color(0xFF0F2B48),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Toyota Axio, White',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Card 2: License Plate
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'License Plate',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: Color(0xFF0F2B48),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'WP CAH-5521',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reported Breakdown Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Location pin + REPORTED BREAKDOWN + 3 Passengers
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFDC2626),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'REPORTED BREAKDOWN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.groups_rounded, size: 14, color: Color(0xFF475569)),
                          SizedBox(width: 4),
                          Text(
                            '3 Passengers',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Quote body
                const Text(
                  '"Engine overheating with steam, pulled into emergency shoulder safely."',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                // Timestamp row
                Row(
                  children: const [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Requested 2 mins ago • Corporate SLA: 15 min dispatch target',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. Action Buttons (Call Driver & Accept Request)
  // =========================================================================
  Widget _buildActionButtons(BuildContext context, EmergencyIncident inc) {
    return Row(
      children: [
        // Left: Outlined / White rounded pill button "Call Driver"
        Expanded(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling Driver Kaveen Perera at +94 77 234 5678...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF0F2B48),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Call Driver',
                    style: TextStyle(
                      color: Color(0xFF0F2B48),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right: Solid vibrant orange-red pill button "Accept Request"
        Expanded(
          child: InkWell(
            onTap: () {
              widget.state.acceptIncident(inc.id);
              widget.state.updateDiagnosticCode('DTC-P0A80', _noteCtrl.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request accepted! High-voltage unit dispatched to KM 14.8.'),
                  duration: Duration(seconds: 2),
                ),
              );
              widget.onAccepted();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE63914),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE63914).withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Accept Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
  // 6. Safety Guideline Banner
  // =========================================================================
  Widget _buildSafetyGuidelineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: Color(0xFF1E40AF),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Follow corporate safety standard: deploy high-visibility warning cones immediately upon arrival.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF334155),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 7. Persistent Bottom Navigation Bar (5 Items, Safety SOS Active)
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
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(0);
                },
              ),
              // 2. Find Rides
              _buildNavItem(
                icon: Icons.search,
                label: 'Find Rides',
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                },
              ),
              // 3. My Trips
              _buildNavItem(
                icon: Icons.directions_car_outlined,
                label: 'My Trips',
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(2);
                },
              ),
              // 4. Safety SOS (Active with Light-Blue Pill and Red Asterisk)
              _buildSafetySosNavItem(
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(3);
                },
              ),
              // 5. Profile
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(4);
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
// Custom Painter for Colombo Highway Map (KM 14.8)
// =========================================================================
class _ColomboHighwayMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base terrain background (soft map sage green)
    final bgPaint = Paint()..color = const Color(0xFFDCECE1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Coastal water line / Indian Ocean on the left
    final waterPaint = Paint()..color = const Color(0xFFA5C9EB);
    final waterPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.35, size.width * 0.28, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.85, 0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Grid road network (thin white/grey lines)
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.48, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.72, 0), Offset(size.width * 0.78, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.4), Offset(size.width, size.height * 0.35), thinRoadPaint);
    canvas.drawLine(Offset(size.width * 0.30, size.height * 0.65), Offset(size.width, size.height * 0.70), thinRoadPaint);

    // 4. Colombo-Kottawa Highway route curve
    final highwayPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round;

    final startPt = Offset(size.width * 0.88, size.height * 0.22);
    final ctrlPt = Offset(size.width * 0.62, size.height * 0.48);
    final endPt = Offset(size.width * 0.42, size.height * 0.82);

    final hwyCurve = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..quadraticBezierTo(ctrlPt.dx, ctrlPt.dy, endPt.dx, endPt.dy);

    canvas.drawPath(hwyCurve, highwayPaint);

    // White dashed lane divider
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(hwyCurve, dashPaint);

    // Active tracking route line (vibrant blue with aura)
    final glowPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(hwyCurve, glowPaint);
    canvas.drawPath(hwyCurve, routePaint);

    // 5. Town Labels
    _drawLabel(canvas, 'Colombo', Offset(size.width * 0.38, size.height * 0.58), isBig: true);
    _drawLabel(canvas, 'Peliyagoda', Offset(size.width * 0.46, size.height * 0.46));
    _drawLabel(canvas, 'Wattala', Offset(size.width * 0.52, size.height * 0.28));
    _drawLabel(canvas, 'Kiribathgoda', Offset(size.width * 0.64, size.height * 0.32));
    _drawLabel(canvas, 'Kaduwela', Offset(size.width * 0.80, size.height * 0.60));

    // 6. Emergency Breakdown Vehicle Position Marker (End point)
    final evAura = Paint()..color = const Color(0xFFDC2626).withOpacity(0.25);
    canvas.drawCircle(endPt, 18, evAura);

    final evOuter = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(endPt, 8.5, evOuter);

    final evInner = Paint()..color = Colors.white;
    canvas.drawCircle(endPt, 5.5, evInner);

    final evDot = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(endPt, 3.2, evDot);

    // 7. Mechanic Patrol Van Position Marker (Start point)
    final vanAura = Paint()..color = const Color(0xFF2563EB).withOpacity(0.25);
    canvas.drawCircle(startPt, 18, vanAura);

    final vanOuter = Paint()..color = const Color(0xFF0F2B48);
    canvas.drawCircle(startPt, 8.5, vanOuter);

    final vanInner = Paint()..color = Colors.white;
    canvas.drawCircle(startPt, 5.5, vanInner);

    final vanDot = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(startPt, 3.2, vanDot);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, {bool isBig = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isBig ? const Color(0xFF0F172A) : const Color(0xFF475569),
          fontSize: isBig ? 13 : 8.5,
          fontWeight: isBig ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
