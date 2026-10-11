import 'package:flutter/material.dart';
import '../models/emergency_models.dart';
import '../state/emergency_state.dart';

class MechanicQueueScreen extends StatefulWidget {
  final EmergencyState state;
  final Function(EmergencyIncident) onInspectIncident;
  final Function(int index)? onNavigateTab;
  final int selectedTabIndex;

  const MechanicQueueScreen({
    super.key,
    required this.state,
    required this.onInspectIncident,
    this.onNavigateTab,
    this.selectedTabIndex = 0,
  });

  @override
  State<MechanicQueueScreen> createState() => _MechanicQueueScreenState();
}

class _MechanicQueueScreenState extends State<MechanicQueueScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final allIncidents = widget.state.queue;
        final filtered = allIncidents.where((i) {
          if (_selectedFilter == 'High Urgency') {
            return i.priority.toLowerCase().contains('critical') || i.priority.toLowerCase().contains('high');
          }
          if (_selectedFilter == 'Expressway') {
            return i.locationText.toLowerCase().contains('expressway') ||
                i.locationText.toLowerCase().contains('highway');
          }
          if (_selectedFilter == 'Resolved') {
            return i.status.toLowerCase() == 'resolved';
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildHeaderAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Fleet Metric Banner
                _buildHeroMetricBanner(allIncidents.length),
                const SizedBox(height: 14),

                // 2. Horizontal Category Filter Chips
                _buildCategoryFilterChips(allIncidents.length),
                const SizedBox(height: 16),

                // 3. Incident Cards List
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.asMap().entries.map((entry) {
                    final index = entry.key;
                    final incident = entry.value;
                    return _buildIncidentCard(context, incident, index);
                  }),

                // 4. Bottom Radar Sync Strip
                _buildRadarSyncStrip(),
                const SizedBox(height: 12),
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
                if (Navigator.canPop(context)) {
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

          // Title: Mechanic Job Queue
          const Expanded(
            child: Text(
              'Mechanic Job Queue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
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
  // 2. HERO FLEET METRIC BANNER
  // =========================================================================
  Widget _buildHeroMetricBanner(int incidentCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D253F),
            Color(0xFF06182D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D253F).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative background concentric radar arcs
            Positioned.fill(
              child: CustomPaint(
                painter: _RadarArcsPainter(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: On duty banner + Live radar badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6622C55E),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'ON DUTY • SOUTHERN CORRIDOR FLEET DISPATCH',
                            style: TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.wifi_tethering, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Live',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Bottom Row: Count & Avg response
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$incidentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Active Incidents',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Avg Response',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '6.2m',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. HORIZONTAL CATEGORY FILTER CHIPS
  // =========================================================================
  Widget _buildCategoryFilterChips(int totalCount) {
    final filters = ['All', 'High Urgency', 'Expressway', 'Resolved'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;

          Widget? leadingWidget;
          if (f == 'High Urgency') {
            leadingWidget = Container(
              margin: const EdgeInsets.only(right: 6),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            );
          }

          Widget? trailingBadge;
          if (f == 'All' && isSelected) {
            trailingBadge = Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A5F),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedFilter = f);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F2B48) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?leadingWidget,
                      Text(
                        f,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      ?trailingBadge,
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================================
  // 4. INCIDENT CARDS (DYNAMICALLY STYLED MATCHING SPEC)
  // =========================================================================
  Widget _buildIncidentCard(BuildContext context, EmergencyIncident incident, int index) {
    final isCritical = incident.priority.toLowerCase().contains('critical');
    final isDispatched = incident.status.toLowerCase() == 'dispatched' ||
        incident.priority.toLowerCase().contains('patrol');

    // Commuter squircle icon
    IconData commuterIcon;
    Color commuterIconColor = const Color(0xFF0F2B48);
    if (isCritical) {
      commuterIcon = Icons.emergency_outlined;
      commuterIconColor = const Color(0xFF0F2B48);
    } else if (isDispatched) {
      commuterIcon = Icons.directions_car_outlined;
      commuterIconColor = const Color(0xFF475569);
    } else {
      commuterIcon = Icons.build_outlined;
      commuterIconColor = const Color(0xFF2563EB);
    }

    // Diagnosis subcard icon
    IconData issueIcon;
    Color issueIconColor = const Color(0xFFDC2626);
    if (isCritical) {
      issueIcon = Icons.warning_amber_rounded;
      issueIconColor = const Color(0xFFDC2626);
    } else if (isDispatched) {
      issueIcon = Icons.battery_alert_outlined;
      issueIconColor = const Color(0xFF475569);
    } else {
      issueIcon = Icons.adjust;
      issueIconColor = const Color(0xFF2563EB);
    }

    // Location icon
    IconData locIcon = Icons.location_on_outlined;
    if (!isCritical && !isDispatched) {
      locIcon = Icons.near_me_outlined;
    }

    // Action button label & icon
    final bool isInspect = isCritical || index == 0;
    final String actionText = isInspect ? 'Inspect Request' : 'View';
    final IconData actionIcon = isInspect ? Icons.assignment_ind_outlined : Icons.visibility_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCE7F5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B48).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1 Status Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isDispatched)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.airport_shuttle_outlined, size: 12, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text(
                            'DISPATCHED',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '! NEW',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    incident.priority,
                    style: TextStyle(
                      color: isCritical
                          ? const Color(0xFFDC2626)
                          : (isDispatched ? const Color(0xFF2563EB) : const Color(0xFF475569)),
                      fontSize: 12,
                      fontWeight: (isCritical || isDispatched) ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    incident.reportedAt,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4.2 Commuter Row
          Row(
            children: [
              // White squircle icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(commuterIcon, color: commuterIconColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Commuter info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.reporterName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${incident.vehicleModel} (${incident.vehiclePlate})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Phone link or Dispatched badge
              if (isDispatched)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Unit 04 ETA 4m',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dialing ${incident.reporterPhone}...')),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, size: 13, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            incident.reporterPhone,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
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
          const SizedBox(height: 12),

          // 4.3 Diagnosis White Sub-card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(issueIcon, size: 16, color: issueIconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(locIcon, size: 15, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident.locationText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4.4 Action Buttons Row
          Row(
            children: [
              // Expanded dark navy button
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2B48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () => widget.onInspectIncident(incident),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          actionText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Trailing square/squircle navigation pointer button
              SizedBox(
                width: 46,
                height: 46,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting live GPS route to ${incident.locationText}...'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.near_me_outlined,
                        size: 20,
                        color: Color(0xFF0F2B48),
                      ),
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
  // 5. BOTTOM RADAR SYNC STRIP
  // =========================================================================
  Widget _buildRadarSyncStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.sync, size: 15, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Auto-dispatch radar active • Refreshing eve',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Synced',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF16A34A)),
          SizedBox(height: 12),
          Text(
            'No Incidents Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          SizedBox(height: 4),
          Text(
            'No breakdown reports match the selected filter criteria.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. PERSISTENT 4-TAB MECHANIC BOTTOM NAVIGATION BAR (Retained from 1st UI)
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
            // Tab 0: Job Queue (Selected with warm cream/yellow pill highlight)
            _buildMechanicNavItem(
              index: 0,
              label: 'Job Queue',
              isSelected: true,
              selectedIcon: Icons.format_list_bulleted_rounded,
              unselectedIcon: Icons.format_list_bulleted_outlined,
            ),

            // Tab 1: Diagnostics
            _buildMechanicNavItem(
              index: 1,
              label: 'Diagnostics',
              isSelected: false,
              selectedIcon: Icons.build_circle,
              unselectedIcon: Icons.build_circle_outlined,
            ),

            // Tab 2: Dispatch
            _buildMechanicNavItem(
              index: 2,
              label: 'Dispatch',
              isSelected: false,
              selectedIcon: Icons.location_on,
              unselectedIcon: Icons.location_on_outlined,
            ),

            // Tab 3: Profile
            _buildMechanicNavItem(
              index: 3,
              label: 'Profile',
              isSelected: false,
              selectedIcon: Icons.person,
              unselectedIcon: Icons.person_outline,
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
    required IconData selectedIcon,
    required IconData unselectedIcon,
  }) {
    return InkWell(
      onTap: () {
        if (index == 0) return;
        if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(index);
        } else if (index == 1 && widget.state.queue.isNotEmpty) {
          widget.onInspectIncident(widget.state.queue.first);
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
                  selectedIcon,
                  color: const Color(0xFFD97706),
                  size: 22,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Icon(
                  unselectedIcon,
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

/// Concentric radar arcs custom painter for the hero banner
class _RadarArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.88, size.height * 0.45);
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, 38, paint);
    canvas.drawCircle(center, 72, paint);
    canvas.drawCircle(center, 110, paint);
    canvas.drawCircle(center, 150, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
