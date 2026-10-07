import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class HomeHubScreen extends StatelessWidget {
  final Function(int mainTab, {int? subIndex}) onNavigateToModule;

  const HomeHubScreen({
    super.key,
    required this.onNavigateToModule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: VeluneAppBar(
        title: 'Velune Carpool Hub',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: VeluneColors.primaryNavy),
            tooltip: 'Live Alerts',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('3 Ride Partners notified • Expressway Unit #04 active'),
                  backgroundColor: VeluneColors.primaryNavy,
                ),
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
            // Welcome Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: VeluneColors.navyGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: VeluneColors.primaryNavy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VELUNE COMMUTE',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                              Text(
                                'Enterprise Mobility Hub',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: VeluneColors.success.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: VeluneColors.success, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: VeluneColors.success, size: 8),
                            SizedBox(width: 6),
                            Text('ALL SYSTEMS LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Unified office carpooling with automated distance fare splitting, real-time emergency breakdown patrol, and corporate Scope 3 ESG analytics.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildHeroBadge(Icons.check_circle_outline, '17 Working Screens'),
                      _buildHeroBadge(Icons.storage_outlined, 'MySQL & SQLite CRUD'),
                      _buildHeroBadge(Icons.lock_outline, 'Sanctum Token Auth'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Jump Section Header
            const Text(
              'PLATFORM MODULES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            // 1. Module 2: Booking & Fare Settlement (Tissera)
            _buildModuleCard(
              context,
              number: 'MODULE 02',
              title: 'Carpool Booking & Fare Splitting',
              owner: 'IT23555808 • Tissera J H J D',
              color: VeluneColors.accentBlue,
              icon: Icons.directions_car_filled,
              description: 'Booking confirmation, 3-minute grace pickup countdown, real-time trip fare telemetry, automated 75% corporate subsidy split, and Workday ERP receipt filing.',
              screensCount: '5 Screens',
              onTap: () => onNavigateToModule(1, subIndex: 0),
            ),

            const SizedBox(height: 14),

            // 2. Module 3: Emergency Assistance & Fleet Dispatch (Jayathilaka)
            _buildModuleCard(
              context,
              number: 'MODULE 03',
              title: 'Emergency Assistance & Fleet Dispatch',
              owner: 'IT23829824 • Jayathilaka G.G.H.R',
              color: VeluneColors.danger,
              icon: Icons.emergency,
              description: 'Active ride monitoring, 2-tap roadside breakdown alert, live GPS & KM 74.2 marker lock, 4-step assistance progress, and mechanic job queue with OBD triage.',
              screensCount: '6 Screens (Commuter + Mechanic)',
              onTap: () => onNavigateToModule(2, subIndex: 0),
            ),

            const SizedBox(height: 14),

            // 3. Module 4: HR Corporate & System Integration (Amanda)
            _buildModuleCard(
              context,
              number: 'MODULE 04',
              title: 'HR Corporate & System Integration',
              owner: 'IT23555112 • Amanda Jayawardena',
              color: VeluneColors.primaryNavy,
              icon: Icons.business_center,
              description: 'Campus decarbonization KPI rings, Scope 3 avoided carbon logs, Deck B priority parking bay allocations, corporate ESG audit reports, and commuter incentives.',
              screensCount: '6 Screens',
              onTap: () => onNavigateToModule(3, subIndex: 0),
            ),

            const SizedBox(height: 24),

            // Live Commute Snapshot Card
            const Text(
              'TODAYS ACTIVE COMMUTE SNAPSHOT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.near_me, color: VeluneColors.accentBlue),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matara Clock Tower -> Colombo WTC',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary),
                            ),
                            Text(
                              'Driver: Kasun Silva (Prius CAB-4288) • 06:15 AM',
                              style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(
                        text: 'Confirmed',
                        bgColor: VeluneColors.successBg,
                        textColor: VeluneColors.success,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniMetric('Gross Fare', 'LKR 7,800'),
                      _buildMiniMetric('Enterprise Subsidy', '-75% (LKR 5,850)'),
                      _buildMiniMetric('Your Share', 'LKR 800'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onNavigateToModule(1, subIndex: 0),
                          icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                          label: const Text('View Booking Flow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VeluneColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => onNavigateToModule(2, subIndex: 1),
                        icon: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: const Text('Emergency'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VeluneColors.dangerBg,
                          foregroundColor: VeluneColors.danger,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Hotline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VeluneColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: VeluneColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Expressway Emergency Patrol',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.danger),
                        ),
                        Text(
                          'Dial 1990 (Toll-Free) or Fleet Control 011-2004000',
                          style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String number,
    required String title,
    required String owner,
    required Color color,
    required IconData icon,
    required String description,
    required String screensCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            number,
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: VeluneColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              screensCount,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: VeluneColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VeluneColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Owner: $owner',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: VeluneColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Open Module Flow',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: color, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
      ],
    );
  }
}
