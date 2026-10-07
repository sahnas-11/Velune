import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/home_hub_screen.dart';

// Module 4: HR Corporate
import 'state/hr_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/co2_report_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/incentives_screen.dart';

// Module 2: Booking Feature
import 'features/booking/state/booking_state.dart';
import 'features/booking/screens/booking_confirmation_screen.dart';
import 'features/booking/screens/live_pickup_screen.dart';
import 'features/booking/screens/active_trip_screen.dart';
import 'features/booking/screens/fare_settlement_screen.dart';
import 'features/booking/screens/payment_receipt_screen.dart';

// Module 3: Emergency Feature
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
  // Main Tab: 0 = Home Hub, 1 = Booking (Module 2), 2 = Emergency (Module 3), 3 = HR Corporate (Module 4)
  int _currentMainTab = 0;

  // Sub-steps within each module
  int _bookingStep = 0;
  int _emergencyMode = 0; // 0 = Commuter, 1 = Mechanic
  int _emergencyCommuterStep = 0;
  int _emergencyMechanicStep = 0;
  EmergencyIncident? _selectedIncident;
  int _hrTab = 0;

  // State instances
  final HrState _hrState = HrState();
  final BookingState _bookingState = BookingState();
  final EmergencyState _emergencyState = EmergencyState();

  void _navigateToModule(int mainTab, {int? subIndex}) {
    setState(() {
      _currentMainTab = mainTab;
      if (mainTab == 1 && subIndex != null) {
        _bookingStep = subIndex;
      } else if (mainTab == 2 && subIndex != null) {
        if (subIndex >= 3) {
          _emergencyMode = 1;
          _emergencyMechanicStep = subIndex - 3;
        } else {
          _emergencyMode = 0;
          _emergencyCommuterStep = subIndex;
        }
      } else if (mainTab == 3 && subIndex != null) {
        _hrTab = subIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeContent;

    switch (_currentMainTab) {
      case 0:
        // 🏠 Unified Home Hub
        activeContent = HomeHubScreen(
          onNavigateToModule: _navigateToModule,
        );
        break;

      case 1:
        // 🚗 Module 2: Carpool Booking & Fare Splitting (Tissera)
        activeContent = _buildBookingModuleView();
        break;

      case 2:
        // 🚨 Module 3: Emergency Breakdown & Fleet Dispatch (Jayathilaka)
        activeContent = _buildEmergencyModuleView();
        break;

      case 3:
      default:
        // 🏢 Module 4: HR Corporate & System Integration (Amanda)
        activeContent = _buildHrModuleView();
        break;
    }

    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(child: activeContent),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentMainTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VeluneColors.skyBlue,
        height: 68,
        onDestinationSelected: (idx) => setState(() => _currentMainTab = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: VeluneColors.primaryNavy),
            label: 'Home Hub',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car, color: VeluneColors.accentBlue),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency, color: VeluneColors.danger),
            label: 'Emergency',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business, color: VeluneColors.primaryNavy),
            label: 'HR Portal',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Module 2 View: Booking & Fare Settlement
  // ==========================================
  Widget _buildBookingModuleView() {
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
          _currentMainTab = 2;
          _emergencyMode = 0;
          _emergencyCommuterStep = 1; // Direct jump to breakdown!
        }),
      ),
      FareSettlementScreen(
        state: _bookingState,
        onPaymentApproved: () => setState(() => _bookingStep = 4),
      ),
      PaymentReceiptScreen(
        state: _bookingState,
        onReturnToHub: () => setState(() => _currentMainTab = 0),
      ),
    ];

    final stepLabels = ['1. Confirm', '2. Pickup (3m)', '3. Active Trip', '4. Fare Split', '5. Receipt'];

    return Column(
      children: [
        // Sub-navigation step selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(stepLabels.length, (idx) {
                final isSelected = _bookingStep == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(stepLabels[idx]),
                    selected: isSelected,
                    selectedColor: VeluneColors.skyBlue,
                    backgroundColor: VeluneColors.background,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? VeluneColors.accentBlue : VeluneColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? VeluneColors.accentBlue : VeluneColors.border),
                    ),
                    onSelected: (_) => setState(() => _bookingStep = idx),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(child: bookingScreens[_bookingStep]),
      ],
    );
  }

  // ==========================================
  // Module 3 View: Emergency & Fleet Dispatch
  // ==========================================
  Widget _buildEmergencyModuleView() {
    final inc = _selectedIncident ?? _emergencyState.queue.first;

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

    final commuterLabels = ['1. Active Ride', '2. Breakdown Alert', '3. Dispatched'];
    final mechanicLabels = ['1. Job Queue', '2. Triage Details', '3. Diagnostics & Resolve'];

    return Column(
      children: [
        // Mode switch: Commuter vs Mechanic
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Commuter Flow', style: TextStyle(fontSize: 11)),
                      icon: Icon(Icons.person_pin_circle_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Mechanic Fleet', style: TextStyle(fontSize: 11)),
                      icon: Icon(Icons.build_outlined, size: 16),
                    ),
                  ],
                  selected: {_emergencyMode},
                  onSelectionChanged: (val) => setState(() => _emergencyMode = val.first),
                ),
              ),
            ],
          ),
        ),

        // Sub-step chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (idx) {
              final isCommuter = _emergencyMode == 0;
              final isSelected = isCommuter ? _emergencyCommuterStep == idx : _emergencyMechanicStep == idx;
              final label = isCommuter ? commuterLabels[idx] : mechanicLabels[idx];
              final activeColor = isCommuter ? VeluneColors.danger : VeluneColors.primaryNavy;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: isCommuter ? VeluneColors.dangerBg : VeluneColors.skyBlue,
                  backgroundColor: VeluneColors.background,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : VeluneColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? activeColor : VeluneColors.border),
                  ),
                  onSelected: (_) => setState(() {
                    if (isCommuter) {
                      _emergencyCommuterStep = idx;
                    } else {
                      _emergencyMechanicStep = idx;
                    }
                  }),
                ),
              );
            }),
          ),
        ),

        Expanded(
          child: _emergencyMode == 0 ? commuterScreens[_emergencyCommuterStep] : mechanicScreens[_emergencyMechanicStep],
        ),
      ],
    );
  }

  // ==========================================
  // Module 4 View: HR & Corporate Portal
  // ==========================================
  Widget _buildHrModuleView() {
    final List<Widget> hrScreens = [
      DashboardScreen(state: _hrState, onNavigateTab: (idx) => setState(() => _hrTab = idx)),
      Co2ReportScreen(state: _hrState),
      ParkingScreen(state: _hrState, onNavigateTab: (idx) => setState(() => _hrTab = idx)),
      StatisticsScreen(state: _hrState),
      ReportsScreen(state: _hrState),
      IncentivesScreen(state: _hrState),
    ];

    final hrLabels = ['Dashboard', 'CO2 Logs', 'Parking Deck B', 'Analytics', 'ESG Reports', 'Rewards'];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hrLabels.length, (idx) {
                final isSelected = _hrTab == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(hrLabels[idx]),
                    selected: isSelected,
                    selectedColor: VeluneColors.skyBlue,
                    backgroundColor: VeluneColors.background,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? VeluneColors.primaryNavy : VeluneColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? VeluneColors.primaryNavy : VeluneColors.border),
                    ),
                    onSelected: (_) => setState(() => _hrTab = idx),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(child: hrScreens[_hrTab]),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: VeluneColors.navyGradient),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    'V',
                    style: TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Velune Corporate Platform',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'SLIIT IT3060 • Milestone 03 • Group WE_162',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          // Platform Sections
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('NAVIGATION MENU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1)),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: VeluneColors.primaryNavy),
            title: const Text('Home Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Unified Portal & System Overview', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 0,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.directions_car, color: VeluneColors.accentBlue),
            title: const Text('Module 2: Carpool Booking & Fare', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555808 (Tissera) • 5 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 1,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 1);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.emergency, color: VeluneColors.danger),
            title: const Text('Module 3: Emergency & Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23829824 (Jayathilaka) • 6 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 2,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 2);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.business, color: VeluneColors.primaryNavy),
            title: const Text('Module 4: HR Corporate & ESG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555112 (Amanda) • 6 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 3,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 3);
              Navigator.pop(context);
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PROJECT REPOSITORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted)),
                const SizedBox(height: 4),
                const Text('github.com/sahnas-11/Velune', style: TextStyle(fontSize: 11, color: VeluneColors.accentBlue, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VeluneColors.successBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: VeluneColors.success.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: VeluneColors.success, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '17 Screens Active • SQLite / MySQL Synchronized',
                          style: TextStyle(fontSize: 10, color: VeluneColors.success, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
