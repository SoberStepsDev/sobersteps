import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../l10n/strings.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final a = _p1.text;
    final b = _p2.text;
    if (a.length < 6) {
      setState(() => _error = S.t(context, 'passwordMin'));
      return;
    }
    if (a != b) {
      setState(() => _error = S.t(context, 'passwordsMismatch'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().updatePassword(a);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (_) {
      if (mounted) setState(() => _error = S.t(context, 'setPasswordError'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.needsEmailPasswordSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'setPasswordTitle'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(S.t(context, 'setPasswordIntro'), style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 24),
              TextField(
                controller: _p1,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: S.t(context, 'registerPasswordHint'),
                  errorText: _error,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _p2,
                obscureText: _obscure,
                decoration: InputDecoration(hintText: S.t(context, 'registerConfirmHint')),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(S.t(context, 'setPasswordSubmit')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
