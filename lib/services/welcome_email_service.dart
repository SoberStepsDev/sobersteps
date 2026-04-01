import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeEmailService {
  static const _pendingRegistrationKey = 'pending_registration_welcome_uid';

  /// In-memory pending id so auth listeners that run before SharedPreferences persists still see it.
  static String? _pendingRegistrationUserId;

  static Future<void> markPendingRegistrationWelcome(String userId) async {
    _pendingRegistrationUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingRegistrationKey, userId);
  }

  static Future<void> postAuthEmailHooks(User? user) async {
    if (user == null) return;
    await trySendRegistrationWelcome(user);
    await trySendConfirmationEmail(user);
  }

  static Future<void> trySendRegistrationWelcome(User user) async {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getString(_pendingRegistrationKey) ?? _pendingRegistrationUserId;
    if (pending != user.id) return;

    final sentKey = 'registration_welcome_sent_${user.id}';
    if (prefs.getBool(sentKey) == true) return;

    final client = Supabase.instance.client;
    try {
      final res = await client.functions.invoke(
        'send_welcome_email',
        body: {'email': email},
      );
      final data = res.data;
      if (data is Map && data['ok'] == true) {
        _pendingRegistrationUserId = null;
        await prefs.remove(_pendingRegistrationKey);
        await prefs.setBool(sentKey, true);
      }
    } catch (_) {}
  }

  static Future<void> trySendConfirmationEmail(User user) async {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) return;
    if (user.emailConfirmedAt == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'confirmation_email_sent_${user.id}';
    if (prefs.getBool(key) == true) return;

    final client = Supabase.instance.client;
    try {
      final res = await client.functions.invoke(
        'send_confirmation_email',
        body: {'email': email},
      );
      final data = res.data;
      if (data is Map && data['ok'] == true) {
        await prefs.setBool(key, true);
      }
    } catch (_) {}
  }
}
