import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soberstepsod/providers/sobriety_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SobrietyProvider loads local date and computes milestone fields', () async {
    final start = DateTime.now().subtract(const Duration(days: 8));
    SharedPreferences.setMockInitialValues({
      'sobriety_start_date': start.toIso8601String().split('T')[0],
    });

    final provider = SobrietyProvider();
    await provider.loadFromLocal();

    expect(provider.daysSober, greaterThanOrEqualTo(7));
    expect(provider.nextMilestone, isNotNull);
    expect(provider.daysToNextMilestone, greaterThan(0));
    expect(provider.progressToNextMilestone, inInclusiveRange(0.0, 1.0));
  });
}
