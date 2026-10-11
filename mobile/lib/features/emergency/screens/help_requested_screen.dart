import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/emergency_state.dart';

class HelpRequestedScreen extends StatelessWidget {
  final EmergencyState state;
  final VoidCallback onIncidentClosed;
  final Function(int index)? onNavigateTab;

  const HelpRequestedScreen({
    super.key,
    required this.state,
    required this.onIncidentClosed,
    this.onNavigateTab,
  });

  void _confirmCancelIncident(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Emergency Request?'),
        content: const Text(
          'Are you sure your vehicle is safely operational? Roadside Unit #04 will stand down.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.cancelIncident();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency incident cancelled. Roadside unit notified.')),
              );
              onIncidentClosed();
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final inc = state.currentIncident;

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
                // 1. Status Banner Container (Dispatch Active • Incident #RD-8492)
                _buildStatusBanner(inc),
                const SizedBox(height: 14),

                // 2. Assistance Dispatched Card
                _buildAssistanceDispatchedCard(inc),
                const SizedBox(height: 14),

                // 3. Technician & Live Tracking Details Card
                _buildTechnicianAndTrackingCard(context, inc),
                const SizedBox(height: 14),

                // 4. Escalation / Hotline Card
                _buildEscalationHotlineCard(context),
                const SizedBox(height: 14),

                // 5. Corporate Safeguard Activated Card
                _buildCorporateSafeguardCard(),
                const SizedBox(height: 18),

                // Cancel Emergency Request Action
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmCancelIncident(context),
                    icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 16),
                    label: const Text(
                      'Cancel Emergency Request',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // 6. Persistent Bottom Navigation Bar matching 1st UI page
          bottomNavigationBar: _buildBottomNavBar(context),
        );
      },
    );
  }

  // =========================================================================
  // 1. Header / AppBar & Status Banner
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

  Widget _buildStatusBanner(dynamic inc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Blue indicator dot + "Dispatch Active"
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Dispatch Active',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          // Right: Light gray/blue pill badge with "Incident #RD-8492"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
            ),
            child: const Text(
              'Incident #RD-8492',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. Assistance Dispatched Card
  // =========================================================================
  Widget _buildAssistanceDispatchedCard(dynamic inc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Top Center Circular Icon Container with small green check badge
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F2B48),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            'Assistance Dispatched',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Subtitle
          const Text(
            'Dispatcher notified at 8:42 AM • Corporate Priority 1',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Segmented progress step indicator (3 dark active bar segments, 1 light inactive segment)
          Row(
            children: [
              _buildSegmentBar(active: true),
              const SizedBox(width: 6),
              _buildSegmentBar(active: true),
              const SizedBox(width: 6),
              _buildSegmentBar(active: true),
              const SizedBox(width: 6),
              _buildSegmentBar(active: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBar({required bool active}) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F2B48) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. Technician & Live Tracking Details Card
  // =========================================================================
  Widget _buildTechnicianAndTrackingCard(BuildContext context, dynamic inc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technician Profile Row
          Row(
            children: [
              // Avatar with verified badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Text(
                      'NS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                        fontSize: 15,
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
                        size: 14,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name, subtitle & rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nalin Silva',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Text(
                          'Certified Roadside Tech',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        Text(
                          ' 4.9 (318 fleet assists)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right tag: Service Unit / Van #04
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Service Unit',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Van #04',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Arrival Metrics Row (Estimated Arrival | Distance)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: Row(
              children: [
                // Left Metric: ESTIMATED ARRIVAL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ESTIMATED ARRIVAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '15 mins',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider Line
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFCBD5E1),
                ),

                // Right Metric: DISTANCE
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DISTANCE',
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
                            Transform.rotate(
                              angle: 0.6,
                              child: const Icon(
                                Icons.navigation,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '6.8 km',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
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
          ),
          const SizedBox(height: 14),

          // Interactive Route Map Box
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EDE5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // High-fidelity tracking route map painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TechnicianTrackingMapPainter(),
                    ),
                  ),

                  // Top-left overlay: Blue dot + "Live En Route • Baseline Highway"
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Live En Route • Baseline Highway',
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

                  // Top-right overlay: Dark pill badge "Express"
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B48).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Express',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-left overlay: Red target pin + "Your EV #821"
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.88),
                        borderRadius: BorderRadius.circular(14),
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
                            'Your EV #821',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
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

          // Contact Actions Row (Call Nalin | Message)
          Row(
            children: [
              // Dark navy pill button: Phone icon + "Call Nalin"
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling Technician Nalin Silva at 077-4492811...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2B48),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.phone_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Call Nalin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Light blue pill button: Chat bubble icon + "Message"
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening live technician dispatch chat with Nalin...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1E40AF), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Message',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
  // 4. Escalation / Hotline Card
  // =========================================================================
  Widget _buildEscalationHotlineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Row with Light red/coral squircle + Urgent title & subtitle
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Urgent or Unsafe Location?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Immediate corporate fleet escalation desk',
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
          const SizedBox(height: 14),

          // Full-width Light Blue Rounded Pill Button: Call Hotline (24/7 Dispatch)
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dialing 24/7 Priority Emergency Dispatch Desk 1990...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
              ),
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
                    'Call Hotline (24/7 Dispatch)',
                    style: TextStyle(
                      color: Color(0xFF0F2B48),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. Corporate Safeguard Activated Card
  // =========================================================================
  Widget _buildCorporateSafeguardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green shield icon
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Body description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Corporate Safeguard Activated',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Company Fleet Admin notified • Alternative carpool pickup standby enabled for passengers at 09:00 AM.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF334155),
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

  // =========================================================================
  // 6. Persistent Bottom Navigation Bar (matching 1st UI page)
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
// Technician Tracking Map Painter (Van #04 en route to Commuter EV)
// =========================================================================
class _TechnicianTrackingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base map terrain (soft map sage green)
    final bgPaint = Paint()..color = const Color(0xFFDCECE1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Coastal water line / river in background
    final waterPaint = Paint()..color = const Color(0xFFB8D8F8);
    final waterPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.88, size.width * 0.6, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Grid road network
    final thinRoad = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.3, size.height), thinRoad);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), thinRoad);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.45), thinRoad);

    // 4. Baseline Highway arterial curve
    final highwayPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    final startVan = Offset(size.width * 0.82, size.height * 0.22);
    final ctrlPt = Offset(size.width * 0.48, size.height * 0.52);
    final endEV = Offset(size.width * 0.22, size.height * 0.78);

    final roadCurve = Path()
      ..moveTo(startVan.dx, startVan.dy)
      ..quadraticBezierTo(ctrlPt.dx, ctrlPt.dy, endEV.dx, endEV.dy);

    canvas.drawPath(roadCurve, highwayPaint);

    // White dashed lane line
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(roadCurve, dashPaint);

    // 5. Active live en-route dispatch curve (vibrant blue line with glow)
    final glowPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(roadCurve, glowPaint);
    canvas.drawPath(roadCurve, routePaint);

    // 6. Van #04 Position Marker (Service Vehicle at start point)
    final vanAura = Paint()..color = const Color(0xFF2563EB).withOpacity(0.24);
    canvas.drawCircle(startVan, 18, vanAura);

    final vanOuter = Paint()..color = const Color(0xFF0F2B48);
    canvas.drawCircle(startVan, 8.5, vanOuter);

    final vanInner = Paint()..color = Colors.white;
    canvas.drawCircle(startVan, 5.5, vanInner);

    final vanDot = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(startVan, 3.2, vanDot);

    // 7. Commuter EV #821 Position Marker (Breakdown vehicle at end point)
    final evAura = Paint()..color = const Color(0xFFEF4444).withOpacity(0.24);
    canvas.drawCircle(endEV, 18, evAura);

    final evOuter = Paint()..color = const Color(0xFFB91C1C);
    canvas.drawCircle(endEV, 8.5, evOuter);

    final evInner = Paint()..color = Colors.white;
    canvas.drawCircle(endEV, 5.5, evInner);

    final evDot = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(endEV, 3.2, evDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
