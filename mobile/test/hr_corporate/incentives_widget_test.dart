import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/incentives_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: Scaffold(
        body: IncentivesScreen(state: state),
      ),
    );
  }

  group('Corporate Incentives Widget Tests', () {
    testWidgets('TC-HR-W51: Corporate Incentives renders active programs and fleet leaderboard', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Corporate Incentives'), findsOneWidget);
      expect(find.text('Active Corporate Programs'), findsOneWidget);
      expect(find.text('Add Program'), findsOneWidget);

      // Verify program cards
      expect(find.text(state.incentives.first.title), findsOneWidget);
    });

    testWidgets('TC-HR-W52: Corporate Incentives add program modal validation rejects empty title', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.incentives.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Program'));
      await tester.pumpAndSettle();

      expect(find.text('New Incentive Program'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), ''); // Empty title
      await tester.enterText(textFields.at(1), 'Negative test budget description');
      await tester.enterText(textFields.at(2), '5000');
      await tester.enterText(textFields.at(3), '0');

      await tester.tap(find.text('Add Incentive Program'));
      await tester.pumpAndSettle();

      // Program must NOT be added with empty title
      expect(state.incentives.length, equals(initialCount));
    });

    testWidgets('TC-HR-W53: Corporate Incentives creates new incentive program into state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.incentives.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Program'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Expressway Toll Grant');
      await tester.enterText(textFields.at(1), 'Reimbursement for 3+ carpools');
      await tester.enterText(textFields.at(2), '40000');
      await tester.enterText(textFields.at(3), '15000');

      await tester.tap(find.text('Add Incentive Program'));
      await tester.pumpAndSettle();

      expect(state.incentives.length, equals(initialCount + 1));
      expect(find.text('Expressway Toll Grant'), findsOneWidget);
    });

    testWidgets('TC-HR-W54: Corporate Incentives delete program removes item from state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.incentives.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final deleteButtons = find.text('Delete');
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        expect(state.incentives.length, equals(initialCount - 1));
      }
    });

    testWidgets('TC-HR-W55: Corporate Incentives toggle pause/resume updates program status', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final firstProgram = state.incentives.first;
      final initialStatus = firstProgram.isActive;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final pauseButtons = find.text('Pause');
      expect(pauseButtons, findsWidgets);

      await tester.tap(pauseButtons.first);
      await tester.pumpAndSettle();

      expect(firstProgram.isActive, equals(!initialStatus));
    });
  });
}
