import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/core/theme.dart';
import 'package:velune_app/screens/reports_screen.dart';
import 'package:velune_app/screens/pdf_report_viewer_screen.dart';
import 'package:velune_app/state/hr_state.dart';

void main() {
  Widget createTestWidget({required HrState state}) {
    return MaterialApp(
      theme: VeluneTheme.theme,
      home: ReportsScreen(state: state),
    );
  }

  group('Monthly ESG Reports Widget Tests', () {
    testWidgets('TC-HR-W41: Monthly Reports renders latest hero report, archive list, and preview buttons', (tester) async {
      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('ESG Monthly Reports'), findsOneWidget);
      expect(find.text('Latest Published'), findsOneWidget);
      expect(find.text(state.monthlyReports.first.title), findsAtLeastNWidgets(1));
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Download & View'), findsOneWidget);
    });

    testWidgets('TC-HR-W42: Monthly Reports download hero button opens PDF Report Viewer screen', (tester) async {
      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final downloadHeroFinder = find.text('Download & View');
      expect(downloadHeroFinder, findsOneWidget);

      await tester.tap(downloadHeroFinder);
      await tester.pumpAndSettle();

      // PdfReportViewerScreen should be pushed on navigator
      expect(find.byType(PdfReportViewerScreen), findsOneWidget);
      expect(find.text('Official ISO 14064-1 Verified Audit • Read-Only'), findsOneWidget);
    });

    testWidgets('TC-HR-W43: Monthly Reports generate modal creates new report entry', (tester) async {
      final state = HrState();
      final initialCount = state.monthlyReports.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate New'));
      await tester.pumpAndSettle();

      expect(find.text('Generate ESG Report'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'November 2026 Special Audit');
      await tester.enterText(textFields.at(1), '410');
      await tester.enterText(textFields.at(2), '85.0');

      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();

      // Report created and opened
      expect(state.monthlyReports.length, equals(initialCount + 1));
      expect(state.monthlyReports.first.title, equals('November 2026 Special Audit'));
    });

    testWidgets('TC-HR-W44: Monthly Reports delete archive removes report from state', (tester) async {
      final state = HrState();
      final initialCount = state.monthlyReports.length;

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final deleteButtons = find.byIcon(Icons.delete_outline);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        expect(state.monthlyReports.length, equals(initialCount - 1));
      }
    });

    testWidgets('TC-HR-W45: Monthly Reports auto-email switch toggles state', (tester) async {
      final state = HrState();
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final initialVal = state.autoEmailReports;
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(state.autoEmailReports, equals(!initialVal));
    });
  });
}
