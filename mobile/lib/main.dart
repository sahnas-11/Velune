import 'package:flutter/material.dart';
import 'core/theme.dart';
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
      title: 'Velune Corporate HR',
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
  int _currentIndex = 0;
  final HrState _hrState = HrState();

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(state: _hrState, onNavigateTab: _onNavigateTab),
      Co2ReportScreen(state: _hrState),
      ParkingScreen(state: _hrState, onNavigateTab: _onNavigateTab),
      StatisticsScreen(state: _hrState),
      ReportsScreen(state: _hrState),
      IncentivesScreen(state: _hrState),
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: VeluneColors.navyGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      'AJ',
                      style: TextStyle(
                        color: VeluneColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Amanda Jayawardena',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    'Head of HR & Corporate Facilities',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: VeluneColors.primaryNavy),
              title: const Text('1. HR Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                _onNavigateTab(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.eco_outlined, color: VeluneColors.success),
              title: const Text('2. CO2 Reduction Report'),
              selected: _currentIndex == 1,
              onTap: () {
                _onNavigateTab(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_parking_outlined, color: VeluneColors.accentBlue),
              title: const Text('3. Parking Allocation'),
              selected: _currentIndex == 2,
              onTap: () {
                _onNavigateTab(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined, color: Colors.deepPurple),
              title: const Text('4. Carpool Statistics'),
              selected: _currentIndex == 3,
              onTap: () {
                _onNavigateTab(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: VeluneColors.warning),
              title: const Text('5. Monthly ESG Reports'),
              selected: _currentIndex == 4,
              onTap: () {
                _onNavigateTab(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined, color: Colors.amber),
              title: const Text('6. Corporate Incentives'),
              selected: _currentIndex == 5,
              onTap: () {
                _onNavigateTab(5);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'IT3060 HCI - Milestone 03\nModule: HR / Corporate & System Integration\nOwner: IT23555112',
                style: TextStyle(fontSize: 11, color: VeluneColors.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex > 4 ? 4 : _currentIndex,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VeluneColors.skyBlue,
        elevation: 3,
        height: 65,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: VeluneColors.primaryNavy),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: VeluneColors.success),
            label: 'CO2',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking, color: VeluneColors.accentBlue),
            label: 'Parking',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.deepPurple),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description, color: VeluneColors.warning),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
