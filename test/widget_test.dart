import 'package:flutter_test/flutter_test.dart';

import 'package:musayyer_app/main.dart';

void main() {
  testWidgets('Musayyer app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MusayyerApp());

    expect(find.text('Musayyer'), findsOneWidget);
  });
}
