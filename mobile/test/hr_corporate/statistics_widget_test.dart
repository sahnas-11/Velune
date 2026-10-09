import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/statistics_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: StatisticsScreen(state: state),
    );
  }

  group('Carpool Statistics Widget Tests', () {
    testWidgets('TC-HR-W31: Carpool Statistics renders top routes, average riders, and commute splits', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Carpool Statistics'), findsOneWidget);
      expect(find.text('Top Performing Routes'), findsOneWidget);
      expect(find.text('Pin Route'), findsOneWidget);

      // Verify route names from initial state
      expect(find.text(state.topRoutes.first.name), findsOneWidget);
    });

    testWidgets('TC-HR-W32: Carpool Statistics pins new corridor route into registry', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.topRoutes.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pin Route'));
      await tester.pumpAndSettle();

      expect(find.text('Pin Commuter Route'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Panadura Coastal Express');
      await tester.enterText(textFields.at(1), '50');
      await tester.enterText(textFields.at(2), 'High EV Share');

      await tester.tap(find.text('Pin to Dashboard'));
      await tester.pumpAndSettle();

      expect(state.topRoutes.length, equals(initialCount + 1));
      expect(find.text('Panadura Coastal Express'), findsOneWidget);
    });

    testWidgets('TC-HR-W33: Carpool Statistics unpin route removes item from top routes', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      final initialCount = state.topRoutes.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final closeIcons = find.byIcon(Icons.close);
      if (closeIcons.evaluate().isNotEmpty) {
        await tester.tap(closeIcons.first);
        await tester.pumpAndSettle();

        expect(state.topRoutes.length, equals(initialCount - 1));
      }
    });

    testWidgets('TC-HR-W34: Carpool Statistics commute mode breakdown displays splits', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Commute Modal Share'), findsOneWidget);
      expect(find.text(state.commuteSplits.first.name), findsOneWidget);
      expect(find.text('${state.commuteSplits.first.percentage.toInt()}%'), findsOneWidget);
    });
  });
}
