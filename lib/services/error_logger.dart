import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../constants/app_constants.dart';

enum ErrorCategory {
  network,
  auth,
  database,
  storage,
  crypto,
  validation,
  ui,
  unknown,
}

class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();

  ErrorLogger._internal();

  factory ErrorLogger() => _instance;

  /// Log error with full stack trace and optional Sentry integration
  static Future<void> log(
    Object error,
    StackTrace stackTrace, {
    String? context,
    ErrorCategory category = ErrorCategory.unknown,
    bool captureToSentry = true,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final categoryStr = category.toString().split('.').last;

    debugPrint(
      '[$categoryStr] [$timestamp] $context: $error\n'
      'Stack trace:\n$stackTrace',
    );

    if (captureToSentry && AppConstants.sentryDsn.isNotEmpty) {
      try {
        await Sentry.captureException(
          error,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'error_category': categoryStr,
            'context': context,
          }),
        );
      } catch (e) {
        debugPrint('[ErrorLogger] Failed to send to Sentry: $e');
      }
    }
  }

  /// Log exception from provider/service
  static Future<void> logException(
    String classMethod,
    Object error,
    StackTrace stackTrace,
    ErrorCategory category,
  ) =>
      log(error, stackTrace, context: classMethod, category: category);

  /// Log validation error (doesn't go to Sentry)
  static Future<void> logValidationError(String message) async {
    debugPrint('[Validation] $message');
  }

  /// Log auth error
  static Future<void> logAuthError(
    String method,
    Object error,
    StackTrace stackTrace,
  ) =>
      log(error, stackTrace,
          context: 'AuthProvider.$method', category: ErrorCategory.auth);

  /// Log network/Supabase error
  static Future<void> logDatabaseError(
    String method,
    Object error,
    StackTrace stackTrace,
  ) =>
      log(error, stackTrace,
          context: 'Database.$method', category: ErrorCategory.database);
}
