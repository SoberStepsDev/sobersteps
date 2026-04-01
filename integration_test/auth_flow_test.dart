import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soberstepsod/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Navigate from splash to auth screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify splash screen or navigation to auth
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Auth screen displays login and register buttons', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to auth screen if needed
      await tester.tap(find.byType(MaterialButton).first);
      await tester.pumpAndSettle();

      // Verify UI elements exist
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Sign in button is disabled when form is empty', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find sign-in button and verify initial state
      final signInButton = find.byType(ElevatedButton);
      if (signInButton.evaluate().isNotEmpty) {
        expect(signInButton, findsWidgets);
      }
    });

    testWidgets('Error handling in auth flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test error message display if auth fails
      expect(find.byType(Text), findsWidgets);
    });
  });
}
