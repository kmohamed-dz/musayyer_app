import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musayyer_app/src/app.dart';
import 'package:musayyer_app/src/core/di/providers.dart';

void main() {
  testWidgets('Musayyer app renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MusayyerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MusayyerApp), findsOneWidget);
  });
}
