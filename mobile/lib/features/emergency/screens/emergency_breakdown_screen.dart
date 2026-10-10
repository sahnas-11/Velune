import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/emergency_state.dart';

class EmergencyBreakdownScreen extends StatefulWidget {
  final EmergencyState state;
  final VoidCallback onMechanicRequested;
  final VoidCallback? onBack;
  final Function(int index)? onNavigateTab;

  const EmergencyBreakdownScreen({
    super.key,
    required this.state,
    required this.onMechanicRequested,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<EmergencyBreakdownScreen> createState() => _EmergencyBreakdownScreenState();
}

class _EmergencyBreakdownScreenState extends State<EmergencyBreakdownScreen> {
  String _selectedIssue = 'EV / Battery';
  final TextEditingController _notesCtrl = TextEditingController(
    text: 'Vehicle propulsion failure on expressway hard shoulder.',
  );
  final String _autoKm = 'KM 74.2 Southbound (Near Welipenna)';

  final List<Map<String, dynamic>> _issueTypes = [
    {'label': 'Flat Tire', 'icon': Icons.album_outlined},
    {'label': 'EV / Battery', 'icon': Icons.bolt_rounded},
    {'label': 'Overheating', 'icon': Icons.thermostat_rounded},
    {'label': 'Mechanical Lock', 'icon': Icons.lock_outline_rounded},
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Sub-Header
              _buildTopSubHeader(context),
              const SizedBox(height: 14),

              // 2. Screen Title
              _buildScreenTitle(),
              const SizedBox(height: 14),

              // 3. Hero Banner Card
              _buildHeroBannerCard(),
              const SizedBox(height: 14),

              // 4. Live Expressway Imagery & Location Cards
              _buildExpresswayPhotoCard(),
              const SizedBox(height: 10),
              _buildDetectedLocationCard(),
              const SizedBox(height: 10),
              _buildRegisteredVehicleCard(),
              const SizedBox(height: 16),

              // 5. Symptom / Issue Selector
              _buildIssueSelector(),
              const SizedBox(height: 16),

              // 6. Primary Call-To-Action Area (Request Mechanic & Call Hotline)
              _buildCallToActionArea(context),
              const SizedBox(height: 16),

              // 7. Automated Safety Protocol & Passenger Status Card
              _buildSafetyProtocolCard(),
              const SizedBox(height: 10),
              _buildPassengerStatusCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // 8. Persistent Bottom Navigation Bar matching 1st UI page
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // =========================================================================
  // 1. Top Sub-Header
  // =========================================================================
  Widget _buildTopSubHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Circular back button <
        InkWell(
          onTap: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF0F2B48),
              size: 26,
            ),
          ),
        ),

        // Center: Light-red rounded pill badge "● PRIORITY ALERT"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECACA), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                'PRIORITY ALERT',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),

