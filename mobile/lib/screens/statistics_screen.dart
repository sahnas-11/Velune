import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/hr_state.dart';

class StatisticsScreen extends StatelessWidget {
  final HrState state;

  const StatisticsScreen({super.key, required this.state});

  void _showPinRouteDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Panadura Express');
    final ridersCtrl = TextEditingController(text: '38');
    final tagCtrl = TextEditingController(text: 'New Corridor');

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
                const Text('Pin Commuter Route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Route Corridor Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: ridersCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Active Daily Riders', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Classification Badge', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final riders = int.tryParse(ridersCtrl.text) ?? 30;
                  if (nameCtrl.text.isNotEmpty) {
                    state.pinRoute(nameCtrl.text, riders, tagCtrl.text);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pinned route ${nameCtrl.text}')),
                    );
                  }
                },
                child: const Text('Pin to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'Carpool Statistics',
            subtitle: 'Commute Analytics & Trends',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Split Donut Card
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
                      const Text(
                        'Commute Modal Share',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CustomPaint(
                                  painter: DonutChartPainter(state.commuteSplits),
                                ),
                              ),
                              const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('420', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                                  Text('Commuters', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: state.commuteSplits.map((split) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(width: 10, height: 10, decoration: BoxDecoration(color: split.color, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(split.name, style: const TextStyle(fontSize: 12, color: VeluneColors.textPrimary, fontWeight: FontWeight.w500)),
                                      ),
                                      Text('${split.percentage.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Adoption Trend Line Chart Card
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Carpool Adoption Growth', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                              Text('Apr - Sep 2026', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(8)),
                            child: const Text('+24% Growth', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: LineChartPainter(
                            values: const [0.2, 0.35, 0.45, 0.6, 0.72, 0.95],
                            lineColor: VeluneColors.accentBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Apr', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                          Text('May', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                          Text('Jun', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                          Text('Jul', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                          Text('Aug', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                          Text('Sep', style: TextStyle(fontSize: 10, color: VeluneColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2 Analytics Highlights
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.accentBlue.withOpacity(0.2)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3.2 Commuters', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Avg Pool Group Size', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VeluneColors.successBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.success.withOpacity(0.2)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wednesday', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Peak Day (88% Active)', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Top Performing Routes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Top Performing Routes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showPinRouteDialog(context),
                      icon: const Icon(Icons.push_pin, size: 14, color: Colors.white),
                      label: const Text('Pin Route', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Routes List
                ...state.topRoutes.map((route) {
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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.route, color: VeluneColors.primaryNavy, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                                Text('${route.riders} daily commuters', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: route.tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                              child: Text(route.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: route.tagColor)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: VeluneColors.textMuted),
                              onPressed: () {
                                state.unpinRoute(route.id);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unpinned ${route.name}')));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // Carbon Impact Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '1,420 kg CO2 avoided by employee carpools this quarter across all campus routes.',
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
