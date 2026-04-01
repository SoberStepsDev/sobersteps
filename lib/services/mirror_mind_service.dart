import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MirrorMindService {
  MirrorMindService._();
  static const _queueKey = 'pending_mirror_entries';

  static Future<void> logMoment({
    required String content,
    required String type,
    int? energyLevel,
    List<String>? tags,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final text = content.length > 1000 ? content.substring(0, 1000) : content;
    final row = <String, dynamic>{
      'entry_type': type,
      'content': text,
      'energy_level': ?energyLevel,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    };
    if (user == null) {
      await _enqueue(row);
      return;
    }
    row['user_id'] = user.id;
    try {
      await client.from('mirror_entries').insert(row);
    } catch (e, s) {
      debugPrint('[MirrorMind] insert failed, queue: $e');
      await _enqueue(row);
      if (kDebugMode) debugPrintStack(stackTrace: s);
    }
  }

  static Future<void> _enqueue(Map<String, dynamic> row) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final q = prefs.getStringList(_queueKey) ?? [];
      q.add(jsonEncode(row));
      await prefs.setStringList(_queueKey, q);
    } catch (e, s) {
      debugPrint('[MirrorMindService] _enqueue: $e\n$s');
    }
  }

  static Future<void> syncPending() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final q = prefs.getStringList(_queueKey) ?? [];
      if (q.isEmpty) return;
      final remain = <String>[];
      for (final raw in q) {
        try {
          final m = Map<String, dynamic>.from(jsonDecode(raw) as Map);
          m['user_id'] = user.id;
          await client.from('mirror_entries').insert(m);
        } catch (e, s) {
          debugPrint('[MirrorMindService] syncPending item: $e\n$s');
          remain.add(raw);
        }
      }
      await prefs.setStringList(_queueKey, remain);
    } catch (e, s) {
      debugPrint('[MirrorMindService] syncPending: $e\n$s');
    }
  }
}
