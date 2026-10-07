import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'state/hr_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/co2_report_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/incentives_screen.dart';

// Booking Feature
import 'features/booking/state/booking_state.dart';
import 'features/booking/screens/booking_confirmation_screen.dart';
import 'features/booking/screens/live_pickup_screen.dart';
import 'features/booking/screens/active_trip_screen.dart';
import 'features/booking/screens/fare_settlement_screen.dart';
import 'features/booking/screens/payment_receipt_screen.dart';

// Emergency Feature
import 'features/emergency/state/emergency_state.dart';
import 'features/emergency/models/emergency_models.dart';
import 'features/emergency/screens/active_ride_screen.dart';
import 'features/emergency/screens/emergency_breakdown_screen.dart';
import 'features/emergency/screens/help_requested_screen.dart';
import 'features/emergency/screens/mechanic_queue_screen.dart';
import 'features/emergency/screens/mechanic_request_details_screen.dart';
import 'features/emergency/screens/dispatch_status_screen.dart';

void main() {
  runApp(const VeluneApp());
}

class VeluneApp extends StatelessWidget {
  const VeluneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velune Carpool Platform',
      debugShowCheckedModeBanner: false,
      theme: VeluneTheme.theme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // Active Module: 'hr', 'booking', 'emergency_commuter', 'emergency_mechanic'
  String _activeModule = 'hr';
  int _hrTab = 0;
  int _bookingStep = 0;
  int _emergencyCommuterStep = 0;
  int _emergencyMechanicStep = 0;
  EmergencyIncident? _selectedIncident;

  final HrState _hrState = HrState();
  final BookingState _bookingState = BookingState();
  final EmergencyState _emergencyState = EmergencyState();

