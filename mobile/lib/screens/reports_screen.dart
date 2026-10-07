import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../models/hr_models.dart';
import '../state/hr_state.dart';

class ReportsScreen extends StatelessWidget {
  final HrState state;

  const ReportsScreen({super.key, required this.state});

  void _showGenerateReportDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'October 2026 Interim ESG Report');
    final co2Ctrl = TextEditingController(text: '355');
    final evCtrl = TextEditingController(text: '81.2');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate ESG Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Report Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: co2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Avoided CO2 (kg)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: evCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'EV Share (%)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
            onPressed: () {
              final co2 = int.tryParse(co2Ctrl.text) ?? 300;
              final ev = double.tryParse(evCtrl.text) ?? 75.0;
              state.addReport(titleCtrl.text, co2, ev);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generated ${titleCtrl.text}')),
              );
            },
            child: const Text('Generate PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    final emailCtrl = TextEditingController(text: state.recipientEmail);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Automated Report Recipient'),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Corporate Email', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
            onPressed: () {
              if (emailCtrl.text.isNotEmpty) {
                state.updateRecipientEmail(emailCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recipient email updated to ${emailCtrl.text}')),
                );
              }
            },
            child: const Text('Save Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _previewReportModal(BuildContext context, MonthlyReportItem report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(report.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: VeluneColors.background, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf, size: 48, color: VeluneColors.danger),
                  const SizedBox(height: 12),
                  Text('${report.title} (Official Audit)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Published: ${report.publishDate} • Size: ${report.fileSizeMb} MB', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('${report.co2SavedKg} kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                          const Text('CO2 Avoided', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('${report.evSharePercent}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                          const Text('EV Share', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(report.auditScope, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                          const Text('Compliance', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloaded ${report.title} to device storage.')),
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Download PDF File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final latest = state.monthlyReports.isNotEmpty ? state.monthlyReports.first : null;

        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'ESG Monthly Reports',
            subtitle: 'DomPDF Carbon & Fleet Audits',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Latest Report Hero Card
                if (latest != null) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: VeluneColors.navyGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Latest Published', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            Text('${latest.fileSizeMb} MB PDF', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(latest.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Published: ${latest.publishDate} • ${latest.auditScope}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _previewReportModal(context, latest),
                                icon: const Icon(Icons.visibility, color: Colors.white, size: 16),
                                label: const Text('Preview', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VeluneColors.accentBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloading ${latest.title}... Complete!')),
                                  );
                                },
                                icon: const Icon(Icons.download, color: Colors.white, size: 16),
                                label: const Text('Download', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Auto-Email Settings Card
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Automated Email Dispatch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                              Text('1st of every month at 08:00 AM', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ],
                          ),
                          Switch(
                            value: state.autoEmailReports,
                            activeColor: VeluneColors.accentBlue,
                            onChanged: (val) {
                              state.toggleAutoEmail(val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(val ? 'Auto-email delivery enabled' : 'Auto-email delivery paused')),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: VeluneColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 16, color: VeluneColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(state.recipientEmail, style: const TextStyle(fontSize: 12, color: VeluneColors.textPrimary, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _showEditEmailDialog(context),
                            child: const Text('Change', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Report Archives Header + Generate Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Archived Monthly Reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showGenerateReportDialog(context),
                      icon: const Icon(Icons.post_add, size: 14, color: Colors.white),
                      label: const Text('Generate New', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Archives List
                ...state.monthlyReports.map((report) {
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: VeluneColors.dangerBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.picture_as_pdf, color: VeluneColors.danger, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                                Text('${report.publishDate} • ${report.fileSizeMb} MB • ${report.co2SavedKg} kg CO2', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, size: 18, color: VeluneColors.accentBlue),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Downloading ${report.title}... Complete!')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: VeluneColors.danger),
                              onPressed: () {
                                state.deleteReport(report.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Deleted ${report.title}')),
                                );
                              },
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
