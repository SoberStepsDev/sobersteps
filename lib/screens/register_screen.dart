import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../l10n/strings.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Tooltip(
          message: S.t(context, 'back'),
          child: Semantics(
            label: S.t(context, 'back'),
            button: true,
            child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _buildRegisterView(),
        ),
      ),
    );
  }

  Widget _buildRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Image.asset(
          'assets/images/SoberStepsLogo.png',
          height: 56,
          width: 56,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.local_fire_department_rounded, size: 56, color: AppColors.gold),
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 16),
        Text(S.t(context, 'register'),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(S.t(context, 'joinCommunity'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 32),

        // Email
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: S.t(context, 'registerEmailHint'),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: S.t(context, 'registerPasswordHint'),
            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textSecondary),
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
        const SizedBox(height: 16),

        // Confirm password
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: S.t(context, 'registerConfirmHint'),
            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textSecondary),
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
                  Text('${S.t(context, 'accept')} ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                    child: Text(S.t(context, 'termsAnd'),
                        style: TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline)),
                  ),
                  Text(' ${S.t(context, 'and')} ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                    child: Text(S.t(context, 'privacyPolicy'),
                        style: TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline)),
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
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : Text(S.t(context, 'register')),
          ),
        ),

        const SizedBox(height: 24),
        Row(children: [
          const Expanded(child: Divider(color: AppColors.surfaceLight)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(S.t(context, 'or'), style: const TextStyle(color: AppColors.textSecondary))),
          const Expanded(child: Divider(color: AppColors.surfaceLight)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: Text(S.t(context, 'continueGoogle')),
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
            Text('${S.t(context, 'haveAccount')} ', style: const TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/auth'),
              child: Text(S.t(context, 'login'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        const SizedBox(height: 32),
        Text('${S.t(context, 'contactLabel')} ${AppConstants.contactEmail}',
            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = S.t(context, 'emailInvalid'));
      return;
    }
    if (password.length < 6) {
      setState(() => _error = S.t(context, 'passwordMin'));
      return;
    }
    if (password != confirmPassword) {
      setState(() => _error = S.t(context, 'passwordsMismatch'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().signUpWithPassword(email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.t(context, 'accountCreated'))),
        );
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } catch (e) {
      if (mounted) setState(() => _error = S.t(context, 'registerError'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
