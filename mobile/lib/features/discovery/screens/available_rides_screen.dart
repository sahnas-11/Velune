import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/discovery_state.dart';
import '../models/discovery_models.dart';

class AvailableRidesScreen extends StatefulWidget {
  final DiscoveryState state;
  final VoidCallback onBack;
  final Function(int rideId) onViewRide;

  const AvailableRidesScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onViewRide,
  });

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  String _sortBy = 'time'; // time, price, rating
  bool _verifiedOnly = false;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter & Sort Rides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Sort By', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Earliest Departure'),
                    selected: _sortBy == 'time',
                    onSelected: (val) {
                      setSheetState(() => _sortBy = 'time');
                      setState(() => _sortBy = 'time');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Lowest Price'),
                    selected: _sortBy == 'price',
                    onSelected: (val) {
                      setSheetState(() => _sortBy = 'price');
                      setState(() => _sortBy = 'price');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Highest Rating'),
                    selected: _sortBy == 'rating',
                    onSelected: (val) {
                      setSheetState(() => _sortBy = 'rating');
                      setState(() => _sortBy = 'rating');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Verified Employees Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _verifiedOnly,
                activeColor: VeluneColors.primaryNavy,
                onChanged: (val) {
                  setSheetState(() => _verifiedOnly = val);
                  setState(() => _verifiedOnly = val);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VeluneColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('APPLY FILTERS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DiscoveryRideItem> rides = List.from(widget.state.rides);

    if (_verifiedOnly) {
      rides = rides.where((r) => r.verifiedOnly).toList();
    }

    if (_sortBy == 'price') {
      rides.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'rating') {
      rides.sort((a, b) => b.driverRating.compareTo(a.driverRating));
    } else {
      rides.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeluneColors.textPrimary),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Rides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
            Text(
              '${widget.state.selectedFrom} -> ${widget.state.selectedTo} • 18 Sep',
              style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: VeluneColors.primaryNavy),
            tooltip: 'Filter rides',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return _buildRideCard(context, ride);
        },
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, DiscoveryRideItem ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VeluneColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver header
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: VeluneColors.skyBlue,
                    child: Text(
                      ride.driverName.split(' ').map((e) => e[0]).take(2).join(),
                      style: const TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, color: VeluneColors.success, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: VeluneColors.textPrimary)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: VeluneColors.successBg, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Verified Employee', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VeluneColors.success)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text('${ride.driverRating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(ride.vehicleModel, style: const TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              // Bookmark heart button (CRUD)
              IconButton(
                icon: Icon(
                  ride.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: ride.isBookmarked ? VeluneColors.accentBlue : VeluneColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  widget.state.toggleBookmark(ride.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ride.isBookmarked ? 'Ride bookmarked!' : 'Bookmark removed'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          const Divider(height: 22),

          // Time and Route Stops
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: VeluneColors.accentBlue, size: 10),
                  Container(width: 2, height: 26, color: VeluneColors.border),
                  const Icon(Icons.location_on, color: VeluneColors.danger, size: 12),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ride.pickupSpot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                        Text(ride.departureTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ride.dropoffSpot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary)),
                        Text(ride.arrivalTime, style: const TextStyle(fontSize: 11, color: VeluneColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tag, Seats left, Price & VIEW RIDE button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(6)),
                child: Text(ride.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
              ),
              Row(
                children: [
                  const Icon(Icons.event_seat_outlined, size: 14, color: VeluneColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${ride.seatsLeft} seats left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: VeluneColors.textSecondary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. ${ride.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
                  const Text('Per passenger', style: TextStyle(fontSize: 9, color: VeluneColors.textMuted)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Navy VIEW RIDE Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => widget.onViewRide(ride.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: VeluneColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('VIEW RIDE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
            ),
          ),
        ],
      ),
    );
  }
}
