import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/emergency_models.dart';
import '../state/emergency_state.dart';

class DispatchStatusScreen extends StatefulWidget {
  final EmergencyState state;
  final VoidCallback onResolved;
  final Function(int index)? onNavigateTab;
  final VoidCallback? onBack;

  const DispatchStatusScreen({
    super.key,
    required this.state,
    required this.onResolved,
    this.onNavigateTab,
    this.onBack,
  });

  @override
  State<DispatchStatusScreen> createState() => _DispatchStatusScreenState();
}

class _DispatchStatusScreenState extends State<DispatchStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final inc = widget.state.currentIncident;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildHeaderAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Incident ID & Priority Tag Row
                _buildIncidentHeaderRow(inc),
                const SizedBox(height: 14),

                // 2. Service Progress Tracker Card
                _buildServiceProgressCard(inc),
                const SizedBox(height: 14),

                // 3. Commuter Incident & Live Telemetry Container
                _buildCommuterTelemetryCard(context, inc),
                const SizedBox(height: 14),

                // 4. Incident Diagnostics Box
                _buildDiagnosticsBox(inc),
                const SizedBox(height: 18),

                // 5. Primary Resolution Action Button
                _buildResolutionButton(context, inc),
                const SizedBox(height: 12),

                // 6. Guarantee Subtext
                _buildGuaranteeSubtext(),
                const SizedBox(height: 18),
              ],
            ),
          ),
          bottomNavigationBar: _buildPersistentMechanicBottomNavBar(context),
        );
      },
    );
  }

  // =========================================================================
  // 1. HEADER / APPBAR
  // =========================================================================
  PreferredSizeWidget _buildHeaderAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Leading: Soft-blue rounded squircle back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  widget.onNavigateTab?.call(0);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0F2B48),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title: Mechanic Incident Diagnostic
          const Expanded(
            child: Text(
              'Mechanic Incident Diagnostic',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Trailing: Circular dark profile button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onNavigateTab?.call(3);
              },
              borderRadius: BorderRadius.circular(21),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2B48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. INCIDENT ID & PRIORITY TAG ROW
  // =========================================================================
  Widget _buildIncidentHeaderRow(EmergencyIncident inc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Incident ',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '#${inc.id}',
                style: const TextStyle(
                  color: Color(0xFF0F2B48),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'PRIORITY 1 MOBILE UNIT',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. SERVICE PROGRESS TRACKER CARD
  // =========================================================================
  Widget _buildServiceProgressCard(EmergencyIncident inc) {
    // Current step evaluation: 1=Accepted, 2=En Route, 3=Arrived, 4=Resolved
    int currentStep = 2; // Default active step is 2 (En Route)
    if (inc.status == 'Accepted') currentStep = 1;
    if (inc.status == 'En Route') currentStep = 2;
    if (inc.status == 'Arrived') currentStep = 3;
    if (inc.status == 'Resolved') currentStep = 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE7F5), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Step $currentStep of 4',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4-step row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Accepted
              _buildStepItem(
                label: 'Accepted',
                stepNum: 1,
                currentStep: currentStep,
                icon: Icons.check,
              ),

              // Line 1
              _buildStepDividerLine(isPassed: currentStep >= 2),

              // Step 2: En Route (Active)
              _buildStepItem(
                label: 'En Route',
                stepNum: 2,
                currentStep: currentStep,
                icon: Icons.directions_car,
              ),

              // Line 2
              _buildStepDividerLine(isPassed: currentStep >= 3),

              // Step 3: Arrived
              _buildStepItem(
                label: 'Arrived',
                stepNum: 3,
                currentStep: currentStep,
                icon: Icons.location_on_outlined,
              ),

              // Line 3
              _buildStepDividerLine(isPassed: currentStep >= 4),

              // Step 4: Resolved
              _buildStepItem(
                label: 'Resolved',
                stepNum: 4,
                currentStep: currentStep,
                icon: Icons.check,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String label,
    required int stepNum,
    required int currentStep,
    required IconData icon,
  }) {
    final bool isPassed = currentStep > stepNum;
    final bool isCurrent = currentStep == stepNum;

    Color circleBg;
    Color iconColor;
    Border? border;

    if (isPassed) {
      circleBg = const Color(0xFF16A34A); // Green check
      iconColor = Colors.white;
    } else if (isCurrent) {
      circleBg = const Color(0xFF2563EB); // Vibrant active blue
      iconColor = Colors.white;
    } else {
      circleBg = Colors.white;
      iconColor = const Color(0xFF94A3B8);
      border = Border.all(color: const Color(0xFFCBD5E1), width: 1.5);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: border,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent
                ? const Color(0xFF2563EB)
                : (isPassed ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDividerLine({required bool isPassed}) {
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(top: 13, left: 4, right: 4),
        color: isPassed ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
      ),
    );
  }

  // =========================================================================
  // 4. COMMUTER INCIDENT & LIVE TELEMETRY CONTAINER
  // =========================================================================
  Widget _buildCommuterTelemetryCard(BuildContext context, EmergencyIncident inc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B48).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1 Expressway Map Box
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Custom Vector Map Canvas
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DispatchMapPainter(),
                    ),
                  ),

                  // Bottom-left overlay: Green navigation compass + Expressway Sector E01 • Lane 2
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B48).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.navigation, color: Color(0xFF22C55E), size: 12),
                          SizedBox(width: 5),
                          Text(
                            'Expressway Sector E01 • Lane 2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4.2 Estimated Arrival & Speed Gauge Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE7F5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left metrics column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED ARRIVAL',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '8',
                          style: TextStyle(
                            color: Color(0xFF0F2B48),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'mins',
                          style: TextStyle(
                            color: Color(0xFF0F2B48),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '2.4 km remaining',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Right circular radial speed gauge
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CustomPaint(
                    painter: _SpeedometerGaugePainter(),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.speed, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(height: 1),
                          Text(
                            '54 km/h',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4.3 Commuter Profile Details
          Row(
            children: [
              // Commuter Profile Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0F2B48),
                      child: const Center(
                        child: Text(
                          'KP',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Commuter Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inc.reporterName.isNotEmpty ? inc.reporterName : 'Kaveen Perera',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toyota Axio • Polar White (${inc.vehiclePlate})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 3),
                        Text(
                          'KM 14.8 Colombo-Kottawa',
                          style: TextStyle(
                            fontSize: 12,
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
          const SizedBox(height: 14),

          // 4.4 Action Triggers: Call Driver & GPS Route
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F1FC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dialing ${inc.reporterName}... (+94 77 123 4567)')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.phone, size: 16, color: Color(0xFF0F2B48)),
                        SizedBox(width: 8),
                        Text(
                          'Call Driver',
                          style: TextStyle(
                            color: Color(0xFF0F2B48),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F1FC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Launching GPS turn-by-turn route to KM 14.8...')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.near_me_outlined, size: 16, color: Color(0xFF0F2B48)),
                        SizedBox(width: 8),
                        Text(
                          'GPS Route',
                          style: TextStyle(
                            color: Color(0xFF0F2B48),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. INCIDENT DIAGNOSTICS BOX
  // =========================================================================
  Widget _buildDiagnosticsBox(EmergencyIncident inc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE7F5), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.build_outlined, size: 16, color: Color(0xFF0F2B48)),
                  SizedBox(width: 8),
                  Text(
                    'Incident Diagnostics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2B48),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text(
                  'Code: HYB-88',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Inverter overheating warning flagged on high-speed cruise. Driver parked safely at emergency shoulder bay. Toolset #4 and replacement auxiliary inverter unit pre-loaded.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. PRIMARY RESOLUTION ACTION BUTTON & SUBTEXT
  // =========================================================================
  Widget _buildResolutionButton(BuildContext context, EmergencyIncident inc) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          widget.state.updateIncidentStatus(inc.id, 'Resolved');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incident #EM-9042 successfully marked as Resolved! Telemetry synced.'),
            ),
          );
          widget.onResolved();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Mark as Resolved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeSubtext() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.shield_outlined, size: 16, color: Color(0xFF64748B)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Corporate mobility guarantee credited to passenger accounts. Auto-telemetry sync completes upon resolution submission.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 7. PERSISTENT 4-TAB MECHANIC BOTTOM NAVIGATION BAR (Dispatch Tab Active)
  // =========================================================================
  Widget _buildPersistentMechanicBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: Job Queue
            _buildMechanicNavItem(
              index: 0,
              label: 'Job Queue',
              isSelected: false,
              icon: Icons.format_list_bulleted_outlined,
            ),

            // Tab 1: Diagnostics
            _buildMechanicNavItem(
              index: 1,
              label: 'Diagnostics',
              isSelected: false,
              icon: Icons.build_circle_outlined,
            ),

            // Tab 2: Dispatch (Active with warm cream/yellow pill highlight)
            _buildMechanicNavItem(
              index: 2,
              label: 'Dispatch',
              isSelected: true,
              icon: Icons.location_on,
            ),

            // Tab 3: Profile
            _buildMechanicNavItem(
              index: 3,
              label: 'Profile',
              isSelected: false,
              icon: Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicNavItem({
    required int index,
    required String label,
    required bool isSelected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        if (index == 2) return;
        if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0F2B48),
                  size: 22,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Icon(
                  icon,
                  color: const Color(0xFF64748B),
                  size: 22,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SPEEDOMETER GAUGE CUSTOM PAINTER
// ===========================================================================
class _SpeedometerGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    const startAngle = 0.75 * math.pi;
    const totalSweep = 1.5 * math.pi;

    // Track Paint (light blue background arc)
    final trackPaint = Paint()
      ..color = const Color(0xFFDBEAFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // Active Progress Paint (~65% speed value)
    final progressPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * 0.65,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// VECTOR MAP CANVAS CUSTOM PAINTER
// ===========================================================================
class _DispatchMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base land background (light cream / soft land)
    final landPaint = Paint()..color = const Color(0xFFEFF4EC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // 2. Coastline / Ocean (Water in the top-left)
    final waterPaint = Paint()..color = const Color(0xFFBAE6FD).withOpacity(0.85);
    final waterPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.35, size.width * 0.26, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.85, 0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Grid road network (thin blue-grey route lines)
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawLine(Offset(size.width * 0.42, 0), Offset(size.width * 0.50, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.68, 0), Offset(size.width * 0.75, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.28, size.height * 0.38), Offset(size.width, size.height * 0.32), roadPaint);
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.68), Offset(size.width, size.height * 0.65), roadPaint);

    // 4. Colombo-Kottawa Highway route curve (Blue corridor)
    final highwayPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final startPt = Offset(size.width * 0.90, size.height * 0.30);
    final ctrlPt = Offset(size.width * 0.60, size.height * 0.55);
    final endPt = Offset(size.width * 0.40, size.height * 0.78);

    final hwyCurve = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..quadraticBezierTo(ctrlPt.dx, ctrlPt.dy, endPt.dx, endPt.dy);

    canvas.drawPath(hwyCurve, highwayPaint);

    // Vibrant blue live tracking route line
    final routeGlow = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final routeLine = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(hwyCurve, routeGlow);
    canvas.drawPath(hwyCurve, routeLine);

    // 5. Town / Landmark labels
    _drawLabel(canvas, 'Colombo', Offset(size.width * 0.42, size.height * 0.52), isProminent: true);
    _drawLabel(canvas, 'Peliyagoda', Offset(size.width * 0.52, size.height * 0.22));
    _drawLabel(canvas, 'Pettah', Offset(size.width * 0.34, size.height * 0.42));
    _drawLabel(canvas, 'Gonawala', Offset(size.width * 0.78, size.height * 0.18));
    _drawLabel(canvas, 'Diyatha Uyana Park', Offset(size.width * 0.54, size.height * 0.70));
    _drawLabel(canvas, 'CINEC', Offset(size.width * 0.76, size.height * 0.56));

    // Route markers (B231, AB10)
    _drawRouteBadge(canvas, 'B231', Offset(size.width * 0.64, size.height * 0.30));
    _drawRouteBadge(canvas, 'A010', Offset(size.width * 0.80, size.height * 0.28));

    // 6. Breakdown marker (Red marker near end point)
    final redAura = Paint()..color = const Color(0xFFDC2626).withOpacity(0.25);
    canvas.drawCircle(endPt, 14, redAura);
    final redOuter = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(endPt, 7, redOuter);
    final redInner = Paint()..color = Colors.white;
    canvas.drawCircle(endPt, 3.5, redInner);

    // 7. En-route Patrol Van marker (Blue marker near middle)
    final vanPt = Offset(size.width * 0.65, size.height * 0.52);
    final blueAura = Paint()..color = const Color(0xFF2563EB).withOpacity(0.25);
    canvas.drawCircle(vanPt, 14, blueAura);
    final blueOuter = Paint()..color = const Color(0xFF0F2B48);
    canvas.drawCircle(vanPt, 7, blueOuter);
    final blueInner = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(vanPt, 3.5, blueInner);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, {bool isProminent = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isProminent ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          fontSize: isProminent ? 12 : 8.5,
          fontWeight: isProminent ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  void _drawRouteBadge(Canvas canvas, String badge, Offset position) {
    final bgPaint = Paint()..color = const Color(0xFFCBD5E1);
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(position.dx, position.dy, 22, 10), const Radius.circular(3));
    canvas.drawRRect(rrect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: badge,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 6.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(position.dx + 2, position.dy + 1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
