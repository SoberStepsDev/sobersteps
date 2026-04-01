import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local loop index for CrashLog (0 AI tokens). ≥4 similar entries in 30 days → loop mode.
class CrashLogLoopDetector {
  CrashLogLoopDetector._();

  static const _prefsKey = 'crash_log_loop_records_v1';
  static const _window = Duration(days: 30);
  static const _jaccardThreshold = 0.35;
  /// Prior similar entries needed so this submission is the 4th in a cluster.
  static const _priorSimilarNeeded = 3;
  static const _maxRecords = 60;

  static const List<String> _stop = [
    'i', 'a', 'an', 'the', 'to', 'of', 'in', 'for', 'on', 'with', 'is', 'are', 'was', 'were',
    'it', 'at', 'be', 'or', 'as', 'if', 'my', 'me', 'we', 'you', 'he', 'she', 'they', 'this',
    'that', 'but', 'not', 'so', 'do', 'does', 'did', 'have', 'has', 'had', 'just', 'very',
    'i', 'w', 'na', 'z', 'że', 'do', 'nie', 'się', 'co', 'jak', 'to', 'od', 'po', 'za', 'ale',
    'o', 'u', 'dla', 'jest', 'są', 'te', 'przy', 'czy', 'tylko', 'już', 'mi', 'go', 'ich',
    'mnie', 'mną', 'sobie', 'jego', 'jej', 'ich', 'ten', 'ta', 'tę', 'tą', 'nim', 'nam',
  ];

  static double jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1;
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return inter / union;
  }

  static Set<String> tokenize(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = s.split(' ').where((w) => w.isNotEmpty).toList();
    final out = <String>{};
    for (final w in parts) {
      if (w.length < 2) continue;
      if (_stop.contains(w)) continue;
      out.add(w);
    }
    if (out.isEmpty && raw.trim().isNotEmpty) {
      final h = sha256.convert(utf8.encode(raw.toLowerCase().trim())).toString();
      return {h.substring(0, 16)};
    }
    return out;
  }

  static Future<List<_Record>> _loadPruned() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    List<dynamic> list;
    try {
      list = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
    final cutoff = DateTime.now().toUtc().subtract(_window);
    final out = <_Record>[];
    for (final e in list) {
      if (e is! Map) continue;
      final t = e['t'] as String?;
      final words = e['w'] as List<dynamic>?;
      if (t == null || words == null) continue;
      final dt = DateTime.tryParse(t);
      if (dt == null) continue;
      if (dt.toUtc().isBefore(cutoff)) continue;
      out.add(_Record(dt.toUtc(), words.map((x) => '$x').toSet()));
    }
    return out;
  }

  static Future<void> _save(List<_Record> records) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = records.length > _maxRecords
        ? records.sublist(records.length - _maxRecords)
        : records;
    final encoded = jsonEncode(trimmed
        .map((r) => {
              't': r.t.toIso8601String(),
              'w': r.words.toList()..sort(),
            })
        .toList());
    await prefs.setString(_prefsKey, encoded);
  }

  /// True when ≥3 prior entries in [past] are similar to [current] (4th hit uses loop mode).
  static bool isLoopThresholdReached(Iterable<Set<String>> past, Set<String> current) {
    var similar = 0;
    for (final p in past) {
      if (jaccard(current, p) >= _jaccardThreshold) similar++;
    }
    return similar >= _priorSimilarNeeded;
  }

  /// True when this submission should use loop (harsher) AI — 4th similar in 30d window.
  static Future<bool> shouldUseLoopMode(String text) async {
    final current = tokenize(text);
    final past = await _loadPruned();
    return isLoopThresholdReached(past.map((r) => r.words), current);
  }

  /// Call after a successful AI response so the next check sees this entry.
  static Future<void> recordSubmission(String text) async {
    final current = tokenize(text);
    final past = await _loadPruned();
    past.add(_Record(DateTime.now().toUtc(), current));
    past.sort((a, b) => a.t.compareTo(b.t));
    await _save(past);
  }
}

class _Record {
  final DateTime t;
  final Set<String> words;
  _Record(this.t, this.words);
}
