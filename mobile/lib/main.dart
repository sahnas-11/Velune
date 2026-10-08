import 'package:flutter/material.dart';
import 'core/theme.dart';

// Module 1: Auth & Verification (Karunarathna IT23820050)
import 'features/auth/state/auth_state.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/corporate_verification_screen.dart';
import 'features/auth/screens/government_id_screen.dart';
import 'features/auth/screens/profile_screen.dart';

// Module 1: Ride Discovery (Karunarathna IT23820050)
import 'features/discovery/state/discovery_state.dart';
import 'features/discovery/screens/commuter_home_screen.dart';
import 'features/discovery/screens/find_ride_screen.dart';
import 'features/discovery/screens/available_rides_screen.dart';
import 'features/discovery/screens/ride_details_screen.dart';

// Module 2: Booking & Fare Settlement (Tissera IT23555808)
import 'features/booking/state/booking_state.dart';
import 'features/booking/screens/booking_confirmation_screen.dart';
import 'features/booking/screens/live_pickup_screen.dart';
import 'features/booking/screens/active_trip_screen.dart';
import 'features/booking/screens/fare_settlement_screen.dart';
import 'features/booking/screens/payment_receipt_screen.dart';

// Module 3: Emergency & Fleet Dispatch (Jayathilaka IT23829824)
import 'features/emergency/state/emergency_state.dart';
import 'features/emergency/models/emergency_models.dart';
import 'features/emergency/screens/active_ride_screen.dart';
import 'features/emergency/screens/emergency_breakdown_screen.dart';
import 'features/emergency/screens/help_requested_screen.dart';
import 'features/emergency/screens/mechanic_queue_screen.dart';
import 'features/emergency/screens/mechanic_request_details_screen.dart';
import 'features/emergency/screens/dispatch_status_screen.dart';

