import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('critical UI journey: auth -> checkin -> sync -> purchase', (tester) async {
    await tester.pumpWidget(const _CriticalFlowApp());

    expect(find.text('Auth'), findsOneWidget);
    await tester.tap(find.byKey(const Key('go-checkin')));
    await tester.pumpAndSettle();

    expect(find.text('Check-in'), findsOneWidget);
    await tester.tap(find.byKey(const Key('complete-checkin')));
    await tester.pumpAndSettle();

    expect(find.text('Sync'), findsOneWidget);
    await tester.tap(find.byKey(const Key('run-sync')));
    await tester.pumpAndSettle();

    expect(find.text('Purchase'), findsOneWidget);
    await tester.tap(find.byKey(const Key('complete-purchase')));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
  });
}

class _CriticalFlowApp extends StatelessWidget {
  const _CriticalFlowApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const _AuthScreen(),
    );
  }
}

class _AuthScreen extends StatelessWidget {
  const _AuthScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Auth'),
          ElevatedButton(
            key: const Key('go-checkin'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _CheckinScreen()),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _CheckinScreen extends StatelessWidget {
  const _CheckinScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Check-in'),
          ElevatedButton(
            key: const Key('complete-checkin'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _SyncScreen()),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _SyncScreen extends StatelessWidget {
  const _SyncScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Sync'),
          ElevatedButton(
            key: const Key('run-sync'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _PurchaseScreen()),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _PurchaseScreen extends StatelessWidget {
  const _PurchaseScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Purchase'),
          ElevatedButton(
            key: const Key('complete-purchase'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Scaffold(body: Center(child: Text('Done'))),
              ),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
