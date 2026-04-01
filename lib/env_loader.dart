import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants/app_constants.dart';

Map<String, String> _parseEnvToMap(String raw) {
  final out = <String, String>{};
  for (var line in raw.split('\n')) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    final k = line.substring(0, eq).trim();
    var v = line.substring(eq + 1).trim();
    if ((v.startsWith('"') && v.endsWith('"')) ||
        (v.startsWith("'") && v.endsWith("'"))) {
      v = v.substring(1, v.length - 1);
    }
    if (k.isNotEmpty) out[k] = v;
  }
  return out;
}

Future<void> loadAppEnv() async {
  final merged = <String, String>{};

  // 1. Base example (non-secret defaults, always bundled)
  try {
    merged.addAll(_parseEnvToMap(
      await rootBundle.loadString('assets/config.env.example'),
    ));
  } catch (_) {}

  // 2. Flavor-specific bundled file (dev only — never bundle prod secrets)
  if (AppConstants.isDevelopment) {
    for (final asset in ['assets/config.dev.env', 'assets/config.env']) {
      try {
        merged.addAll(_parseEnvToMap(await rootBundle.loadString(asset)));
      } catch (_) {}
    }
  }

  // 3. Filesystem overrides (local dev only, never on Android release)
  if (!kIsWeb && AppConstants.isDevelopment) {
    for (final path in ['assets/config.dev.env', 'assets/config.env', '.env']) {
      try {
        final f = File(path);
        if (await f.exists()) {
          merged.addAll(_parseEnvToMap(await f.readAsString()));
        }
      } catch (_) {}
    }
  }

  dotenv.loadFromString(
    envString: merged.isEmpty
        ? ''
        : merged.entries.map((e) => '${e.key}=${e.value}').join('\n'),
    isOptional: true,
  );
  if (!dotenv.isInitialized) {
    dotenv.loadFromString(envString: '', isOptional: true);
  }
}
