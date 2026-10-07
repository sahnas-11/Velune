import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/emergency_models.dart';
import '../state/emergency_state.dart';

class MechanicQueueScreen extends StatefulWidget {
  final EmergencyState state;
  final Function(EmergencyIncident) onInspectIncident;

  const MechanicQueueScreen({
    super.key,
    required this.state,
    required this.onInspectIncident,
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
          if (_selectedFilter == 'High Urgency') return i.priority == 'Critical Priority';
          if (_selectedFilter == 'Expressway') return i.locationText.contains('Expressway');
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Mechanic Job Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: VeluneColors.primaryNavy),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshed fleet incident queue. All dispatch feeds synchronized.')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.dangerBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.danger.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${allIncidents.length} Active', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.danger)),
                            const SizedBox(height: 2),
                            const Text('Open Fleet Incidents', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.successBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.success.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('6.2 mins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                            SizedBox(height: 2),
                            Text('Avg Response SLA', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'High Urgency', 'Expressway'].map((f) {
                      final isSel = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSel,
                          selectedColor: VeluneColors.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : VeluneColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSel ? VeluneColors.primaryNavy : VeluneColors.border),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Incidents List Header
                const Text('Reported Breakdowns (Live Feed)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                const SizedBox(height: 10),

                ...filtered.map((item) {
                  final isCritical = item.priority == 'Critical Priority';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isCritical ? VeluneColors.danger.withOpacity(0.4) : VeluneColors.border),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isCritical ? VeluneColors.dangerBg : VeluneColors.skyBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.priority,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCritical ? VeluneColors.danger : VeluneColors.accentBlue),
                              ),
                            ),
                            Text(item.reportedAt, style: const TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.reporterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item.vehiclePlate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: VeluneColors.primaryNavy)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${item.vehicleModel} • Issue: ${item.issueType}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: VeluneColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(item.locationText, style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: VeluneColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Status: ${item.status}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCritical ? VeluneColors.danger : VeluneColors.primaryNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => widget.onInspectIncident(item),
                              child: const Text('Inspect Request', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
