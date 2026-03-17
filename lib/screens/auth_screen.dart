import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Zaloguj się')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _sent ? _buildSentView() : _buildLoginView(),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/SoberStepsLogo.png',
          height: 64,
          width: 64,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.lock_open_rounded, size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        const Text('Zaloguj się magicznym linkiem',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Email'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : () {
              HapticFeedback.lightImpact();
              _sendMagicLink();
            },
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Wyślij link'),
          ),
        ),
        const SizedBox(height: 24),
        const Row(children: [
          Expanded(child: Divider(color: AppColors.surfaceLight)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('lub', style: TextStyle(color: AppColors.textSecondary))),
          Expanded(child: Divider(color: AppColors.surfaceLight)),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Zaloguj przez Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceLight),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AuthProvider>().signInWithGoogle();
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, size: 26),
            label: const Text('Zaloguj przez Apple'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceLight),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AuthProvider>().signInWithApple();
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nie masz konta? ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
              child: const Text('Zarejestruj się', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 64, color: AppColors.success),
        const SizedBox(height: 24),
        const Text('Sprawdź swoją skrzynkę!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        const Text('Jeśli konto istnieje, wyślemy link.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text('Spróbuj ponownie', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signInWithOtp(email);
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _sent = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
