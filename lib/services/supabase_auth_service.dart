
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

String _oauthRedirectUrl() {
  if (kIsWeb) {
    final u = Uri.base;
    return u.replace(fragment: '').toString();
  }
  return AppConstants.authRedirectUrl;
}

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: AppConstants.authRedirectUrl,
    );
  }

  Future<AuthResponse> signUpWithPassword(
    String email,
    String password, {
    String? displayName,
    int? birthYear,
    String? gender,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'created_at': DateTime.now().toIso8601String(),
          if (displayName != null && displayName.isNotEmpty) 'display_name': displayName,
          if (birthYear != null) 'birth_year': birthYear,
          if (gender != null) 'gender': gender,
        },
      );
    } on AuthException catch (e) {
      debugPrint('[Auth] signUpWithPassword error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] Unexpected error during signUpWithPassword: $e');
      rethrow;
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      debugPrint('[Auth] signInWithPassword error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] Unexpected error during signInWithPassword: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _oauthRedirectUrl(),
    );
  }

  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: _oauthRedirectUrl(),
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConstants.authRedirectUrl,
    );
  }

  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> ensureProfile() async {
    try {
      final user = currentUser;
      if (user == null) return;
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (existing == null) {
        final meta = user.userMetadata ?? {};
        final displayName = (meta['display_name'] as String?)?.trim().isNotEmpty == true
            ? meta['display_name'] as String
            : (meta['full_name'] as String?)?.trim().isNotEmpty == true
                ? meta['full_name'] as String
                : (meta['name'] as String?);
        final birthYear = meta['birth_year'] as int?;
        final gender = meta['gender'] as String?;

        await _client.from('profiles').insert({
          'id': user.id,
          if (displayName != null) 'display_name': displayName,
          if (birthYear != null) 'birth_year': birthYear,
          if (gender != null) 'gender': gender,
        });
      }
    } catch (_) {}
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('[Auth] signOut error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] Unexpected error during signOut: $e');
      rethrow;
    }
  }

  Future<void> insertEmailLead(String email) async {
    try {
      await _client.from('email_leads').upsert({'email': email}, onConflict: 'email');
    } catch (_) {}
  }

  static bool needsEmailPasswordIdentity(User? user) {
    if (user == null) return false;
    return user.identities?.any((i) => i.provider == 'email') ?? false;
  }
}
