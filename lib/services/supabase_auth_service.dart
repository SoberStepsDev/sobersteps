import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
 
class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;
 
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
 
  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: AppConstants.authRedirectUrl,
    );
  }
 
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }
 
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(OAuthProvider.apple);
  }
 
  Future<void> signOut() async {
    await _client.auth.signOut();
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
        await _client.from('profiles').insert({'id': user.id});
      }
    } catch (_) {}
  }
 
  Future<void> insertEmailLead(String email) async {
    try {
      await _client.from('email_leads').upsert({'email': email}, onConflict: 'email');
    } catch (_) {}
  }
 
  Future<void> signUpWithPassword(String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'created_at': DateTime.now().toIso8601String()},
    );
  }
 
  Future<void> signInWithPassword(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
 
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConstants.authRedirectUrl,
    );
  }
}
 