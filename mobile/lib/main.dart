import 'package:flutter/material.dart';
import 'core/theme.dart';

// Module 1: Auth & Verification (Karunarathna IT23820050)
import 'features/auth/state/auth_state.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/auth_screen.dart';
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
  // Global Flow State
  bool _showSplash = true;
  bool _inOtpFlow = false;

  // Commuter Shell Navigation State
  int _commuterTab = 0; // 0=Home, 1=Find Rides, 2=My Trips, 3=SOS, 4=Profile
  int _commuterSearchStep = 0; // 0=Search Form, 1=Available Rides, 2=Ride Details
  int _selectedDiscoveryRideId = 1;
  int _bookingStep = 0; // 0=Confirm, 1=Pickup, 2=Active Trip, 3=Fare Split, 4=Receipt
  int _commuterEmergencyStep = 0; // 0=Active Ride, 1=Breakdown Form, 2=Dispatched

  // Mechanic Shell Navigation State
  int _mechanicTab = 0; // 0=Queue, 1=Triage/Diag, 2=Status, 3=Profile
  EmergencyIncident? _selectedIncident;

  // HR Shell Navigation State
  int _hrTab = 0; // 0=Dashboard, 1=Parking, 2=CO2, 3=Incentives, 4=Reports

  // Shared Reactive States
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

  void _onAuthenticated(String role) {
    setState(() {
      _inOtpFlow = false;
      if (role == 'hr_manager') {
        _hrTab = 0;
      } else if (role == 'mechanic') {
        _mechanicTab = 0;
        _selectedIncident = null;
      } else {
        _commuterTab = 0;
        _commuterSearchStep = 0;
        _bookingStep = 0;
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

    // 2. Unauthenticated: Auth Flow (Sign In, Registration, OTP)
    if (!_authState.isAuthenticated) {
      if (_inOtpFlow) {
        return CorporateVerificationScreen(
          state: _authState,
          onBackToLogin: () => setState(() => _inOtpFlow = false),
          onVerified: () {
            final role = _authState.currentUser?.role ?? 'commuter';
            _onAuthenticated(role);
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

      return AuthScreen(
        state: _authState,
        onContinueToOtp: () => setState(() => _inOtpFlow = true),
        onAuthenticated: (role) => _onAuthenticated(role),
      );
    }

    // 3. Authenticated: STRICT ROLE-SPECIFIC APP SHELLS
    final currentUser = _authState.currentUser!;
    final role = currentUser.role;

    if (role == 'hr_manager') {
      return _buildHrAppShell();
    } else if (role == 'mechanic') {
      return _buildMechanicAppShell();
    } else {
      return _buildCommuterAppShell();
    }
  }

  // =========================================================================
  // 🏢 1. HR CORPORATE SUSTAINABILITY SHELL (Only HR screens & features)
  // =========================================================================
  Widget _buildHrAppShell() {
    final List<Widget> hrScreens = [
      // Tab 0: HR Corporate Dashboard
      DashboardScreen(
        state: _hrState,
        onNavigateTab: (tabIndex) => setState(() => _hrTab = tabIndex),
      ),
      // Tab 1: Parking Deck B (CRUD Bay Allocations)
      ParkingScreen(
        state: _hrState,
        onNavigateTab: (tabIndex) => setState(() => _hrTab = tabIndex),
      ),
      // Tab 2: CO2 & ESG Records (Download PDF)
      Co2ReportScreen(
        state: _hrState,
      ),
      // Tab 3: Corporate Incentive Programs (CRUD Incentives)
      IncentivesScreen(
        state: _hrState,
      ),
      // Tab 4: Scope 3 ESG Audit Reports (Generate & Download)
      ReportsScreen(
        state: _hrState,
      ),
    ];

    return Scaffold(
      drawer: _buildHrDrawer(),
      body: SafeArea(child: hrScreens[_hrTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _hrTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VeluneColors.skyBlue,
        height: 68,
        onDestinationSelected: (idx) => setState(() => _hrTab = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: VeluneColors.primaryNavy),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking, color: VeluneColors.accentBlue),
            label: 'Parking',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: VeluneColors.success),
            label: 'CO2 & ESG',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard, color: VeluneColors.accentBlue),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description, color: VeluneColors.primaryNavy),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildHrDrawer() {
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
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    user != null ? user.name.split(' ').map((e) => e[0]).take(2).join() : 'HR',
                    style: const TextStyle(color: VeluneColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Amanda Jayawardena',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${user?.hrBadgeId ?? "HR-CORP-992"} • ${user?.officeBranch ?? "Colombo HQ"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: VeluneColors.primaryNavy),
            title: const Text('Executive Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _hrTab == 0,
            onTap: () {
              setState(() => _hrTab = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_parking, color: VeluneColors.accentBlue),
            title: const Text('Priority Deck B Parking', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _hrTab == 1,
            onTap: () {
              setState(() => _hrTab = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco, color: VeluneColors.success),
            title: const Text('Carbon Reduction Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _hrTab == 2,
            onTap: () {
              setState(() => _hrTab = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: VeluneColors.accentBlue),
            title: const Text('Corporate Incentives', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _hrTab == 3,
            onTap: () {
              setState(() => _hrTab = 3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: VeluneColors.primaryNavy),
            title: const Text('ESG Monthly Reports (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _hrTab == 4,
            onTap: () {
              setState(() => _hrTab = 4);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: VeluneColors.danger),
            title: const Text('Sign Out', style: TextStyle(color: VeluneColors.danger, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _authState.logout();
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🔧 2. ROADSIDE MECHANIC FLEET SHELL (Only Mechanic screens & features)
  // =========================================================================
  Widget _buildMechanicAppShell() {
    final incident = _selectedIncident ?? _emergencyState.queue.first;

    Widget activeContent;
    switch (_mechanicTab) {
      case 0:
        // Job Queue
        activeContent = MechanicQueueScreen(
          state: _emergencyState,
          onInspectIncident: (item) {
            setState(() {
              _selectedIncident = item;
              _mechanicTab = 1; // Transition to detailed triage & diagnostics
            });
          },
        );
        break;

      case 1:
        // Detailed Triage, Diagnostics & Notes (CRUD)
        activeContent = MechanicRequestDetailsScreen(
          state: _emergencyState,
          incident: incident,
          onAccepted: () {
            setState(() {
              _mechanicTab = 2; // Transition to active dispatch tracker
            });
          },
        );
        break;

      case 2:
        // Active Dispatch Tracking & Status Resolution
        activeContent = DispatchStatusScreen(
          state: _emergencyState,
          onResolved: () {
            setState(() {
              _mechanicTab = 0; // Return to queue upon resolution
              _selectedIncident = null;
            });
          },
        );
        break;

      case 3:
      default:
        // Mechanic Profile & Sign Out
        activeContent = _buildMechanicProfileView();
        break;
    }

    return Scaffold(
      body: SafeArea(child: activeContent),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mechanicTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VeluneColors.warningBg,
        height: 68,
        onDestinationSelected: (idx) => setState(() => _mechanicTab = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted_outlined),
            selectedIcon: Icon(Icons.format_list_bulleted, color: VeluneColors.warning),
            label: 'Job Queue',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            selectedIcon: Icon(Icons.build, color: VeluneColors.warning),
            label: 'Diagnostics',
          ),
          NavigationDestination(
            icon: Icon(Icons.fmd_good_outlined),
            selectedIcon: Icon(Icons.fmd_good, color: VeluneColors.primaryNavy),
            label: 'Dispatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle, color: VeluneColors.primaryNavy),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicProfileView() {
    final user = _authState.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: VeluneColors.warningBg,
              child: const Icon(Icons.build, size: 40, color: VeluneColors.warning),
            ),
            const SizedBox(height: 14),
            Text(user?.name ?? 'Nalin Silva', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Authorized Roadside Technician • ${user?.email}', style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: VeluneColors.border)),
              child: Column(
                children: [
                  _buildProfileRow('License ID', user?.licenseId ?? 'MEC-LK-9021'),
                  const Divider(),
                  _buildProfileRow('Fleet Hub', user?.workshopName ?? 'Expressway Fleet Center - Matara'),
                  const Divider(),
                  _buildProfileRow('Service Van', 'WP-CAB-8812 (Mobile Workshop Unit)'),
                  const Divider(),
                  _buildProfileRow('Active Status', 'On Duty • Immediate Response'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: VeluneColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _authState.logout(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('SIGN OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🚗 3. COMMUTER CARPOOL SHELL (Only Commuter screens & features)
  // =========================================================================
  Widget _buildCommuterAppShell() {
    Widget activeContent;

    switch (_commuterTab) {
      case 0:
        // Tab 0: Commuter Home (HF-03)
        activeContent = CommuterHomeScreen(
          state: _discoveryState,
          userName: _authState.currentUser?.name ?? 'Jay',
          onFindRidePressed: () {
            setState(() {
              _commuterTab = 1; // Switch to Find Rides tab
              _commuterSearchStep = 1; // Jump straight to Available Rides
            });
          },
          onRideSelected: (rideId) {
            setState(() {
              _commuterTab = 1; // Switch to Find Rides tab
              _selectedDiscoveryRideId = rideId;
              _commuterSearchStep = 2; // Jump straight to Ride Details
            });
          },
          onOpenProfile: () => setState(() => _commuterTab = 4),
        );
        break;

      case 1:
        // Tab 1: Find & Discover Rides (HF-04, HF-05, HF-06)
        activeContent = _buildCommuterDiscoveryFlow();
        break;

      case 2:
        // Tab 2: My Bookings & Carpool Trips (Module 2: Confirm, Pickup, Active, Fare Split, Receipt)
        activeContent = _buildCommuterBookingFlow();
        break;

      case 3:
        // Tab 3: Safety & Roadside SOS (Module 3 Commuter Breakdown Assistance)
        activeContent = _buildCommuterEmergencyFlow();
        break;

      case 4:
      default:
        // Tab 4: Commuter Profile & Identity
        activeContent = ProfileScreen(
          authState: _authState,
          onLogout: () => _authState.logout(),
          onSwitchRole: (newRole) => _authState.loginAsRole(newRole),
        );
        break;
    }

    return Scaffold(
      body: SafeArea(child: activeContent),
      bottomNavigationBar: (_commuterTab == 3 && (_commuterEmergencyStep == 0 || _commuterEmergencyStep == 1))
          ? null
          : NavigationBar(
              selectedIndex: _commuterTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VeluneColors.skyBlue,
        height: 68,
        onDestinationSelected: (idx) {
          setState(() {
            _commuterTab = idx;
            if (idx == 1) _commuterSearchStep = 0;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: VeluneColors.primaryNavy),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: VeluneColors.accentBlue),
            label: 'Find Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car, color: VeluneColors.accentBlue),
            label: 'My Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency, color: VeluneColors.danger),
            label: 'Safety SOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: VeluneColors.primaryNavy),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Natural flow within Commuter Discovery (Search -> Results -> Details -> Book)
  Widget _buildCommuterDiscoveryFlow() {
    switch (_commuterSearchStep) {
      case 0:
        return FindRideScreen(
          state: _discoveryState,
          onBack: () => setState(() => _commuterTab = 0),
          onSearchSubmitted: () => setState(() => _commuterSearchStep = 1),
        );
      case 1:
        return AvailableRidesScreen(
          state: _discoveryState,
          onBack: () => setState(() => _commuterSearchStep = 0),
          onViewRide: (rideId) => setState(() {
            _selectedDiscoveryRideId = rideId;
            _commuterSearchStep = 2;
          }),
        );
      case 2:
      default:
        return RideDetailsScreen(
          state: _discoveryState,
          rideId: _selectedDiscoveryRideId,
          onBack: () => setState(() => _commuterSearchStep = 1),
          onContinueToBook: (rideId) {
            // Seamless handoff from Ride Discovery to Booking module!
            setState(() {
              _commuterTab = 2; // Jump to My Trips tab
              _bookingStep = 0; // Start at Booking Confirmation
            });
          },
        );
    }
  }

  // Natural flow within Commuter Booking (Confirm -> Pickup -> Active Trip -> Fare Split -> Receipt)
  Widget _buildCommuterBookingFlow() {
    switch (_bookingStep) {
      case 0:
        return BookingConfirmationScreen(
          state: _bookingState,
          onProceedToPickup: () => setState(() => _bookingStep = 1),
        );
      case 1:
        return LivePickupScreen(
          state: _bookingState,
          onBoardedRide: () => setState(() => _bookingStep = 2),
        );
      case 2:
        return ActiveTripScreen(
          state: _bookingState,
          onGoToSettlement: () => setState(() => _bookingStep = 3),
          onGoToEmergency: () {
            setState(() {
              _commuterTab = 3; // Switch to SOS tab!
              _commuterEmergencyStep = 1;
            });
          },
        );
      case 3:
        return FareSettlementScreen(
          state: _bookingState,
          onPaymentApproved: () => setState(() => _bookingStep = 4),
        );
      case 4:
      default:
        return PaymentReceiptScreen(
          state: _bookingState,
          onReturnToHub: () {
            setState(() {
              _commuterTab = 0; // Return to Home
              _bookingStep = 0;
            });
          },
        );
    }
  }

  // Natural flow within Commuter Emergency (Active Telemetry -> Breakdown Report -> Dispatched)
  Widget _buildCommuterEmergencyFlow() {
    switch (_commuterEmergencyStep) {
      case 0:
        return ActiveRideScreen(
          state: _emergencyState,
          onRequestEmergency: () => setState(() => _commuterEmergencyStep = 1),
          onNavigateTab: (tabIndex) => setState(() => _commuterTab = tabIndex),
        );
      case 1:
        return EmergencyBreakdownScreen(
          state: _emergencyState,
          onMechanicRequested: () => setState(() => _commuterEmergencyStep = 2),
          onBack: () => setState(() => _commuterEmergencyStep = 0),
          onNavigateTab: (tabIndex) => setState(() => _commuterTab = tabIndex),
        );
      case 2:
      default:
        return HelpRequestedScreen(
          state: _emergencyState,
          onIncidentClosed: () => setState(() => _commuterEmergencyStep = 0),
        );
    }
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VeluneColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
