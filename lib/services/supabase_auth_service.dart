import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(email: email);
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
  }

  Future<void> insertEmailLead(String email) async {
    try {
      await _client.from('email_leads').upsert({'email': email}, onConflict: 'email');
    } catch (_) {}
  }
}
