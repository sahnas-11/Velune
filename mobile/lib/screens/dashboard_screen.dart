import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/hr_state.dart';

class DashboardScreen extends StatefulWidget {
  final HrState state;
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = 'Current Month';

  void _showEditCampusTargetDialog() {
    final controller = TextEditingController(text: widget.state.settings.campusTargetPercent.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Campus Target %'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Campus Decarbonization Target (%)',
            hintText: 'e.g. 80',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0 && val <= 100) {
                widget.state.updateCampusTarget(val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Campus decarbonization target updated to $val%')),
                );
              }
            },
            child: const Text('Save Target', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final state = widget.state;
        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'Amanda Jayawardena',
            subtitle: 'Head of HR & Corporate Facilities',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Current Month', 'Quarter to Date', 'Year to Date'].map((period) {
                      final isSelected = selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(period),
                          selected: isSelected,
                          selectedColor: VeluneColors.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : VeluneColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? VeluneColors.primaryNavy : VeluneColors.border,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => selectedPeriod = period);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Hero Card: Fleet Decarbonization Target
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: VeluneColors.deepNavy.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fleet Decarbonization',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Campus Target Progress',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: VeluneColors.success.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: VeluneColors.success.withOpacity(0.5)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 12, color: VeluneColors.success),
                                SizedBox(width: 2),
                                Text(
                                  '+14.2% MoM',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: 0.78,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(VeluneColors.success),
                                ),
                              ),
                              const Text(
                                '78%',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Campus Goal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    GestureDetector(
                                      onTap: _showEditCampusTargetDialog,
                                      child: Row(
                                        children: [
                                          Text(
                                            '${state.settings.campusTargetPercent}% Target',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit, size: 13, color: Colors.white70),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: 0.78 / (state.settings.campusTargetPercent / 100.0),
                                    minHeight: 8,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(VeluneColors.accentBlue),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '325 kg saved of ${state.settings.monthlyCo2TargetKg} kg target',
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4 KPI Metric Cards Grid
                const Text(
                  'Key Mobility Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    const MetricCard(
                      label: 'Active Carpoolers',
                      value: '86',
                      badgeText: '+8% MoM',
                      icon: Icons.people_alt_outlined,
                      iconColor: VeluneColors.accentBlue,
                      badgeBg: VeluneColors.skyBlue,
                      badgeColor: VeluneColors.accentBlue,
                    ),
                    const MetricCard(
                      label: 'Single Cars Reduced',
                      value: '42',
                      badgeText: '+12% Trips',
                      icon: Icons.directions_car_outlined,
                      iconColor: VeluneColors.success,
                      badgeBg: VeluneColors.successBg,
                      badgeColor: VeluneColors.success,
                    ),
                    MetricCard(
                      label: 'CO2 Saved This Mo.',
                      value: '${state.totalCo2Saved} kg',
                      badgeText: 'On Track',
                      icon: Icons.eco_outlined,
                      iconColor: VeluneColors.success,
                      badgeBg: VeluneColors.successBg,
                      badgeColor: VeluneColors.success,
                    ),
                    MetricCard(
                      label: 'Priority Bays Open',
                      value: '${state.availablePrioritySpots}',
                      badgeText: 'Deck B',
                      icon: Icons.local_parking_outlined,
                      iconColor: VeluneColors.warning,
                      badgeBg: VeluneColors.warningBg,
                      badgeColor: VeluneColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Commute Split Summary Bar
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
                          const Text(
                            'Campus Modal Split',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                          ),
                          TextButton(
                            onPressed: () => widget.onNavigateTab(3), // Go to Statistics
                            child: const Text('View Charts →', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: state.commuteSplits.map((s) {
                            return Expanded(
                              flex: (s.percentage * 10).toInt(),
                              child: Container(
                                height: 16,
                                color: s.color,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: state.commuteSplits.map((s) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('${s.name} (${s.percentage.toInt()}%)', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Navigation Shortcuts
                const Text(
                  'Quick Management Modules',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: VeluneColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => widget.onNavigateTab(1), // CO2
                        icon: const Icon(Icons.eco, size: 16, color: VeluneColors.success),
                        label: const Text('CO2 Log', style: TextStyle(fontSize: 12, color: VeluneColors.textPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: VeluneColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => widget.onNavigateTab(2), // Parking
                        icon: const Icon(Icons.local_parking, size: 16, color: VeluneColors.accentBlue),
                        label: const Text('Parking', style: TextStyle(fontSize: 12, color: VeluneColors.textPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: VeluneColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => widget.onNavigateTab(4), // Reports
                        icon: const Icon(Icons.description_outlined, size: 16, color: VeluneColors.primaryNavy),
                        label: const Text('Reports', style: TextStyle(fontSize: 12, color: VeluneColors.textPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // NFR-04 Privacy notice
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: VeluneColors.textMuted),
                        SizedBox(width: 6),
                        Text(
                          'NFR-04: Strictly aggregated, anonymized commuter data',
                          style: TextStyle(fontSize: 10, color: VeluneColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
