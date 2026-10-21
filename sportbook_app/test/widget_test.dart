import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SportBookApp());
    expect(find.byType(SportBookApp), findsOneWidget);
  });
}
