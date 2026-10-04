
import 'package:flutter_test/flutter_test.dart';
import 'package:no_coffee_app/main.dart';

void main() {
  testWidgets('App launches and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(const TaperApp());
    expect(find.text('Taper'), findsOneWidget);

    // Let the splash screen's navigation timer finish instead of leaving it pending.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}