        // Right: Light circular pin / location icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. Screen Title
  // =========================================================================
  Widget _buildScreenTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'INCIDENT SUPPORT',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Emergency Breakdown',
          style: TextStyle(
            color: Color(0xFFB91C1C),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. Hero Banner Card
  // =========================================================================
  Widget _buildHeroBannerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEDEC),
            Color(0xFFF5F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB91C1C).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Red icon box + Title & Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Vehicle issue? Get help now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Rapid roadside dispatch for corporate carpool commuters along Southern Corridor.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Pill Banner: Nearest Mobile Unit info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: 0.6,
                  child: const Icon(
                    Icons.navigation,
                    color: Color(0xFFDC2626),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Nearest Mobile Unit:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Unit #04 • 8-12 mins away',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
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
  // 4. Live Expressway Imagery & Location Cards
  // =========================================================================
  Widget _buildExpresswayPhotoCard() {
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A2B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Custom Painter of scenic aerial expressway through Sri Lankan hills
            Positioned.fill(
              child: CustomPaint(
                painter: _ExpresswayAerialPainter(),
              ),
            ),

            // Bottom-left overlay: Red pin icon + "GPS Lock: High Precision (±4m)"
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFFEF4444),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'GPS Lock: High Precision (±4m)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-right overlay: Dark pill badge "Live"
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Live',
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

  Widget _buildDetectedLocationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // Light blue squircle with radar / GPS target icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gps_fixed_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Subtitle, Bold text, Subtext
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DETECTED LOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Southern Expressway, $_autoKm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '(Near Welipenna Service Area, Southbound)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // Light blue squircle with car icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Vehicle title row + subtext
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REGISTERED VEHICLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'Toyota Prius (Hybrid)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CAB-8492',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Corporate Carpool Pass • Tier A Priority',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
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
  // 5. Symptom / Issue Selector
  // =========================================================================
  Widget _buildIssueSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Primary Issue (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _issueTypes.map((item) {
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isSelected = _selectedIssue == label;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedIssue = label);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFB91C1C),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 6. Primary Call-To-Action Area
  // =========================================================================
  Widget _buildCallToActionArea(BuildContext context) {
    return Column(
      children: [
        // Large Solid Crimson Red Button (Request Mechanic)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: const Color(0xFFB91C1C).withOpacity(0.35),
            ),
            onPressed: () {
              widget.state.createBreakdownIncident(
                _selectedIssue,
                _notesCtrl.text.trim(),
                _autoKm,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Priority alert dispatched to Southern Patrol Unit #04!'),
                  duration: Duration(seconds: 2),
                ),
              );
              widget.onMechanicRequested();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.build_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Request Mechanic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Subtext below button
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sends your live GPS location, vehicle details, and mobile contact directly to the nearest highway dispatch unit.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Secondary Action Button: Full-width Outlined "Call Hotline"
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dialing 1990 Toll-Free Expressway Emergency Hotline...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Call Hotline',
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
        const SizedBox(height: 12),

        // Contact footer row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Toll-Free Emergency: 1990',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              'Fleet Control: 011-2004000',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // 7. Automated Safety Protocol & Passenger Status Card
  // =========================================================================
  Widget _buildSafetyProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green shield checkmark icon
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Automated Carpool Safety Protocol',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your 3 registered ride partners will be notified automatically with an updated safety ETA, and corporate mobility dispatch will monitor your status until you resume transit.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // Overlapping circular initials chips
          SizedBox(
            width: 58,
            height: 26,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2B48),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        'DK',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        'SL',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        'AP',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          const Text(
            '3 passengers on-board',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),

          // Right label: "All Safe ✓"
          Row(
            children: const [
              Text(
                'All Safe',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF047857),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF047857),
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 8. Bottom Navigation Bar matching 1st UI page
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
// Scenic Aerial Expressway Painter (matching Image 2 highway view)
// =========================================================================
class _ExpresswayAerialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky & horizon background
    final skyPaint = Paint()..color = const Color(0xFF90C2DE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.28), skyPaint);

    // 2. Distant mountain ridge
    final mountainPaint = Paint()..color = const Color(0xFF4C7B65);
    final mountainPath = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.16, size.width * 0.5, size.height * 0.22)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.14, size.width, size.height * 0.26)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(0, size.height * 0.3)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // 3. Rolling tropical jungle hills (shades of lush canopy)
    final hillPaint1 = Paint()..color = const Color(0xFF2D6938);
    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.28, size.width, size.height * 0.24)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath1, hillPaint1);

    // Texture dots / tree canopy patches
    final canopyLight = Paint()..color = const Color(0xFF3E834B);
    final canopyDark = Paint()..color = const Color(0xFF1E522B);
    final rnd = Random(42);
    for (int i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = size.height * 0.28 + rnd.nextDouble() * (size.height * 0.72);
      final r = 4.0 + rnd.nextDouble() * 9.0;
      canvas.drawCircle(Offset(x, y), r, i % 2 == 0 ? canopyLight : canopyDark);
    }

    // 4. Dual Carriageway Expressway asphalt ribbon curving through the center
    // Left lane asphalt
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.butt;

    final roadPath = Path()
      ..moveTo(size.width * 0.49, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.46, size.height * 0.60, size.width * 0.49, size.height);

    canvas.drawPath(roadPath, roadPaint);

    // Outer hard shoulders
    final shoulderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 29.0;
    canvas.drawPath(roadPath, shoulderPaint);
    canvas.drawPath(roadPath, roadPaint);

    // Green central median barrier
    final medianPaint = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(roadPath, medianPaint);

    // White highway edge lines & dashed lane lines
    final whiteLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final leftLanePath = Path()
      ..moveTo(size.width * 0.46, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.43, size.height * 0.60, size.width * 0.44, size.height);
    canvas.drawPath(leftLanePath, whiteLinePaint);

    final rightLanePath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.49, size.height * 0.60, size.width * 0.54, size.height);
    canvas.drawPath(rightLanePath, whiteLinePaint);

    // Miniature car dots driving on the expressway
    final carPaintWhite = Paint()..color = Colors.white;
    final carPaintRed = Paint()..color = const Color(0xFFEF4444);
    final carPaintBlue = Paint()..color = const Color(0xFF3B82F6);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.44, size.height * 0.52), width: 3.5, height: 6), const Radius.circular(1)), carPaintWhite);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.45, size.height * 0.78), width: 4.5, height: 8), const Radius.circular(1.5)), carPaintBlue);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.52, size.height * 0.65), width: 4.0, height: 7), const Radius.circular(1)), carPaintRed);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.51, size.height * 0.40), width: 3.0, height: 5), const Radius.circular(1)), carPaintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
