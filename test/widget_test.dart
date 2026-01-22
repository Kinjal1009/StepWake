// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_wake/main.dart';
import 'package:step_wake/presentation/providers/alarm_provider.dart';

void main() {
  testWidgets('StepWake app smoke test', (WidgetTester tester) async {
    // Initializing mock shared preferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const StepWakeApp(),
      ),
    );

    // Verify that the app header is present
    expect(find.text('STEPWAKE'), findsOneWidget);

    // Verify that "No alarms set" is present initially
    expect(find.text('No alarms set'), findsOneWidget);
  });
}
