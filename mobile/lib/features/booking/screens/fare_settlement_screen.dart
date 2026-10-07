import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/booking_state.dart';

class FareSettlementScreen extends StatefulWidget {
  final BookingState state;
  final VoidCallback onPaymentApproved;

  const FareSettlementScreen({
    super.key,
    required this.state,
    required this.onPaymentApproved,
  });

  @override
  State<FareSettlementScreen> createState() => _FareSettlementScreenState();
}

class _FareSettlementScreenState extends State<FareSettlementScreen> {
  bool _isPartialCalibration = false;
  String _selectedDropoff = 'Kottawa Interchange (Exit 2)';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final s = widget.state.settlement;
        final payable = _isPartialCalibration ? 580 : 800;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Trip Settlement and Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gross Route Fare Breakdown Card
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
                          const Text('Total Route Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                          Text('LKR ${s.totalRouteFareLkr}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Base Departure Rate (Distance Tier)', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('LKR ${s.baseDepartureRateLkr}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Expressway Toll & Fuel Surcharge', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('LKR ${s.expresswayTollLkr}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Operational & Clean Fleet Fee', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('LKR ${s.operationalFeeLkr}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const Divider(height: 20, color: VeluneColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: VeluneColors.success),
                              SizedBox(width: 4),
                              Text('Enterprise Commute Subsidy (75%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                            ],
                          ),
                          Text('-LKR ${s.subsidyAmountLkr}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Automated Rider Split
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
                      const Text('Automated Rider Split', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 12),
                      ...s.splits.map((split) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: split.isCurrentUser ? VeluneColors.accentBlue : VeluneColors.skyBlue,
                                    child: Text(
                                      split.riderName[0],
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: split.isCurrentUser ? Colors.white : VeluneColors.primaryNavy),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(split.riderName, style: TextStyle(fontSize: 12, fontWeight: split.isCurrentUser ? FontWeight.bold : FontWeight.w500)),
                                      Text('${split.distanceShareKm} km waypoint share', style: const TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                split.isCurrentUser && _isPartialCalibration ? 'LKR $payable' : 'LKR ${split.amountLkr}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: split.isCurrentUser ? VeluneColors.accentBlue : VeluneColors.textPrimary),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Partial Journey Calibration (FR-03)
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Partial Journey Calibration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                              Text('Adjust share if exiting prior to Colombo WTC', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                            ],
                          ),
                          Switch(
                            value: _isPartialCalibration,
                            activeColor: VeluneColors.accentBlue,
                            onChanged: (val) {
                              setState(() => _isPartialCalibration = val);
                              widget.state.togglePartialCalibration(val, _selectedDropoff);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(val ? 'Calibrated down to LKR 580 for intermediate drop-off' : 'Restored standard route share (LKR 800)')),
                              );
                            },
                          ),
                        ],
                      ),
                      if (_isPartialCalibration) ...[
                        const Divider(height: 16, color: VeluneColors.border),
                        DropdownButtonFormField<String>(
                          value: _selectedDropoff,
                          decoration: const InputDecoration(labelText: 'Calibrated Drop-off Point', border: OutlineInputBorder()),
                          items: [
                            'Kottawa Interchange (Exit 2)',
                            'Makumbura Multimodal Hub',
                            'Welipenna Service Interchange',
                          ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedDropoff = val);
                              widget.state.togglePartialCalibration(true, val);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Final Amount Due & Approve Payment Button
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: VeluneColors.navyGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Share to Pay', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              SizedBox(height: 2),
                              Text('Commercial Bank ending 4082', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Text('LKR $payable', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VeluneColors.success,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            widget.state.approvePayment();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment approved for LKR $payable! Generating receipt...')),
                            );
                            widget.onPaymentApproved();
                          },
                          child: Text('Approve Payment LKR $payable', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
