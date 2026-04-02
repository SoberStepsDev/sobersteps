import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobersteps/services/sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SyncService addToQueue persists pending operation locally', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SyncService();

    await service.addToQueue('journal_entries', 'insert', {
      'id': 'j1',
      'mood': 4,
    });

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sync_queue_v1');
    expect(raw, isNotNull);
    final list = (jsonDecode(raw!) as List).cast<Map<String, dynamic>>();
    expect(list.length, 1);
    expect(list.first['table_name'], 'journal_entries');
    expect(list.first['operation'], 'insert');
    expect(list.first['payload']['mood'], 4);
  });
}
