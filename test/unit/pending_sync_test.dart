import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/models/pending_sync.dart';

void main() {
  test('PendingSync fromJson/toJson roundtrip', () {
    final item = PendingSync.fromJson({
      'id': 's1',
      'table_name': 'journal_entries',
      'operation': 'insert',
      'payload': {'mood': 4},
      'created_at': '2026-03-23T10:00:00.000Z',
      'retry_count': 1,
    });

    expect(item.id, 's1');
    expect(item.retryCount, 1);
    expect(item.toJson()['table_name'], 'journal_entries');
    expect(item.toJson()['payload'], {'mood': 4});
  });

  test('PendingSync copyWith overrides retryCount only', () {
    final base = PendingSync(
      id: 's1',
      tableName: 'journal_entries',
      operation: 'insert',
      payload: const {'mood': 4},
      createdAt: DateTime.parse('2026-03-23T10:00:00.000Z'),
      retryCount: 0,
    );

    final changed = base.copyWith(retryCount: 3);
    expect(changed.retryCount, 3);
    expect(changed.id, base.id);
    expect(changed.tableName, base.tableName);
  });
}
