import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/theme.dart';
import '../l10n/strings.dart';

class DailySelfActScreen extends StatefulWidget {
  const DailySelfActScreen({super.key});

  @override
  State<DailySelfActScreen> createState() => _DailySelfActScreenState();
}

class _DailySelfActScreenState extends State<DailySelfActScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('daily_self_acts').insert({
        'user_id': user.id,
        'note': text.length > 100 ? text.substring(0, 100) : text,
      });
      _controller.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.t(context, 'saved'))));
    } catch (e, s) {
      debugPrint('[DailySelfActScreen] _save: $e\n$s');
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'dailySelfActTitle'))),
      body: user == null
          ? Center(child: Text(S.t(context, 'login'), style: const TextStyle(color: AppColors.textSecondary)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.t(context, 'dailySelfActPrompt'), style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLength: 100,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(S.t(context, 'save')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