  @override
  Widget build(BuildContext context) {
    Widget activeContent;

    if (_activeModule == 'hr') {
      final List<Widget> hrScreens = [
        DashboardScreen(state: _hrState, onNavigateTab: (idx) => setState(() => _hrTab = idx)),
        Co2ReportScreen(state: _hrState),
        ParkingScreen(state: _hrState, onNavigateTab: (idx) => setState(() => _hrTab = idx)),
        StatisticsScreen(state: _hrState),
        ReportsScreen(state: _hrState),
        IncentivesScreen(state: _hrState),
      ];
      activeContent = Scaffold(
        drawer: _buildDrawer(),
        body: hrScreens[_hrTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _hrTab > 4 ? 4 : _hrTab,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: VeluneColors.skyBlue,
          height: 65,
          onDestinationSelected: (idx) => setState(() => _hrTab = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: VeluneColors.primaryNavy), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco, color: VeluneColors.success), label: 'CO2'),
            NavigationDestination(icon: Icon(Icons.local_parking_outlined), selectedIcon: Icon(Icons.local_parking, color: VeluneColors.accentBlue), label: 'Parking'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: Colors.deepPurple), label: 'Stats'),
            NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description, color: VeluneColors.warning), label: 'Reports'),
          ],
        ),
      );
    } else if (_activeModule == 'booking') {
      // 5 Booking Screens
      final List<Widget> bookingScreens = [
        BookingConfirmationScreen(
          state: _bookingState,
          onProceedToPickup: () => setState(() => _bookingStep = 1),
        ),
        LivePickupScreen(
          state: _bookingState,
          onBoardedRide: () => setState(() => _bookingStep = 2),
        ),
        ActiveTripScreen(
          state: _bookingState,
          onGoToSettlement: () => setState(() => _bookingStep = 3),
          onGoToEmergency: () => setState(() {
            _activeModule = 'emergency_commuter';
            _emergencyCommuterStep = 1; // Direct jump to breakdown!
          }),
        ),
        FareSettlementScreen(
          state: _bookingState,
          onPaymentApproved: () => setState(() => _bookingStep = 4),
        ),
        PaymentReceiptScreen(
          state: _bookingState,
          onReturnToHub: () => setState(() => _bookingStep = 0),
        ),
      ];
      activeContent = Scaffold(
        drawer: _buildDrawer(),
        body: bookingScreens[_bookingStep],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _bookingStep,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: VeluneColors.skyBlue,
          height: 65,
          onDestinationSelected: (idx) => setState(() => _bookingStep = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle, color: VeluneColors.primaryNavy), label: 'Confirm'),
            NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer, color: VeluneColors.accentBlue), label: 'Pickup'),
            NavigationDestination(icon: Icon(Icons.navigation_outlined), selectedIcon: Icon(Icons.navigation, color: VeluneColors.success), label: 'Trip'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: VeluneColors.warning), label: 'Split'),
            NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified, color: Colors.purple), label: 'Receipt'),
          ],
        ),
      );
    } else if (_activeModule == 'emergency_commuter') {
      // 3 Commuter Emergency Screens
      final List<Widget> commuterScreens = [
        ActiveRideScreen(
          state: _emergencyState,
          onRequestEmergency: () => setState(() => _emergencyCommuterStep = 1),
        ),
        EmergencyBreakdownScreen(
          state: _emergencyState,
          onMechanicRequested: () => setState(() => _emergencyCommuterStep = 2),
        ),
        HelpRequestedScreen(
          state: _emergencyState,
          onIncidentClosed: () => setState(() => _emergencyCommuterStep = 0),
        ),
      ];
      activeContent = Scaffold(
        drawer: _buildDrawer(),
        body: commuterScreens[_emergencyCommuterStep],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _emergencyCommuterStep,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: VeluneColors.dangerBg,
          height: 65,
          onDestinationSelected: (idx) => setState(() => _emergencyCommuterStep = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car, color: VeluneColors.primaryNavy), label: 'Active Ride'),
            NavigationDestination(icon: Icon(Icons.warning_amber_rounded), selectedIcon: Icon(Icons.warning, color: VeluneColors.danger), label: 'Breakdown'),
            NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent, color: VeluneColors.success), label: 'Dispatched'),
          ],
        ),
      );
    } else {
      // 3 Mechanic Screens
      final inc = _selectedIncident ?? _emergencyState.queue.first;
      final List<Widget> mechanicScreens = [
        MechanicQueueScreen(
          state: _emergencyState,
          onInspectIncident: (item) {
            setState(() {
              _selectedIncident = item;
              _emergencyMechanicStep = 1;
            });
          },
        ),
        MechanicRequestDetailsScreen(
          state: _emergencyState,
          incident: inc,
          onAccepted: () => setState(() => _emergencyMechanicStep = 2),
        ),
        DispatchStatusScreen(
          state: _emergencyState,
          onResolved: () => setState(() => _emergencyMechanicStep = 0),
        ),
      ];
      activeContent = Scaffold(
        drawer: _buildDrawer(),
        body: mechanicScreens[_emergencyMechanicStep],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _emergencyMechanicStep,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: VeluneColors.skyBlue,
          height: 65,
          onDestinationSelected: (idx) => setState(() => _emergencyMechanicStep = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.format_list_bulleted), selectedIcon: Icon(Icons.format_list_bulleted, color: VeluneColors.primaryNavy), label: 'Job Queue'),
            NavigationDestination(icon: Icon(Icons.handyman_outlined), selectedIcon: Icon(Icons.handyman, color: VeluneColors.accentBlue), label: 'Request'),
            NavigationDestination(icon: Icon(Icons.speed), selectedIcon: Icon(Icons.speed, color: VeluneColors.success), label: 'Diagnostic'),
          ],
        ),
      );
    }

    return activeContent;
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: VeluneColors.navyGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    _activeModule == 'hr' ? 'AJ' : (_activeModule == 'emergency_mechanic' ? 'NS' : 'CU'),
                    style: const TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _activeModule == 'hr'
                      ? 'Amanda Jayawardena (HR)'
                      : (_activeModule == 'emergency_mechanic' ? 'Nalin Silva (Roadside Tech)' : 'Commuter Rider Hub'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  _activeModule == 'hr'
                      ? 'Head of HR & Corporate Facilities'
                      : (_activeModule == 'emergency_mechanic' ? 'Fleet Mobile Patrol Unit #04' : 'Verified Office Commuter'),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          // Module Switcher Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('SELECT PLATFORM MODULE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1)),
          ),

          // 1. Module 4: HR / Corporate
          ListTile(
            leading: const Icon(Icons.business, color: VeluneColors.primaryNavy),
            title: const Text('1. HR / Corporate Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555112 • 6 Dedicated Screens', style: TextStyle(fontSize: 10)),
            selected: _activeModule == 'hr',
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() {
                _activeModule = 'hr';
                _hrTab = 0;
              });
              Navigator.pop(context);
            },
          ),

          // 2. Module 2: Booking & Fare Settlement
          ListTile(
            leading: const Icon(Icons.directions_car, color: VeluneColors.accentBlue),
            title: const Text('2. Booking & Fare Splitting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555808 (Tissera) • 5 Screens', style: TextStyle(fontSize: 10)),
            selected: _activeModule == 'booking',
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() {
                _activeModule = 'booking';
                _bookingStep = 0;
              });
              Navigator.pop(context);
            },
          ),

          // 3. Module 3: Emergency - Commuter View
          ListTile(
            leading: const Icon(Icons.emergency, color: VeluneColors.danger),
            title: const Text('3. Emergency Breakdown (Commuter)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23829824 • Active Ride & Breakdown', style: TextStyle(fontSize: 10)),
            selected: _activeModule == 'emergency_commuter',
            selectedTileColor: VeluneColors.dangerBg,
            onTap: () {
              setState(() {
                _activeModule = 'emergency_commuter';
                _emergencyCommuterStep = 0;
              });
              Navigator.pop(context);
            },
          ),

          // 4. Module 3: Emergency - Mechanic View
          ListTile(
            leading: const Icon(Icons.handyman, color: Colors.orange),
            title: const Text('4. Mechanic Fleet Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23829824 • Queue & Diagnostics', style: TextStyle(fontSize: 10)),
            selected: _activeModule == 'emergency_mechanic',
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() {
                _activeModule = 'emergency_mechanic';
                _emergencyMechanicStep = 0;
              });
              Navigator.pop(context);
            },
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SLIIT IT3060 HCI - Milestone 03\nVelune Carpool Monorepo\nAll 3 teammate modules integrated.',
              style: TextStyle(fontSize: 11, color: VeluneColors.textMuted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