// Module 4: HR Corporate & System Integration (Amanda IT23555112)
import 'state/hr_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/co2_report_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/incentives_screen.dart';

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
  // Navigation Flow State
  bool _showSplash = true;
  bool _inOtpFlow = false;
  int _currentMainTab = 0; // 0=Home, 1=Discovery, 2=Booking, 3=Emergency, 4=HR

  // Sub-steps within Discovery (Module 1)
  int _discoveryStep = 0; // 0=Find Ride, 1=Available Rides, 2=Ride Details
  int _selectedDiscoveryRideId = 1;

  // Sub-steps within Booking (Module 2)
  int _bookingStep = 0;

  // Sub-steps within Emergency (Module 3)
  int _emergencyMode = 0; // 0=Commuter, 1=Mechanic
  int _emergencyCommuterStep = 0;
  int _emergencyMechanicStep = 0;
  EmergencyIncident? _selectedIncident;

  // Sub-steps within HR (Module 4)
  int _hrTab = 0;

  // Feature State instances
  final AuthState _authState = AuthState();
  final DiscoveryState _discoveryState = DiscoveryState();
  final BookingState _bookingState = BookingState();
  final EmergencyState _emergencyState = EmergencyState();
  final HrState _hrState = HrState();

  @override
  void initState() {
    super.initState();
    _authState.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    setState(() {});
  }

  // Role-based landing route
  void _applyRoleHomeRoute(String role) {
    setState(() {
      _inOtpFlow = false;
      if (role == 'hr_manager') {
        _currentMainTab = 4; // HR Corporate
        _hrTab = 0;
      } else if (role == 'mechanic') {
        _currentMainTab = 3; // Emergency Mechanic
        _emergencyMode = 1;
        _emergencyMechanicStep = 0;
      } else {
        _currentMainTab = 0; // Commuter Home
        _discoveryStep = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Splash Screen
    if (_showSplash) {
      return AnimatedSplashScreen(
        onAnimationComplete: () {
          setState(() => _showSplash = false);
        },
      );
    }

    // 2. Authentication Flow
    if (!_authState.isAuthenticated) {
      if (_inOtpFlow) {
        return CorporateVerificationScreen(
          state: _authState,
          onBackToLogin: () => setState(() => _inOtpFlow = false),
          onVerified: () {
            final role = _authState.currentUser?.role ?? 'commuter';
            _applyRoleHomeRoute(role);
          },
          onOpenGovernmentId: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GovernmentIdScreen(
                  state: _authState,
                  onCompleted: () => Navigator.pop(context),
                ),
              ),
            );
          },
        );
      }

      return LoginScreen(
        state: _authState,
        onContinueToOtp: () => setState(() => _inOtpFlow = true),
        onDirectRoleLogin: (role) {
          _authState.loginAsRole(role);
          _applyRoleHomeRoute(role);
        },
      );
    }

    // 3. Authenticated App Experience
    Widget activeContent;

    switch (_currentMainTab) {
      case 0:
        // 🏠 Commuter Home (Module 1, HF-03)
        activeContent = CommuterHomeScreen(
          state: _discoveryState,
          userName: _authState.currentUser?.name ?? 'Jay',
          onFindRidePressed: () {
            setState(() {
              _currentMainTab = 1;
              _discoveryStep = 1; // Direct jump to available rides!
            });
          },
          onRideSelected: (rideId) {
            setState(() {
              _currentMainTab = 1;
              _selectedDiscoveryRideId = rideId;
              _discoveryStep = 2; // Direct jump to ride details!
            });
          },
        );
        break;

      case 1:
        // 🔍 Commuter Ride Discovery (Module 1: Karunarathna)
        activeContent = _buildDiscoveryModuleView();
        break;

      case 2:
        // 🚗 Carpool Booking & Fare Settlement (Module 2: Tissera)
        activeContent = _buildBookingModuleView();
        break;

      case 3:
        // 🚨 Emergency Breakdown & Fleet Dispatch (Module 3: Jayathilaka)
        activeContent = _buildEmergencyModuleView();
        break;

      case 4:
      default:
        // 🏢 HR Corporate & System Integration (Module 4: Amanda)
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: VeluneColors.accentBlue),
            label: 'Rides',
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
  // Module 1 View: Ride Discovery (Karunarathna)
  // ==========================================
  Widget _buildDiscoveryModuleView() {
    final List<Widget> screens = [
      FindRideScreen(
        state: _discoveryState,
        onBack: () => setState(() => _currentMainTab = 0),
        onSearchSubmitted: () => setState(() => _discoveryStep = 1),
      ),
      AvailableRidesScreen(
        state: _discoveryState,
        onBack: () => setState(() => _discoveryStep = 0),
        onViewRide: (rideId) => setState(() {
          _selectedDiscoveryRideId = rideId;
          _discoveryStep = 2;
        }),
      ),
      RideDetailsScreen(
        state: _discoveryState,
        rideId: _selectedDiscoveryRideId,
        onBack: () => setState(() => _discoveryStep = 1),
        onContinueToBook: (rideId) {
          // Seamless handoff from Module 1 (Discovery) to Module 2 (Booking)!
          setState(() {
            _currentMainTab = 2;
            _bookingStep = 0; // Booking confirmation screen
          });
        },
      ),
    ];

    final labels = ['1. Find a Ride', '2. Available Rides', '3. Ride Details'];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(labels.length, (idx) {
              final isSelected = _discoveryStep == idx;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(labels[idx]),
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
                  onSelected: (_) => setState(() => _discoveryStep = idx),
                ),
              );
            }),
          ),
        ),
        Expanded(child: screens[_discoveryStep]),
      ],
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
          _currentMainTab = 3;
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
    final user = _authState.currentUser;
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
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Text(
                    user != null ? user.name.split(' ').map((e) => e[0]).take(2).join() : 'V',
                    style: const TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'Velune Corporate Platform',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  user != null ? '${user.role.toUpperCase()} • ${user.maskedEmail}' : 'SLIIT IT3060 • Milestone 03',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          // User Profile Quick Link
          ListTile(
            leading: const Icon(Icons.account_circle, color: VeluneColors.accentBlue),
            title: const Text('My Employee Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('View verified badges, NIC & switch role', style: TextStyle(fontSize: 10)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    authState: _authState,
                    onLogout: () {
                      Navigator.pop(context);
                      _authState.logout();
                      setState(() {});
                    },
                    onSwitchRole: (newRole) {
                      Navigator.pop(context);
                      _authState.loginAsRole(newRole);
                      _applyRoleHomeRoute(newRole);
                    },
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Platform Sections
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('EXPLORE MODULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1)),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: VeluneColors.primaryNavy),
            title: const Text('Home (HF-03)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Commuter Home & Upcoming Ride', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 0,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.search, color: VeluneColors.accentBlue),
            title: const Text('Module 1: Ride Discovery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23820050 (Karunarathna) • 6 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 1,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 1);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.directions_car, color: VeluneColors.accentBlue),
            title: const Text('Module 2: Carpool Booking & Fare', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555808 (Tissera) • 5 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 2,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 2);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.emergency, color: VeluneColors.danger),
            title: const Text('Module 3: Emergency & Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23829824 (Jayathilaka) • 6 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 3,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 3);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.business, color: VeluneColors.primaryNavy),
            title: const Text('Module 4: HR Corporate & ESG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('IT23555112 (Amanda) • 6 Screens', style: TextStyle(fontSize: 10)),
            selected: _currentMainTab == 4,
            selectedTileColor: VeluneColors.skyBlue,
            onTap: () {
              setState(() => _currentMainTab = 4);
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: VeluneColors.danger),
            title: const Text('Sign Out', style: TextStyle(color: VeluneColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              _authState.logout();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
