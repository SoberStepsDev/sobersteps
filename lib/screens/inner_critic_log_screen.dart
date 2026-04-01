import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/theme.dart';
import '../l10n/strings.dart';

class InnerCriticLogScreen extends StatefulWidget {
  const InnerCriticLogScreen({super.key});

  @override
  State<InnerCriticLogScreen> createState() => _InnerCriticLogScreenState();
}

class _InnerCriticLogScreenState extends State<InnerCriticLogScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _rows = [];
      });
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('inner_critic_log')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);
      setState(() {
        _rows = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e, s) {
      debugPrint('[InnerCriticLogScreen] _load: $e\n$s');
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client.from('inner_critic_log').insert({
        'user_id': user.id,
        'content': text.length > 500 ? text.substring(0, 500) : text,
      });
      _controller.clear();
      await _load();
    } catch (e, s) {
      debugPrint('[InnerCriticLogScreen] _save: $e\n$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'innerCriticTitle'))),
      body: user == null
          ? Center(child: Text(S.t(context, 'login'), style: const TextStyle(color: AppColors.textSecondary)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    maxLength: 500,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: S.t(context, 'innerCriticHint'),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _save, child: Text(S.t(context, 'save'))),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _rows.length,
                          itemBuilder: (_, i) {
                            final r = _rows[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    r['content'] as String? ?? '',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
