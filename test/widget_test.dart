import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SoberStepsApp());
    expect(find.text('SoberSteps'), findsOneWidget);
  });
}
