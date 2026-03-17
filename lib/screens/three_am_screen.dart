import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../providers/three_am_provider.dart';
import '../providers/auth_provider.dart';
import '../services/soundscape_service.dart';

class ThreeAmScreen extends StatefulWidget {
  const ThreeAmScreen({super.key});

  @override
  State<ThreeAmScreen> createState() => _ThreeAmScreenState();
}

class _ThreeAmScreenState extends State<ThreeAmScreen> {
  final _soundscape = SoundscapeService();

  @override
  void initState() {
    super.initState();
    context.read<ThreeAmProvider>().loadPosts();
    _soundscape.play('white_noise');
  }

  @override
  void dispose() {
    _soundscape.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreeAmProvider>();
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('3 AM Wall of Strength')),
      body: Column(
        children: [
          _buildSamhsaBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${provider.resolvedCount} people got through their 3 AM',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.resolvedPosts.length,
                    itemBuilder: (context, i) {
                      final post = provider.resolvedPosts[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.outcomeText != null && post.outcomeText!.isNotEmpty)
                              Text(post.outcomeText!, style: const TextStyle(color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                              'Got through it',
                              style: TextStyle(color: AppColors.success, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (isLoggedIn) _buildBottomActions(provider),
        ],
      ),
    );
  }

  Widget _buildSamhsaBanner() {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('tel:${AppConstants.samhsaPhone}')),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: AppColors.crisisRed,
        child: const Text(
          'Jeśli jesteś w kryzysie: SAMHSA 1-800-662-4357',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThreeAmProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.crisisRed, foregroundColor: AppColors.textPrimary),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _submitStruggling(provider);
                },
                child: const Text("I'm struggling"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.textPrimary),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _resolveDialog(provider);
                },
                child: const Text('I got through'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStruggling(ThreeAmProvider provider) async {
    final result = await provider.submitPost();
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trzymaj się. Jesteśmy tu z Tobą.')),
      );
    }
  }

  Future<void> _resolveDialog(ThreeAmProvider provider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Dałeś radę!'),
        content: TextField(
          controller: controller,
          maxLength: AppConstants.maxOutcomeLength,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Jak się teraz czujesz? (opcjonalnie)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    // For resolving, we'd need the user's unresolved post ID — simplified here
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gratulacje! Dałeś radę.')));
    provider.loadPosts();
  }
}
