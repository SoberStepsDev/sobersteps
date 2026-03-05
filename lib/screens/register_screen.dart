import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  bool _agreedToTerms = false;
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _sent ? _buildSentView() : _buildRegisterView(),
        ),
      ),
    );
  }

  Widget _buildRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.local_fire_department_rounded, size: 56, color: AppColors.gold)
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 16),
        const Text('Zarejestruj się',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Dołącz do społeczności osób w drodze do zdrowienia',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 32),

        // Social sign-in buttons
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          label: 'Kontynuuj z Google',
          onTap: _agreedToTerms ? () => _socialSignIn('google') : null,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          icon: Icons.apple,
          label: 'Kontynuuj z Apple',
          onTap: _agreedToTerms ? () => _socialSignIn('apple') : null,
        ),

        const SizedBox(height: 24),
        const Row(children: [
          Expanded(child: Divider(color: AppColors.surfaceLight)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('lub email', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Divider(color: AppColors.surfaceLight)),
        ]),
        const SizedBox(height: 24),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Twój adres email',
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 20),

        // Terms checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                activeColor: AppColors.primary,
                side: const BorderSide(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                children: [
                  const Text('Akceptuję ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                    child: const Text('Regulamin', style: TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline)),
                  ),
                  const Text(' oraz ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                    child: const Text('Politykę Prywatności', style: TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_loading || !_agreedToTerms) ? null : _register,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.surfaceLight,
              disabledForegroundColor: AppColors.textSecondary,
            ),
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : const Text('Zarejestruj się'),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Masz już konto? ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/auth'),
              child: const Text('Zaloguj się', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        const SizedBox(height: 32),
        Text('Kontakt: sobersteps@pm.me', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.mark_email_read_rounded, size: 72, color: AppColors.success)
            .animate()
            .scale(begin: const Offset(0.3, 0.3), duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text('Sprawdź swoją skrzynkę!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Text('Wysłaliśmy link rejestracyjny na:\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => setState(() {
            _sent = false;
            _error = null;
          }),
          child: const Text('Wyślij ponownie', style: TextStyle(color: AppColors.primary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Powrót', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 26),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: onTap != null ? AppColors.textPrimary : AppColors.textSecondary,
          side: BorderSide(color: onTap != null ? AppColors.surfaceLight : AppColors.surfaceLight.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Podaj poprawny adres email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().signInWithOtp(email);
      await context.read<AuthProvider>().insertEmailLead(email);
      setState(() => _sent = true);
    } catch (_) {
      setState(() => _sent = true);
    }
    setState(() => _loading = false);
  }

  Future<void> _socialSignIn(String provider) async {
    try {
      if (provider == 'google') {
        await context.read<AuthProvider>().signInWithGoogle();
      } else {
        await context.read<AuthProvider>().signInWithApple();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd logowania: $e')));
      }
    }
  }
}
