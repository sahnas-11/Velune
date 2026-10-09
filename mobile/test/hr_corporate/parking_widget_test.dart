import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/parking_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state, Function(int)? onNavigate}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: Scaffold(
        body: ParkingScreen(
          state: state,
          onNavigateTab: onNavigate,
        ),
      ),
    );
  }

  group('Parking Allocation Widget Tests', () {
    testWidgets('TC-HR-W11: Parking Allocation renders Deck B bays and allocation list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Parking Allocation'), findsOneWidget);
      expect(find.text('Corporate Deck B'), findsOneWidget);
      expect(find.text('Assigned Carpool Cohorts'), findsOneWidget);
      expect(find.text('Allocate Bay'), findsOneWidget);

      // Verify initial parking groups are displayed
      expect(find.text(state.parkingGroups.first.groupName), findsOneWidget);
    });

    testWidgets('TC-HR-W12: Parking Allocation allocate spot modal validation rejects empty spot code', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.parkingGroups.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Allocate Bay'));
      await tester.pumpAndSettle();

      expect(find.text('Allocate Priority Spot'), findsOneWidget);

      // Clear spot code field (4th text field in modal)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      await tester.enterText(textFields.at(3), ''); // empty spot code
      await tester.tap(find.text('Confirm Spot Allocation'));
      await tester.pumpAndSettle();

      // State count should NOT increase if spot code was empty
      expect(state.parkingGroups.length, equals(initialCount));
    });

    testWidgets('TC-HR-W13: Parking Allocation allocates new carpool bay into state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.parkingGroups.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Allocate Bay'));
      await tester.pumpAndSettle();

      // Enter valid group and spot
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Group Test QA');
      await tester.enterText(textFields.at(1), 'Kandy Corridor');
      await tester.enterText(textFields.at(2), '4');
      await tester.enterText(textFields.at(3), 'B-28');

      await tester.tap(find.text('Confirm Spot Allocation'));
      await tester.pumpAndSettle();

      expect(state.parkingGroups.length, equals(initialCount + 1));
      expect(find.text('Group Test QA'), findsOneWidget);
    });

    testWidgets('TC-HR-W14: Parking Allocation release spot deletes bay from list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.parkingGroups.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Find release button
      final releaseButtons = find.text('Release');
      expect(releaseButtons, findsWidgets);

      await tester.tap(releaseButtons.first);
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Release Bay'), findsOneWidget);
      await tester.tap(find.text('Release Bay'));
      await tester.pumpAndSettle();

      expect(state.parkingGroups.length, equals(initialCount - 1));
    });

    testWidgets('TC-HR-W15: Parking Allocation navigation callback to incentives works', (tester) async {
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

      // Tap on View Incentives banner
      final incentiveBanner = find.text('View Corporate Incentive Programs');
      expect(incentiveBanner, findsOneWidget);

      await tester.tap(incentiveBanner);
      await tester.pumpAndSettle();
      expect(navigatedTab, equals(5));
    });
  });
}
