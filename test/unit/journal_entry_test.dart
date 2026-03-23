import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/models/journal_entry.dart';

void main() {
  test('JournalEntry fromJson parses values', () {
    final entry = JournalEntry.fromJson({
      'id': 'j1',
      'user_id': 'u1',
      'mood': 4,
      'craving_level': 3,
      'triggers': ['stress', 'loneliness'],
      'note': 'ok',
      'created_at': '2026-03-23T10:00:00.000Z',
    });

    expect(entry.id, 'j1');
    expect(entry.userId, 'u1');
    expect(entry.mood, 4);
    expect(entry.cravingLevel, 3);
    expect(entry.triggers, ['stress', 'loneliness']);
    expect(entry.note, 'ok');
  });

  test('JournalEntry toJson maps API payload fields', () {
    final entry = JournalEntry(
      id: 'j1',
      userId: 'u1',
      mood: 5,
      cravingLevel: 2,
      triggers: const ['stress'],
      note: 'note',
      createdAt: DateTime.parse('2026-03-23T10:00:00.000Z'),
    );

    expect(entry.toJson(), {
      'user_id': 'u1',
      'mood': 5,
      'craving_level': 2,
      'triggers': ['stress'],
      'note': 'note',
    });
  });
}
