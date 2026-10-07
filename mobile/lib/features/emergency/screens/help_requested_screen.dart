import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/emergency_state.dart';

class HelpRequestedScreen extends StatelessWidget {
  final EmergencyState state;
  final VoidCallback onIncidentClosed;

  const HelpRequestedScreen({
    super.key,
    required this.state,
    required this.onIncidentClosed,
  });

  void _confirmCancelIncident(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Emergency Request?'),
        content: const Text('Are you sure your vehicle is safely operational? Roadside Unit #04 will stand down.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Active')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.danger),
            onPressed: () {
              state.cancelIncident();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency incident cancelled. Roadside unit notified.')),
              );
              onIncidentClosed();
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white)),
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Help Requested', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: VeluneColors.dangerBg, borderRadius: BorderRadius.circular(8)),
                child: const Text('Priority 1 Dispatch', style: TextStyle(color: VeluneColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dispatch Status Card with 4-Step Progress
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Incident #${inc.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: VeluneColors.textPrimary)),
                              Text('Assistance Dispatched at ${inc.reportedAt}', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: VeluneColors.warningBg, borderRadius: BorderRadius.circular(10)),
                            child: Text(inc.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.warning)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4-Step Progress Bar
                      Row(
                        children: [
                          _buildStep('Accepted', true),
                          _buildStepLine(true),
                          _buildStep('En Route', inc.status == 'En Route' || inc.status == 'Arrived' || inc.status == 'Resolved'),
                          _buildStepLine(inc.status == 'Arrived' || inc.status == 'Resolved'),
                          _buildStep('Arrived', inc.status == 'Arrived' || inc.status == 'Resolved'),
                          _buildStepLine(inc.status == 'Resolved'),
                          _buildStep('Resolved', inc.status == 'Resolved'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Map
                const VeluneMapCanvas(
                  pickupLabel: 'Your Location (KM 74.2)',
                  dropoffLabel: 'Unit #04 (En-route)',
                  statusText: 'Roadside Unit #04 en route • 4.2 km away',
                  progress: 0.72,
                  height: 180,
                ),
                const SizedBox(height: 14),

                // Assigned Mechanic Card
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
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: VeluneColors.skyBlue,
                            child: const Text('NS', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(inc.assignedMechanic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star, size: 13, color: Colors.amber),
                                    Text(' ${inc.mechanicRating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Text('Certified Roadside Fleet Tech • Mobile Van #04', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('ETA: ${inc.etaMinutes} mins (${inc.distanceKm} km away)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: VeluneColors.border),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: VeluneColors.primaryNavy),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling technician ${inc.assignedMechanic}...')),
                                );
                              },
                              icon: const Icon(Icons.phone, size: 16, color: VeluneColors.primaryNavy),
                              label: const Text('Call Tech', style: TextStyle(fontSize: 12, color: VeluneColors.primaryNavy)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: VeluneColors.accentBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Opening live technician chat message modal...')),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 16, color: VeluneColors.accentBlue),
                              label: const Text('Message', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Corporate Safeguard Activated Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VeluneColors.skyBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VeluneColors.accentBlue.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: VeluneColors.primaryNavy, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Corporate Safeguard Activated: All 3 onboard carpool passengers have received automatic SMS status with company transport assurance.',
                          style: TextStyle(fontSize: 11, color: VeluneColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Cancel Incident Button
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmCancelIncident(context),
                    icon: const Icon(Icons.cancel_outlined, color: VeluneColors.danger, size: 16),
                    label: const Text('Cancel Emergency Request', style: TextStyle(color: VeluneColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(String label, bool active) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? VeluneColors.success : const Color(0xFFD0D5DD),
            shape: BoxShape.circle,
          ),
          child: active ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? VeluneColors.textPrimary : VeluneColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: active ? VeluneColors.success : const Color(0xFFD0D5DD),
      ),
    );
  }
}
