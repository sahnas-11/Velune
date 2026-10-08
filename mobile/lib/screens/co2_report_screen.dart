import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/hr_state.dart';
import 'pdf_report_viewer_screen.dart';

class Co2ReportScreen extends StatelessWidget {
  final HrState state;

  const Co2ReportScreen({super.key, required this.state});

  void _showLogCo2Dialog(BuildContext context) {
    final labelCtrl = TextEditingController(text: 'Week ${state.co2Records.length + 1}');
    final kgCtrl = TextEditingController(text: '82');
    final dateCtrl = TextEditingController(text: 'Oct 1 - Oct 7');
    String selectedMode = 'Carpool & Vanpool';

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
                const Text('Log New CO2 Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: 'Period Label', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kgCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CO2 Saved (kg)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: 'Date Range', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final kg = int.tryParse(kgCtrl.text) ?? 0;
                  if (kg > 0 && labelCtrl.text.isNotEmpty) {
                    state.addCo2Entry(labelCtrl.text, kg, dateCtrl.text, selectedMode);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged ${labelCtrl.text}: $kg kg saved!')),
                    );
                  }
                },
                child: const Text('Add CO2 Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTargetDialog(BuildContext context) {
    final ctrl = TextEditingController(text: state.settings.monthlyCo2TargetKg.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Monthly CO2 Target'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Target (kg)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0) {
                state.updateMonthlyCo2Target(val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Monthly CO2 Target updated to $val kg')),
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
      listenable: state,
      builder: (context, _) {
        final totalKg = state.totalCo2Saved;
        final targetKg = state.settings.monthlyCo2TargetKg;
        final percentReached = ((totalKg / targetKg) * 100).toInt();

        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'CO2 Reduction Report',
            subtitle: 'Campus Emissions Avoidance',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Progress Card
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
                              Text('$totalKg kg', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                              const Text('Total CO2 Avoided (Month)', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: VeluneColors.successBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('+18% vs Aug', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Goal: $targetKg kg ($percentReached% reached)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
                          GestureDetector(
                            onTap: () => _showEditTargetDialog(context),
                            child: const Row(
                              children: [
                                Text('Edit Goal', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue, fontWeight: FontWeight.bold)),
                                SizedBox(width: 2),
                                Icon(Icons.edit, size: 12, color: VeluneColors.accentBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (totalKg / targetKg).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE4E7EC),
                          valueColor: const AlwaysStoppedAnimation<Color>(VeluneColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Environmental Equivalent Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.successBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.success.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.park, color: VeluneColors.success, size: 22),
                            SizedBox(height: 8),
                            Text('14 Trees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            Text('Planted Equivalent', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.accentBlue.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.electric_bolt, color: VeluneColors.accentBlue, size: 22),
                            SizedBox(height: 8),
                            Text('1,240 mi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            Text('EV Miles Offset', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Download & Open Official ESG Report (PDF) Banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: VeluneColors.primaryNavy.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final report = state.monthlyReports.isNotEmpty ? state.monthlyReports.first : state.monthlyReports[0];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfReportViewerScreen(report: report, state: state),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Download Official ESG Report (PDF)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tap to generate & open verified Scope 3 audit report',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Weekly Breakdown Header + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weekly Reduction Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showLogCo2Dialog(context),
                      icon: const Icon(Icons.add, size: 14, color: Colors.white),
                      label: const Text('Log Entry', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Weekly Entries List
                ...state.co2Records.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VeluneColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: VeluneColors.skyBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_today, size: 18, color: VeluneColors.primaryNavy),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.weekLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                                Text('${entry.dateRange} • ${entry.primaryMode}', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: VeluneColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('+${entry.kgSaved} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.success)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // Primary Driver Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VeluneColors.deepNavy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.insights, color: Colors.amber, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Shuttle & Carpool pooling represents the primary carbon reduction driver (64% of total avoided emissions).',
                          style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
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
