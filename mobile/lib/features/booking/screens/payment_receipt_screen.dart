import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/booking_state.dart';

class PaymentReceiptScreen extends StatefulWidget {
  final BookingState state;
  final VoidCallback onReturnToHub;

  const PaymentReceiptScreen({
    super.key,
    required this.state,
    required this.onReturnToHub,
  });

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  int _stars = 5;
  final List<String> _selectedTags = ['Punctual', 'Smooth Drive'];
  final List<String> _availableTags = ['Punctual', 'Smooth Drive', 'Clean Hybrid', 'Friendly Driver', 'Safe Following Distance'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final r = widget.state.receipt;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Payment Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: VeluneColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 48, color: VeluneColors.success),
                ),
                const SizedBox(height: 12),
                const Text('Auto-Debit Successful', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                const SizedBox(height: 4),
                Text('LKR ${r.amountLkr}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                Text('${r.date} • Card ending ${r.cardEnding}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                const SizedBox(height: 20),

                // Trip and Fare Itemised Summary Card
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
                      const Text('Trip and Fare Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Route Corridor', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('Matara → WTC Colombo (E01)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Driver & Vehicle', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('Kasun Silva (CAB-4288)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Enterprise Subsidy (75%)', style: TextStyle(fontSize: 12, color: VeluneColors.success)),
                          Text('-LKR 5,850', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                        ],
                      ),
                      const Divider(height: 18, color: VeluneColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Debited', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('LKR ${r.amountLkr}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Commute Environmental Impact Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.eco, color: VeluneColors.success, size: 20),
                          SizedBox(width: 8),
                          Text('Your Commute ESG Impact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('${r.fuelSavedL} L', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Fuel Saved', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('${r.co2AvoidedKg} kg', style: const TextStyle(color: VeluneColors.success, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('CO2 Avoided', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('+${r.carpoolPoints}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('ESG Points', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Rate Your Commute Card
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
                      const Text('Rate Your Commute Experience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _stars ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() => _stars = index + 1);
                              widget.state.updateRating(_stars, _selectedTags);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTags.map((tag) {
                          final isSel = _selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSel,
                            selectedColor: VeluneColors.skyBlue,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: isSel ? VeluneColors.primaryNavy : VeluneColors.textSecondary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                              widget.state.updateRating(_stars, _selectedTags);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Workday Expense Filing Export (CRUD)
                Container(
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
                          Icon(
                            r.isExportedWorkday ? Icons.check_circle : Icons.upload_file,
                            color: r.isExportedWorkday ? VeluneColors.success : VeluneColors.primaryNavy,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.isExportedWorkday ? 'Ready for Workday Filing' : 'Corporate Expense Export',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                r.isExportedWorkday ? 'Synced with corporate ERP' : 'One-tap Workday filing sync',
                                style: const TextStyle(fontSize: 10, color: VeluneColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: r.isExportedWorkday ? VeluneColors.successBg : VeluneColors.primaryNavy,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          widget.state.exportToWorkday();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receipt marked ready for Workday corporate expense report!')),
                          );
                        },
                        child: Text(
                          r.isExportedWorkday ? 'Exported ✓' : 'Export',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: r.isExportedWorkday ? VeluneColors.success : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Return to Commute Hub Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VeluneColors.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: widget.onReturnToHub,
                    child: const Text('Done: Return to Commute Hub', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
