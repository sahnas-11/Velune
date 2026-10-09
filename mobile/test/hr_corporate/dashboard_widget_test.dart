import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/dashboard_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state, Function(int)? onNavigate}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: DashboardScreen(
        state: state,
        onNavigateTab: onNavigate ?? (_) {},
      ),
    );
  }

  group('HR Dashboard Widget Tests', () {
    testWidgets('TC-HR-W01: HR Dashboard renders title, KPIs, and status metrics', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Check Header and KPI metrics
      expect(find.text('Amanda Jayawardena'), findsOneWidget);
      expect(find.text('Head of HR & Corporate Facilities'), findsOneWidget);
      expect(find.text('Fleet Decarbonization'), findsOneWidget);
      expect(find.text('${state.settings.campusTargetPercent}% Target'), findsOneWidget);
      expect(find.text('CO2 Saved This Mo.'), findsOneWidget);
      expect(find.text('${state.totalCo2Saved} kg'), findsOneWidget);
      expect(find.text('Active Carpoolers'), findsOneWidget);
      expect(find.text('Single Cars Reduced'), findsOneWidget);
    });

    testWidgets('TC-HR-W02: HR Dashboard notification center dismiss item deletes notification', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Notification bell in app bar
      final bellFinder = find.byIcon(Icons.notifications_outlined);
      expect(bellFinder, findsOneWidget);

      await tester.tap(bellFinder);
      await tester.pumpAndSettle();

      // Corporate Alerts modal is open
      expect(find.text('Corporate Alerts'), findsOneWidget);
      expect(find.text('Mark All Read'), findsOneWidget);

      // Dismiss first notification
      final deleteButtons = find.byIcon(Icons.delete_outline);
      if (deleteButtons.evaluate().isNotEmpty) {
        final initialCount = state.notifications.length;
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        expect(state.notifications.length, equals(initialCount - 1));
      }
    });

    testWidgets('TC-HR-W03: HR Dashboard quick action navigation triggers callback (Dashboard -> CO2)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      int navigatedTab = -1;

      await tester.pumpWidget(createTestWidget(
        state: state,
        onNavigate: (tab) => navigatedTab = tab,
      ));
      await tester.pumpAndSettle();

      // Find quick action button for CO2 Log
      final co2ActionFinder = find.text('CO2 Log');
      expect(co2ActionFinder, findsOneWidget);

      await tester.tap(co2ActionFinder);
      await tester.pumpAndSettle();

      // Tab index 1 corresponds to CO2 Reduction Report
      expect(navigatedTab, equals(1));
    });

    testWidgets('TC-HR-W04: HR Dashboard edit campus target dialog opens and updates target', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Find Edit Target gesture
      final editTargetFinder = find.text('${state.settings.campusTargetPercent}% Target');
      expect(editTargetFinder, findsOneWidget);

      await tester.tap(editTargetFinder);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Edit Campus Target %'), findsOneWidget);
      expect(find.text('Save Target'), findsOneWidget);

      // Enter new target percentage
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, '85');
      await tester.tap(find.text('Save Target'));
      await tester.pumpAndSettle();

      expect(state.settings.campusTargetPercent, equals(85));
    });

    testWidgets('TC-HR-W05: HR Dashboard empty notification state displays clean empty banner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      state.notifications.clear();

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Open notifications modal
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(find.text('No active notifications'), findsOneWidget);
    });
  });
}
