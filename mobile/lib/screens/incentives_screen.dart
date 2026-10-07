import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../models/hr_models.dart';
import '../state/hr_state.dart';

class IncentivesScreen extends StatelessWidget {
  final HrState state;

  const IncentivesScreen({super.key, required this.state});

  void _showAddIncentiveDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'After-Hours Transit Voucher');
    final descCtrl = TextEditingController(text: 'Guaranteed cab reimbursement for carpool drivers staying past 8 PM.');
    final budgetCtrl = TextEditingController(text: '30000');
    final disbursedCtrl = TextEditingController(text: '12000');

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
                const Text('New Incentive Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Program Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Terms / Description', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Budget (LKR)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: disbursedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Disbursed (LKR)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final budget = int.tryParse(budgetCtrl.text) ?? 20000;
                  final disbursed = int.tryParse(disbursedCtrl.text) ?? 0;
                  if (titleCtrl.text.isNotEmpty) {
                    state.addIncentive(titleCtrl.text, descCtrl.text, budget, disbursed);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created incentive program: ${titleCtrl.text}')),
                    );
                  }
                },
                child: const Text('Add Incentive Program', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIncentiveDialog(BuildContext context, IncentiveItem item) {
    final titleCtrl = TextEditingController(text: item.title);
    final descCtrl = TextEditingController(text: item.description);
    final budgetCtrl = TextEditingController(text: item.budgetLkr.toString());
    final disbursedCtrl = TextEditingController(text: item.disbursedLkr.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${item.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget (LKR)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: disbursedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Disbursed (LKR)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
            onPressed: () {
              final budget = int.tryParse(budgetCtrl.text) ?? item.budgetLkr;
              final disbursed = int.tryParse(disbursedCtrl.text) ?? item.disbursedLkr;
              state.updateIncentive(item.id, titleCtrl.text, descCtrl.text, budget, disbursed);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated ${titleCtrl.text}')),
              );
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
        return Scaffold(
          appBar: const VeluneAppBar(
            title: 'Corporate Incentives',
            subtitle: 'Carpool Subsidies & Benefits',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: VeluneColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Tier-1 Fleet Impact', style: TextStyle(color: VeluneColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const Text('Cycle Active', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('32 Carpool Groups Qualified', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Eligible for priority parking passes, energy subsidies, and corporate rewards.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2 Metric Highlight Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('18 Issued', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Priority Parking Passes', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VeluneColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('75% Disbursed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                            SizedBox(height: 2),
                            Text('LKR 45k of 60k Budget', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Active Programs Header + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Corporate Programs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeluneColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddIncentiveDialog(context),
                      icon: const Icon(Icons.add, size: 14, color: Colors.white),
                      label: const Text('Add Program', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Programs List
                ...state.incentives.map((item) {
                  final percent = (item.disbursedLkr / item.budgetLkr).clamp(0.0, 1.0);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VeluneColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isActive ? VeluneColors.successBg : const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(item.isActive ? 'Active' : 'Paused', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isActive ? VeluneColors.success : VeluneColors.textMuted)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(item.description, style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary, height: 1.3)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Disbursed: LKR ${item.disbursedLkr}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
                            Text('Budget: LKR ${item.budgetLkr}', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE4E7EC),
                            valueColor: AlwaysStoppedAnimation<Color>(item.isActive ? VeluneColors.accentBlue : VeluneColors.textMuted),
                          ),
                        ),
                        const Divider(height: 20, color: VeluneColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditIncentiveDialog(context, item),
                              icon: const Icon(Icons.edit, size: 14, color: VeluneColors.accentBlue),
                              label: const Text('Edit', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => state.toggleIncentive(item.id),
                              icon: Icon(item.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 14, color: VeluneColors.warning),
                              label: Text(item.isActive ? 'Pause' : 'Resume', style: const TextStyle(fontSize: 12, color: VeluneColors.warning)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                state.deleteIncentive(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed ${item.title}')));
                              },
                              icon: const Icon(Icons.delete_outline, size: 14, color: VeluneColors.danger),
                              label: const Text('Delete', style: TextStyle(fontSize: 12, color: VeluneColors.danger)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // Top Performing Squad Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VeluneColors.skyBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VeluneColors.accentBlue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.military_tech, color: VeluneColors.accentBlue, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Finance Commute Cohort 4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.textPrimary)),
                            Text('Top Pooling Squad: 420 kg CO2 avoided, 98% schedule compliance this cycle.', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
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
