import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/booking_state.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingState state;
  final VoidCallback onProceedToPickup;

  const BookingConfirmationScreen({
    super.key,
    required this.state,
    required this.onProceedToPickup,
  });

  void _showChangeSeatsDialog(BuildContext context) {
    int seats = state.currentBooking.seatsBooked;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Seat Allocation'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: seats > 1 ? () => setDialogState(() => seats--) : null,
              ),
              Text('$seats', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: seats < 3 ? () => setDialogState(() => seats++) : null,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.primaryNavy),
              onPressed: () {
                state.updateBookingSeats(seats);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated to $seats seats (Total Due: LKR ${seats * 800})')),
                );
              },
              child: const Text('Update Seats', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePaymentDialog(BuildContext context) {
    final methods = [
      'Commercial Bank Corporate Card ending 4082',
      'Sampath Bank Corporate Mastercard ending 1194',
      'Company Mobility Fleet Credit Account',
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Corporate Payment Method'),
        children: methods.map((m) {
          return SimpleDialogOption(
            onPressed: () {
              state.updatePaymentMethod(m);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment method set to: $m')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmCancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Carpool Booking?'),
        content: const Text('Your seat reservation on Kasun Silva\'s vehicle will be returned to the office pool.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.danger),
            onPressed: () {
              state.cancelBooking();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carpool reservation cancelled.')),
              );
            },
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
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
        final b = state.currentBooking;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Booking Confirmation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            leading: const Icon(Icons.arrow_back_ios_new, size: 18),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.directions_car, size: 14, color: VeluneColors.primaryNavy),
                    SizedBox(width: 4),
                    Text('Carpool', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
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
                // Map Overview
                const VeluneMapCanvas(
                  pickupLabel: 'Matara Clock Tower',
                  dropoffLabel: 'WTC Colombo',
                  statusText: 'Southern Expressway E01 • Normal Flow',
                  progress: 0.15,
                ),
                const SizedBox(height: 16),

                // Waypoints Timeline Card
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
                      const Text('Route Waypoints', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            children: [
                              Icon(Icons.radio_button_checked, size: 16, color: Colors.amber),
                              SizedBox(height: 2),
                              SizedBox(height: 24, child: VerticalDivider(color: VeluneColors.border, thickness: 2)),
                              Icon(Icons.location_on, size: 16, color: VeluneColors.danger),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(b.pickupName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(b.pickupTime, style: const TextStyle(color: VeluneColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(b.dropoffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(b.dropoffTime, style: const TextStyle(color: VeluneColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Verified Driver Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: VeluneColors.skyBlue,
                        child: const Text('KS', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(b.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('Verified Employee', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('${b.vehicleModel} • ${b.vehiclePlate}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${b.driverRating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Fare & Subsidy Split Card
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
                      const Text('Fare & Corporate Subsidy Split', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Base Highway Share (Distance Tier)', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                          Text('LKR ${b.baseCorporateShare}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Enterprise Commute Subsidy (75%)', style: TextStyle(fontSize: 12, color: VeluneColors.success, fontWeight: FontWeight.w500)),
                          Text('-LKR ${b.corporateSubsidyCredit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toll & Corporate Parking Offset', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue, fontWeight: FontWeight.w500)),
                          Text('-LKR ${b.highwayTollOffset}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                        ],
                      ),
                      const Divider(height: 20, color: VeluneColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Due (Your Share)', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                              Text('LKR ${b.totalDueLkr}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(8)),
                                child: Text('-${b.co2SavedKg} kg CO2', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _showChangeSeatsDialog(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('${b.seatsBooked} Seat(s)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Payment Method Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: VeluneColors.primaryNavy, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(b.paymentMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
                      ),
                      TextButton(
                        onPressed: () => _showChangePaymentDialog(context),
                        child: const Text('Change', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VeluneColors.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Carpool booking confirmed! Proceeding to live pickup tracking...')),
                      );
                      onProceedToPickup();
                    },
                    child: const Text('Confirm Carpool Booking (LKR 800)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmCancelBooking(context),
                    child: const Text('Cancel Reservation', style: TextStyle(color: VeluneColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
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
