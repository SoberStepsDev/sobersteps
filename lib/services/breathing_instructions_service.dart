import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Fetches short breathing-exercise cues from Wikipedia REST API (public HTTPS).
class BreathingInstructionsService {
  BreathingInstructionsService._();

  static Uri _summaryUri(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'pl') {
      return Uri.parse('https://pl.wikipedia.org/api/rest_v1/page/summary/Oddech');
    }
    return Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/Box_breathing',
    );
  }

  static List<String> _splitExtract(String? extract) {
    if (extract == null || extract.trim().isEmpty) return [];
    final cleaned = extract.replaceAll(RegExp(r'\([^)]*\)'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
    final out = <String>[];
    for (final p in parts) {
      final t = p.trim();
      if (t.length > 12) out.add(t);
      if (out.length >= 8) break;
    }
    return out;
  }

  static Future<List<String>> fetchForLocale(Locale locale) async {
    final uri = _summaryUri(locale);
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return _fallback(locale);
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final extract = map['extract'] as String?;
      final lines = _splitExtract(extract);
      if (lines.isNotEmpty) return lines;
    } catch (_) {}
    return _fallback(locale);
  }

  static Future<List<String>> fetch(BuildContext context) =>
      fetchForLocale(Localizations.localeOf(context));

  static List<String> _fallback(Locale locale) {
    if (locale.languageCode.toLowerCase() == 'pl') {
      return const [
        'Usiądź wygodnie. Rozluźnij barki.',
        'Wdychaj nosem przez ok. 4 sekundy.',
        'Zatrzymaj oddech na ok. 4 sekundy.',
        'Wydychaj ustami wolno przez ok. 6 sekund.',
        'Powtórz rytm kilka razy — spokojnie, w swoim tempie.',
        'Skup się na wydłużonym wydechu — to uspokaja układ nerwowy.',
      ];
    }
    return const [
      'Sit comfortably. Loosen your jaw and shoulders.',
      'Inhale gently through your nose for about 4 counts.',
      'Hold softly for about 4 counts.',
      'Exhale slowly through pursed lips for about 6 counts.',
      'Keep the rhythm smooth — no strain.',
      'Longer, slower exhales help your nervous system downshift.',
    ];
  }
}
