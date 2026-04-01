import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../l10n/strings.dart';
import '../widgets/post_login_redirect.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostLoginRedirect(
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'login'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Image.asset(
                  'assets/images/SoberStepsLogo.png',
                  height: 64,
                  width: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.lock_open_rounded, size: 64, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Text(S.t(context, 'loginToSoberSteps'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: S.t(context, 'email'),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: S.t(context, 'password'),
                    suffixIcon: Tooltip(
                      message: S.t(
                        context,
                        _obscurePassword ? 'passwordVisibilityShow' : 'passwordVisibilityHide',
                      ),
                      child: Semantics(
                        label: S.t(
                          context,
                          _obscurePassword ? 'passwordVisibilityShow' : 'passwordVisibilityHide',
                        ),
                        button: true,
                        child: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(S.t(context, 'login')),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => _showResetPasswordDialog(),
                    child: Text(S.t(context, 'forgotPassword'), style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 32),
                Row(children: [
                  const Expanded(child: Divider(color: AppColors.surfaceLight)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(S.t(context, 'or'), style: const TextStyle(color: AppColors.textSecondary))),
                  const Expanded(child: Divider(color: AppColors.surfaceLight)),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(S.t(context, 'loginGoogle')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.surfaceLight),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      try {
                        await context.read<AuthProvider>().signInWithGoogle();
                      } on AuthException catch (e) {
                        if (!mounted) return;
                        setState(() => _error = e.message);
                      } catch (_) {
                        if (!mounted) return;
                        setState(() => _error = S.t(context, 'loginError'));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${S.t(context, 'noAccount')} ', style: const TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: Text(S.t(context, 'register'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = S.t(context, 'enterEmailPassword'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().signInWithPassword(email, password);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _mapLoginError(context, e));
    } catch (e) {
      if (mounted) setState(() => _error = S.t(context, 'loginError'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapLoginError(BuildContext context, AuthException e) {
    final code = e.code?.toLowerCase();
    final msg = e.message.toLowerCase();
    if (code == 'email_not_confirmed' || msg.contains('email not confirmed')) {
      return S.t(context, 'loginErrorEmailNotConfirmed');
    }
    if (code == 'email_provider_disabled' || msg.contains('email signups are disabled')) {
      return S.t(context, 'loginErrorInvalidCredentials');
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid login') ||
        code == 'invalid_credentials') {
      return S.t(context, 'loginErrorInvalidCredentials');
    }
    return S.t(context, 'loginError');
  }

  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(S.t(ctx, 'resetPassword')),
        content: TextField(
          controller: resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: S.t(ctx, 'resetPasswordHint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(S.t(ctx, 'cancel'))),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              final dialogNav = Navigator.of(ctx);
              final auth = ctx.read<AuthProvider>();
              final sentLabel = S.t(ctx, 'resetPasswordSent');
              final errorLabel = S.t(ctx, 'resetPasswordError');
              try {
                await auth.resetPassword(resetEmailController.text.trim());
                if (!ctx.mounted) return;
                dialogNav.pop();
                messenger.showSnackBar(SnackBar(content: Text(sentLabel)));
              } catch (e) {
                if (!ctx.mounted) return;
                messenger.showSnackBar(SnackBar(content: Text(errorLabel)));
              }
            },
            child: Text(S.t(ctx, 'sendLink')),
          ),
        ],
      ),
    ).whenComplete(resetEmailController.dispose);
  }
}
