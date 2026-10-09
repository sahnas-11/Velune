import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/hr_models.dart';
import '../state/hr_state.dart';

class PdfReportViewerScreen extends StatefulWidget {
  final MonthlyReportItem report;
  final HrState state;

  const PdfReportViewerScreen({
    super.key,
    required this.report,
    required this.state,
  });

  @override
  State<PdfReportViewerScreen> createState() => _PdfReportViewerScreenState();
}

class _PdfReportViewerScreenState extends State<PdfReportViewerScreen> {
  bool _isSaving = false;
  String? _savedPath;

  @override
  void initState() {
    super.initState();
    _autoSaveFile();
  }

  void _autoSaveFile() async {
    final path = await widget.state.downloadReportPdf(widget.report);
    if (mounted) {
      setState(() {
        _savedPath = path;
      });
    }
  }

  void _handleManualSave() async {
    setState(() => _isSaving = true);
    final path = await widget.state.downloadReportPdf(widget.report);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _savedPath = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to: $path'),
          backgroundColor: VeluneColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4D52), // Classic PDF reader viewer background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.report.title.replaceAll(" ", "_")}.pdf',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Official ISO 14064-1 Verified Audit • Read-Only',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  tooltip: 'Save to Downloads',
                  onPressed: _handleManualSave,
                ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share Audit Document',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document ready for distribution to Corporate ESG Board.'),
                  backgroundColor: VeluneColors.primaryNavy,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF Reader Status Bar
          Container(
            color: const Color(0xFF1E2022),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                      child: const Text('PAGE 1 / 1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    const Text('100%', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Text(
                  _savedPath != null ? '✓ Downloaded (${widget.report.fileSizeMb} MB)' : 'Preparing PDF...',
                  style: const TextStyle(color: VeluneColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Scrollable PDF Document Canvas (A4 sheet appearance)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Header & Seals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: VeluneColors.primaryNavy,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('VELUNE PLATFORM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2, color: VeluneColors.primaryNavy), overflow: TextOverflow.ellipsis),
                                      Text('Corporate Sustainability Division', style: TextStyle(fontSize: 9, color: VeluneColors.textSecondary), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: VeluneColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: VeluneColors.success),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, size: 12, color: VeluneColors.success),
                                SizedBox(width: 4),
                                Text('ISO 14064-1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.black26, thickness: 1.5),
                      const SizedBox(height: 12),

                      // Document Title
                      Text(
                        widget.report.title.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: VeluneColors.primaryNavy, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monthly Carbon Offset & Commute Decarbonization Audit',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 16),

                      // Audit Metadata Table
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildMetaRow('Reporting Period:', widget.report.publishDate),
                            _buildMetaRow('Audit Compliance:', widget.report.auditScope),
                            _buildMetaRow('Organization:', 'Velune Technologies & Client HQ Campus'),
                            _buildMetaRow('Lead Auditor:', 'Amanda Jayawardena (Head of HR & ESG)'),
                            _buildMetaRow('Document Status:', 'Certified Official Scope 3 Record'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Key Performance Highlights
                      const Text('1. EXECUTIVE SUMMARY & KPIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: VeluneColors.primaryNavy)),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              label: 'TOTAL AVOIDED CO2',
                              value: '${widget.report.co2SavedKg} kg',
                              color: VeluneColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              label: 'EV / HYBRID SHARE',
                              value: '${widget.report.evSharePercent}%',
                              color: VeluneColors.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              label: 'CARPOOL COMMUTES',
                              value: '1,420',
                              color: VeluneColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Weekly Emissions Avoided Breakdown Table
                      const Text('2. CERTIFIED WEEKLY EMISSIONS REDUCTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: VeluneColors.primaryNavy)),
                      const SizedBox(height: 8),

                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2.0),
                          2: FlexColumnWidth(1.4),
                          3: FlexColumnWidth(1.0),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFE9ECEF)),
                            children: const [
                              Padding(padding: EdgeInsets.all(6), child: Text('Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                              Padding(padding: EdgeInsets.all(6), child: Text('Primary Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                              Padding(padding: EdgeInsets.all(6), child: Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                              Padding(padding: EdgeInsets.all(6), child: Text('CO2 Saved', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                            ],
                          ),
                          ...widget.state.co2Records.map((entry) {
                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(6), child: Text(entry.weekLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(6), child: Text(entry.primaryMode, style: const TextStyle(fontSize: 10))),
                                Padding(padding: const EdgeInsets.all(6), child: Text(entry.dateRange, style: const TextStyle(fontSize: 10))),
                                Padding(padding: const EdgeInsets.all(6), child: Text('+${entry.kgSaved} kg', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.success))),
                              ],
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 3. Deck B Priority Parking Analysis
                      const Text('3. PRIORITY PARKING DECK B UTILIZATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: VeluneColors.primaryNavy)),
                      const SizedBox(height: 6),
                      Text(
                        'Total dedicated carpool bays: ${widget.state.totalPrioritySpots} spots. '
                        'Current allocated groups: ${widget.state.assignedPrioritySpots}. '
                        'Average group vehicle occupancy: 3.6 commuters per bay. '
                        'Zero solo-driving parking infractions registered during audit cycle.',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade800, height: 1.4),
                      ),

                      const SizedBox(height: 24),

                      // 4. Formal Sign-Off Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: VeluneColors.success.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified_user, color: VeluneColors.success, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AUDIT CERTIFICATION STATEMENT',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: VeluneColors.success),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'This document certifies that the Scope 3 emissions reductions reported herein comply with ISO 14064-1 Greenhouse Gas Protocol. Calculations are audited and immutably stamped.',
                                    style: TextStyle(fontSize: 9, color: Colors.grey.shade800, height: 1.3),
                                  ),
                                  const SizedBox(height: 8),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text('Signed: Amanda Jayawardena', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontStyle: FontStyle.italic)),
                                      ),
                                      SizedBox(width: 8),
                                      Text('REF: ISO-GHG-2026-LK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: VeluneColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer with saved path
                      if (_savedPath != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: VeluneColors.success, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'File stored on device: $_savedPath',
                                  style: const TextStyle(fontSize: 9, color: VeluneColors.textSecondary, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8, color: VeluneColors.textMuted, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
