import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../models/emergency_models.dart';
import '../state/emergency_state.dart';

class MechanicRequestDetailsScreen extends StatefulWidget {
  final EmergencyState state;
  final EmergencyIncident incident;
  final VoidCallback onAccepted;

  const MechanicRequestDetailsScreen({
    super.key,
    required this.state,
    required this.incident,
    required this.onAccepted,
  });

  @override
  State<MechanicRequestDetailsScreen> createState() => _MechanicRequestDetailsScreenState();
}

class _MechanicRequestDetailsScreenState extends State<MechanicRequestDetailsScreen> {
  final TextEditingController _noteCtrl = TextEditingController(text: 'Assigned Unit #04 high-voltage bypass kit.');

  @override
  Widget build(BuildContext context) {
    final inc = widget.incident;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Mechanic Incident Diagnostic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: VeluneColors.dangerBg, borderRadius: BorderRadius.circular(8)),
            child: Text(inc.priority, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.danger)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map
            const VeluneMapCanvas(
              pickupLabel: 'Unit #04 (Depot)',
              dropoffLabel: 'Incident KM 74.2',
              statusText: 'Southern Expressway E01 Corridor • Target SLA: 10 mins',
              progress: 0.40,
              height: 180,
            ),
            const SizedBox(height: 16),

            // Incident Info Card
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inc.reporterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Driver / Commuter • 3 Passengers Onboard', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: VeluneColors.accentBlue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling driver ${inc.reporterName}...')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: VeluneColors.border),
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 16, color: VeluneColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('${inc.vehicleModel} (${inc.vehiclePlate})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_outlined, size: 16, color: VeluneColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(inc.locationText, style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: VeluneColors.danger),
                      const SizedBox(width: 8),
                      Text('Reported: ${inc.issueType} • "${inc.description}"', style: const TextStyle(fontSize: 12, color: VeluneColors.danger, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Technician Dispatch Note (CRUD)
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
                  const Text('Technician Diagnostic Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter tool requirement or triage note...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accept & Dispatch Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.state.acceptIncident(inc.id);
                  widget.state.updateDiagnosticCode('DTC-P0A80', _noteCtrl.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accepted incident ${inc.id}! Unit #04 dispatched.')),
                  );
                  widget.onAccepted();
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Accept Request & Dispatch Unit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
