import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/emergency_state.dart';

class DispatchStatusScreen extends StatefulWidget {
  final EmergencyState state;
  final VoidCallback onResolved;

  const DispatchStatusScreen({
    super.key,
    required this.state,
    required this.onResolved,
  });

  @override
  State<DispatchStatusScreen> createState() => _DispatchStatusScreenState();
}

class _DispatchStatusScreenState extends State<DispatchStatusScreen> {
  final TextEditingController _codeCtrl = TextEditingController(text: 'DTC-P0A80 (Hybrid Inverter Voltage)');
  final TextEditingController _noteCtrl = TextEditingController(text: 'Battery safety relay reset completed. Hybrid cooling fans operational.');

  void _advanceStatus() {
    final cur = widget.state.currentIncident.status;
    String next = 'Arrived';
    if (cur == 'Accepted') next = 'En Route';
    if (cur == 'En Route') next = 'Arrived';
    if (cur == 'Arrived') next = 'Resolved';

    widget.state.updateIncidentStatus(widget.state.currentIncident.id, next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to: $next')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final inc = widget.state.currentIncident;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text('Incident #${inc.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(8)),
                child: Text(inc.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4-Step Progress Card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Technician Service Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            inc.status == 'Resolved' ? 'Step 4 of 4' : (inc.status == 'Arrived' ? 'Step 3 of 4' : 'Step 2 of 4'),
                            style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      if (inc.status != 'Resolved')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _advanceStatus,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: VeluneColors.accentBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Advance Status: ${inc.status == 'Accepted' ? 'En Route' : (inc.status == 'En Route' ? 'Arrived at Vehicle' : 'Complete')}'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Map
                const VeluneMapCanvas(
                  pickupLabel: 'Depot (Welipenna)',
                  dropoffLabel: 'Incident KM 74.2',
                  statusText: 'Patrol GPS Route Lock • Live Telemetry',
                  progress: 0.85,
                  height: 180,
                ),
                const SizedBox(height: 14),

                // Driver Strip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: VeluneColors.skyBlue,
                        child: const Text('KP', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inc.reporterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${inc.vehicleModel} • ${inc.vehiclePlate}', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: VeluneColors.primaryNavy, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling driver ${inc.reporterName}...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Incident Diagnostics Card (CRUD)
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
                      const Text('Incident Diagnostics & OBD Telemetry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(labelText: 'Diagnostic Code (OBD/DTC)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Resolution Summary Notes', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            widget.state.updateDiagnosticCode(_codeCtrl.text, _noteCtrl.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved diagnostic codes & technician notes!')),
                            );
                          },
                          child: const Text('Save Diagnostic Notes', style: TextStyle(color: VeluneColors.accentBlue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Mark as Resolved Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      widget.state.updateIncidentStatus(inc.id, 'Resolved');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incident marked Resolved! All passengers & fleet admin notified.')),
                      );
                      widget.onResolved();
                    },
                    child: const Text('Mark as Resolved (Clear Incident)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
