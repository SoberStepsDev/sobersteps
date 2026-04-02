import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashService {
  CrashService._();

  static Future<void> recordError(Object error, StackTrace? stack, {bool fatal = false}) async {
    if (kDebugMode) {
      print('CrashService: $error');
      if (stack != null) print(stack);
    }
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }

  static Future<void> recordFatalError(FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  static Future<void> setUserIdentifier(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }
}
