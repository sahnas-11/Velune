import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/booking_state.dart';

class ActiveTripScreen extends StatelessWidget {
  final BookingState state;
  final VoidCallback onGoToSettlement;
  final VoidCallback onGoToEmergency;

  const ActiveTripScreen({
    super.key,
    required this.state,
    required this.onGoToSettlement,
    required this.onGoToEmergency,
  });

  void _showReportDelayDialog(BuildContext context) {
    final reasons = ['Heavy Toll Gate Queue', 'Weather Rain Delay', 'Expressway Maintenance', 'Tire Pressure Check'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Report Trip Delay'),
        children: reasons.map((r) {
          return SimpleDialogOption(
            onPressed: () {
              state.addDelayReport(r);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reported delay: $r. Office dispatch notified.')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final accrued = state.liveAccruedFareLkr;
        final cap = state.maxRouteCapLkr;
        final fareProgress = (accrued / cap).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Active Carpool Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.speed, size: 12, color: VeluneColors.success),
                    SizedBox(width: 4),
                    Text('78 km/h', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turn-by-Turn Maneuver Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VeluneColors.deepNavy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.turn_slight_right, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('In 1.2 km Welipenna Exit', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('Stay on Southern Expressway (E01) • 42 km left', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Map
                const VeluneMapCanvas(
                  pickupLabel: 'Matara (06:45 AM)',
                  dropoffLabel: 'WTC (08:30 AM)',
                  statusText: 'Active Navigation • Southern Expressway E01',
                  progress: 0.65,
                  height: 200,
                ),
                const SizedBox(height: 14),

                // Corporate Split Fare Live Accrual Card
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
                          const Text('Corporate Split Fare Accrual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Capped at LKR 800', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LKR $accrued', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                          Text('Max cap: LKR $cap', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: fareProgress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF2F4F7),
                          valueColor: const AlwaysStoppedAnimation<Color>(VeluneColors.accentBlue),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${state.tripCo2Avoided} kg CO2 Avoided', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                          const Text('3 Commuters Splitting Route', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Driver Strip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: VeluneColors.skyBlue,
                        child: const Text('KS', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kasun Silva (Driver)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Toyota Prius Hybrid • CAB-4288', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: VeluneColors.accentBlue, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening carpool in-app chat...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: VeluneColors.primaryNavy, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling Kasun Silva...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Delay Reports List (if any)
                if (state.delayReports.isNotEmpty) ...[
                  ...state.delayReports.map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: VeluneColors.warningBg, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Active Alert: $r', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.warning)),
                            GestureDetector(
                              onTap: () => state.removeDelayReport(r),
                              child: const Icon(Icons.close, size: 14, color: VeluneColors.warning),
                            ),
                          ],
                        ),
                      )),
                ],

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showReportDelayDialog(context),
                        icon: const Icon(Icons.warning_amber, size: 16, color: VeluneColors.warning),
                        label: const Text('Report Delay', style: TextStyle(fontSize: 12, color: VeluneColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VeluneColors.primaryNavy,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onGoToSettlement,
                        icon: const Icon(Icons.receipt_long, size: 16, color: Colors.white),
                        label: const Text('Trip Settlement', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Roadside Breakdown Shortcut
                GestureDetector(
                  onTap: onGoToEmergency,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VeluneColors.dangerBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VeluneColors.danger.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.car_crash, color: VeluneColors.danger, size: 22),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Roadside & Incident Dispatch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.danger)),
                                Text('Request emergency mechanic assistance (2-tap rule)', style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: VeluneColors.danger),
                      ],
                    ),
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
