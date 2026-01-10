import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmed_app/main.dart'; // Import main.dart to access SmartMedApp

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SmartMedApp()));

    // Verify that our app starts.
    expect(find.text('SmartMed'), findsOneWidget);
  });
}
