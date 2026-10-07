import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/map_widget.dart';
import '../state/emergency_state.dart';

class ActiveRideScreen extends StatelessWidget {
  final EmergencyState state;
  final VoidCallback onRequestEmergency;

  const ActiveRideScreen({
    super.key,
    required this.state,
    required this.onRequestEmergency,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final ride = state.activeRide;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Active Rides', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(8)),
                child: const Text('On Schedule', style: TextStyle(color: VeluneColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Arrival Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Arrival', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Arriving in ${ride.remainingMinutes} mins', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                          Text('Target arrival: ${ride.targetArrivalTime}', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(10)),
                        child: Text('${ride.speedKmh} km/h', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.accentBlue)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Map
                const VeluneMapCanvas(
                  pickupLabel: 'Matara Interchange',
                  dropoffLabel: 'Colombo WTC',
                  statusText: 'Southern Expressway E01 • Normal Flow',
                  progress: 0.55,
                  height: 190,
                ),
                const SizedBox(height: 14),

                // Driver Strip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${ride.passengersCount} Passengers Onboard • Toyota Prius', style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 18, color: VeluneColors.accentBlue),
                        onPressed: () {
                          state.toggleRouteSharing(!ride.isRouteShared);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ride.isRouteShared ? 'Live route sharing active' : 'Route sharing paused')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 18, color: VeluneColors.primaryNavy),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening carpool team chat...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // EMERGENCY ASSISTANCE PROMINENT 2-TAP CARD
                GestureDetector(
                  onTap: onRequestEmergency,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: VeluneColors.dangerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VeluneColors.danger, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: VeluneColors.danger.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: VeluneColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emergency, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Breakdown Assistance',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VeluneColors.danger),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tap to report vehicle failure, alert fleet dispatch & request mobile roadside unit (2-Tap Rule).',
                                style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: VeluneColors.danger),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Safety Assurance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: VeluneColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Expressway telemetry continuously monitors speed, route deviation, and impact status.',
                          style: TextStyle(fontSize: 10, color: VeluneColors.textSecondary),
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
