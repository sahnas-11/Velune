import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../models/hr_models.dart';
import '../state/hr_state.dart';

class ParkingScreen extends StatelessWidget {
  final HrState state;
  final Function(int)? onNavigateTab;

  const ParkingScreen({super.key, required this.state, this.onNavigateTab});

  void _showAllocateDialog(BuildContext context) {
    final groupCtrl = TextEditingController(text: 'Group ${String.fromCharCode(65 + state.parkingGroups.length)}');
    final routeCtrl = TextEditingController(text: 'Nugegoda Route');
    final commutersCtrl = TextEditingController(text: '3');
    final spotCtrl = TextEditingController(text: 'B-${15 + state.parkingGroups.length}');
    String status = 'Reserved';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Allocate Priority Spot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: groupCtrl, decoration: const InputDecoration(labelText: 'Carpool Group Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: routeCtrl, decoration: const InputDecoration(labelText: 'Commute Route', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: commutersCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Riders in Pool', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: spotCtrl, decoration: const InputDecoration(labelText: 'Assigned Bay Code (e.g. B-15)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final riders = int.tryParse(commutersCtrl.text) ?? 3;
                  if (groupCtrl.text.isNotEmpty && spotCtrl.text.isNotEmpty) {
                    state.allocateSpot(groupCtrl.text, routeCtrl.text, riders, spotCtrl.text, status);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Allocated ${spotCtrl.text} to ${groupCtrl.text}')),
                    );
                  }
                },
                child: const Text('Confirm Spot Allocation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReassignDialog(BuildContext context, ParkingGroup group) {
    final spotCtrl = TextEditingController(text: group.spotCode);
    String status = group.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reassign ${group.groupName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: spotCtrl,
                decoration: const InputDecoration(labelText: 'New Bay Code', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Arrived', 'En-route', 'Reserved'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => status = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
              onPressed: () {
                state.reassignSpot(group.id, spotCtrl.text, status);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${group.groupName} reassigned to ${spotCtrl.text}')),
                );
              },
              child: const Text('Update Spot', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReleaseSpot(BuildContext context, ParkingGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Release Spot ${group.spotCode}?'),
        content: Text('Are you sure you want to release the priority spot for ${group.groupName} (${group.route})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.danger),
            onPressed: () {
              state.releaseSpot(group.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Released bay ${group.spotCode}')),
              );
            },
            child: const Text('Release Bay', style: TextStyle(color: Colors.white)),
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
        final total = state.totalPrioritySpots;
        final assigned = state.assignedPrioritySpots;
        final available = state.availablePrioritySpots;

        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'Parking Allocation',
            subtitle: 'Deck B Priority Charging Bays',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deck B Overview Card
                Container(
                  padding: const EdgeInsets.all(18),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: VeluneColors.skyBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.local_parking, color: VeluneColors.primaryNavy, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Corporate Deck B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VeluneColors.textPrimary)),
                                  Text('Zone B • 22kW Fast Chargers', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Zone B Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VeluneColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$assigned of $total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                                  const Text('Assigned Spots', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VeluneColors.successBg.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$available Open', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                                  const Text('Available Bays', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Assigned Groups Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Assigned Carpool Cohorts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAllocateDialog(context),
                      icon: const Icon(Icons.add_location_alt, size: 14, color: Colors.white),
                      label: const Text('Allocate Bay', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Assigned Groups List
                ...state.parkingGroups.map((group) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VeluneColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: VeluneColors.deepNavy,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    group.spotCode,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(group.groupName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary)),
                                    Text('${group.route} • ${group.commuters} commuters', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                            StatusBadge.fromStatus(group.status),
                          ],
                        ),
                        const Divider(height: 20, color: VeluneColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showReassignDialog(context, group),
                              icon: const Icon(Icons.edit, size: 14, color: VeluneColors.accentBlue),
                              label: const Text('Reassign', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmReleaseSpot(context, group),
                              icon: const Icon(Icons.delete_outline, size: 14, color: VeluneColors.danger),
                              label: const Text('Release', style: TextStyle(fontSize: 12, color: VeluneColors.danger)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // Incentive Banner Link
                GestureDetector(
                  onTap: () {
                    if (onNavigateTab != null) onNavigateTab!(5); // Go to incentives
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: VeluneColors.navyGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                            SizedBox(width: 10),
                            Text('View Corporate Incentive Programs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
