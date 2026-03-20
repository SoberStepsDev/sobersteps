import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/karma_provider.dart';
import '../providers/purchase_provider.dart';
import 'paywall_screen.dart';
import '../services/analytics_service.dart';
import '../services/marketing_bridge.dart';
import '../l10n/strings.dart';

/// Philosophy applied: evening reflection as curiosity, not obligation
class KarmaMirrorScreen extends StatefulWidget {
  const KarmaMirrorScreen({super.key});

  @override
  State<KarmaMirrorScreen> createState() => _KarmaMirrorScreenState();
}

class _KarmaMirrorScreenState extends State<KarmaMirrorScreen> {
  final _controller = TextEditingController();
  bool _saved = false;
  bool _isSaving = false;
  bool _routedPaywall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureProKarma());
    AnalyticsService().track('karma_mirror_opened');
  }

  void _ensureProKarma() {
    if (!mounted || _routedPaywall) return;
    if (!context.read<PurchaseProvider>().isPro) {
      _routedPaywall = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen(trigger: 'karma_mirror')),
      );
      return;
    }
    context.read<KarmaProvider>().loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.t(context, 'karmaWriteFirst'))),
      );
      return;
    }
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      await context.read<KarmaProvider>().saveAnswer(text);
      if (!mounted) return;
      MarketingBridge().sendSignal('karma_answered');
      setState(() => _saved = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.t(context, 'karmaError'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final karma = context.watch<KarmaProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.t(context, 'karmaMirror')),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: _saved ? _buildThankYou() : _buildQuestion(karma),
      ),
    );
  }

  Widget _buildQuestion(KarmaProvider karma) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            S.t(context, 'eveningQuestion'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            karma.todayQuestion,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: S.t(context, 'karmaHint'),
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(S.t(context, 'karmaLeave')),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
          const SizedBox(height: 16),
          if (karma.entries.isNotEmpty)
            TextButton(
              onPressed: () => _showHistory(karma),
              child: Text(
                '${S.t(context, 'karmaLookBack')} (${karma.entries.length})',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 64)
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            /// Philosophy applied: gratitude without exaggeration
            Text(
              S.t(context, 'karmaThanks'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            const SizedBox(height: 12),
            Text(
              S.t(context, 'karma80Goodnight'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }

  void _showHistory(KarmaProvider karma) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: karma.entries.length,
        itemBuilder: (_, i) {
          final entry = karma.entries[i];
          return FutureBuilder<String>(
            future: karma.decryptAnswer(entry.answerEncrypted ?? ''),
            builder: (_, snap) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.timestamp.toString().substring(0, 10),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snap.data ?? '…',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
