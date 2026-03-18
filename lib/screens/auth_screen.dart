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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Zaloguj się')),
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
                const Text('Zaloguj się do SoberSteps',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Hasło',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                        : const Text('Zaloguj się'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => _showResetPasswordDialog(),
                    child: const Text('Zapomniałeś hasła?', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 48),
              ],
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
      setState(() => _error = 'Wpisz email i hasło');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().signInWithPassword(email, password);
    } catch (e) {
      if (mounted) setState(() => _error = 'Błąd logowania. Sprawdź email i hasło.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resetuj hasło'),
        content: TextField(
          controller: resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Wpisz email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AuthProvider>().resetPassword(resetEmailController.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link do resetowania hasła wysłany na email')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Błąd. Sprawdź email.')),
                  );
                }
              }
            },
            child: const Text('Wyślij link'),
          ),
        ],
      ),
    );
  }
}
