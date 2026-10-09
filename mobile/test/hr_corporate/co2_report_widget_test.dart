import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/co2_report_screen.dart';
import 'package:velune_app/screens/pdf_report_viewer_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: Co2ReportScreen(state: state),
    );
  }

  group('CO2 Reduction Report Widget Tests', () {
    testWidgets('TC-HR-W21: CO2 Reduction Report renders avoided kg, progress bar and equivalents', (tester) async {
      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('CO2 Reduction Report'), findsOneWidget);
      expect(find.text('${state.totalCo2Saved} kg'), findsOneWidget);
      expect(find.text('Total CO2 Avoided (Month)'), findsOneWidget);
      expect(find.text('14 Trees'), findsOneWidget);
      expect(find.text('1,240 mi'), findsOneWidget);
    });

    testWidgets('TC-HR-W22: CO2 Reduction Report log entry modal validation rejects 0 kg', (tester) async {
      final state = HrState();
      final initialCount = state.co2Records.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Entry'));
      await tester.pumpAndSettle();

      expect(find.text('Log New CO2 Entry'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), '0'); // 0 kg
      await tester.tap(find.text('Add CO2 Record'));
      await tester.pumpAndSettle();

      // Count must not increase
      expect(state.co2Records.length, equals(initialCount));
    });

    testWidgets('TC-HR-W23: CO2 Reduction Report logs new weekly carbon record', (tester) async {
      final state = HrState();
      final initialCount = state.co2Records.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Entry'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Week 5 Test');
      await tester.enterText(textFields.at(1), '95');
      await tester.enterText(textFields.at(2), 'Oct 22 - Oct 28');

      await tester.tap(find.text('Add CO2 Record'));
      await tester.pumpAndSettle();

      expect(state.co2Records.length, equals(initialCount + 1));
      expect(find.text('Week 5 Test'), findsOneWidget);
    });

    testWidgets('TC-HR-W24: CO2 Reduction Report download banner navigates to PDF viewer', (tester) async {
      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      // Find the official ESG Report download banner
      final bannerFinder = find.text('Download Official ESG Report (PDF)');
      expect(bannerFinder, findsOneWidget);

      await tester.tap(bannerFinder);
      await tester.pumpAndSettle();

      // PdfReportViewerScreen should be pushed on navigator
      expect(find.byType(PdfReportViewerScreen), findsOneWidget);
      expect(find.text('Official ISO 14064-1 Verified Audit • Read-Only'), findsOneWidget);

      // Back navigation button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Returned to CO2 Report screen
      expect(find.byType(Co2ReportScreen), findsOneWidget);
    });
  });
}
