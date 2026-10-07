import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/emergency_state.dart';

class EmergencyBreakdownScreen extends StatefulWidget {
  final EmergencyState state;
  final VoidCallback onMechanicRequested;

  const EmergencyBreakdownScreen({
    super.key,
    required this.state,
    required this.onMechanicRequested,
  });

  @override
  State<EmergencyBreakdownScreen> createState() => _EmergencyBreakdownScreenState();
}

class _EmergencyBreakdownScreenState extends State<EmergencyBreakdownScreen> {
  String _selectedIssue = 'EV/Battery';
  final TextEditingController _notesCtrl = TextEditingController(text: 'Vehicle propulsion failure on expressway hard shoulder.');
  final String _autoKm = 'KM 74.2 Southbound (Near Welipenna)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Priority Emergency Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: VeluneColors.danger)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Red Priority Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VeluneColors.danger,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text('Vehicle Issue? Get Help Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Nearest Mobile Unit: Unit #04 is active on Southern Expressway, 8-12 mins away from your location.',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Auto-Detected Location Card
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Auto-Detected Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      Row(
                        children: [
                          Icon(Icons.gps_fixed, size: 12, color: VeluneColors.success),
                          SizedBox(width: 4),
                          Text('High Precision GPS Lock', style: TextStyle(fontSize: 10, color: VeluneColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_autoKm, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                  const Text('Southern Expressway Corridor (E01) • Welipenna hard shoulder', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Registered Vehicle Details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.directions_car, color: VeluneColors.primaryNavy, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toyota Prius Hybrid (WP CAB-8492)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Registered Carpool Fleet • Tier A Emergency Priority', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Issue Type Selection Chips
            const Text('Select Breakdown Symptom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Flat Tire', 'EV/Battery', 'Overheating', 'Mechanical Lock'].map((type) {
                final isSel = _selectedIssue == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSel,
                  selectedColor: VeluneColors.danger,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : VeluneColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSel ? VeluneColors.danger : VeluneColors.border),
                  onSelected: (val) {
                    if (val) setState(() => _selectedIssue = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Incident Description Note
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Incident Notes for Technician',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Automated Safety Protocol Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: VeluneColors.skyBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VeluneColors.accentBlue.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.group_outlined, color: VeluneColors.primaryNavy, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Automated Carpool Safety Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('3 registered ride partners and company fleet admin will receive automated dispatch status and safety reassurance.', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Request Mechanic Primary Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.state.createBreakdownIncident(_selectedIssue, _notesCtrl.text, _autoKm);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency breakdown alert broadcasted to Roadside Patrol #04!')),
                  );
                  widget.onMechanicRequested();
                },
                icon: const Icon(Icons.handyman, color: Colors.white),
                label: const Text('Request Roadside Mechanic (Now)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            // Hotline Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: VeluneColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing Toll-Free Expressway Emergency Hotline 1990...')),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16, color: VeluneColors.danger),
                    label: const Text('Hotline 1990', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.danger)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing Company Fleet Control 011-2004000...')),
                      );
                    },
                    icon: const Icon(Icons.support_agent, size: 16, color: VeluneColors.primaryNavy),
                    label: const Text('Fleet Control', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
