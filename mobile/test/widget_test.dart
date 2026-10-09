import 'package:flutter_test/flutter_test.dart';
import 'package:velune_app/main.dart';

void main() {
  testWidgets('Velune app basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VeluneApp());
    expect(find.byType(VeluneApp), findsOneWidget);
  });
}
