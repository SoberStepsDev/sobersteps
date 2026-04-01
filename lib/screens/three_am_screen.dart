import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../providers/three_am_provider.dart';
import '../providers/auth_provider.dart';
import '../services/soundscape_service.dart';
import '../services/tts_service.dart';
import '../services/breathing_instructions_service.dart';
import '../l10n/strings.dart';

class ThreeAmScreen extends StatefulWidget {
  const ThreeAmScreen({super.key});

  @override
  State<ThreeAmScreen> createState() => _ThreeAmScreenState();
}

class _ThreeAmScreenState extends State<ThreeAmScreen> {
  final _soundscape = SoundscapeService();
  final AudioPlayer _breathPlayer = AudioPlayer();
  Timer? _instructionTimer;
  Completer<void>? _playCompleter;

  bool _ritualActive = false;
  bool _ritualEnding = false;
  bool _showInstructionOverlay = false;
  List<String> _instructions = [];
  int _instructionIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ThreeAmProvider>().loadPosts();
    _soundscape.play('white_noise');
  }

  @override
  void dispose() {
    _instructionTimer?.cancel();
    _ritualEnding = true;
    unawaited(_breathPlayer.stop());
    final c = _playCompleter;
    if (c != null && !c.isCompleted) {
      c.complete();
    }
    _playCompleter = null;
    _breathPlayer.dispose();
    _soundscape.stop();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _playBreathAssetOnce() async {
    _playCompleter = Completer<void>();
    final c = _playCompleter!;
    late final StreamSubscription<void> sub;
    sub = _breathPlayer.onPlayerComplete.listen((_) {
      sub.cancel();
      if (!c.isCompleted) c.complete();
    });
    try {
      await _breathPlayer.stop();
      await _breathPlayer.play(AssetSource('audio/three_am/breath_guide.mp3'));
      await c.future.timeout(const Duration(minutes: 30));
    } finally {
      await sub.cancel();
      _playCompleter = null;
    }
  }

  void _startInstructionCarousel() {
    _instructionTimer?.cancel();
    if (_instructions.isEmpty) return;
    _instructionIndex = 0;
    _instructionTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_showInstructionOverlay) return;
      setState(() {
        _instructionIndex = (_instructionIndex + 1) % _instructions.length;
      });
    });
  }

  void _stopInstructionCarousel() {
    _instructionTimer?.cancel();
    _instructionTimer = null;
  }

  Future<void> _runStrugglingRitual(ThreeAmProvider provider) async {
    if (_ritualActive) return;
    setState(() => _ritualActive = true);
    HapticFeedback.lightImpact();
    final locale = Localizations.localeOf(context);
    final fut = BreathingInstructionsService.fetchForLocale(locale);
    await _submitStruggling(provider);
    if (!mounted) return;

    await _soundscape.stop();
    TtsService().stop();

    try {
      await _playBreathAssetOnce();
      if (!mounted || _ritualEnding) return;

      _instructions = await fut;
      if (!mounted) return;

      setState(() {
        _showInstructionOverlay = true;
        _instructionIndex = 0;
      });
      _startInstructionCarousel();

      await _playBreathAssetOnce();
      if (!mounted) return;

      _stopInstructionCarousel();
      setState(() => _showInstructionOverlay = false);

      while (mounted && !_ritualEnding) {
        await Future.delayed(const Duration(seconds: 30));
        if (!mounted || _ritualEnding) break;
        await _playBreathAssetOnce();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.t(context, 'holdOn'))),
        );
      }
    } finally {
      _stopInstructionCarousel();
      if (mounted) {
        setState(() {
          _ritualActive = false;
          _showInstructionOverlay = false;
        });
        _ritualEnding = false;
        await _breathPlayer.stop();
        await _soundscape.play('white_noise');
      }
    }
  }

  void _endRitual() {
    setState(() => _ritualEnding = true);
    _breathPlayer.stop();
    final c = _playCompleter;
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreeAmProvider>();
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'threeAmWall'))),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSamhsaBanner(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${provider.resolvedCount} ${S.t(context, 'peopleGotThrough3am')}',
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
                                  S.t(context, 'iGotThrough'),
                                  style: TextStyle(color: AppColors.success, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (isLoggedIn && !_ritualActive) _buildBottomActions(provider),
              if (isLoggedIn && _ritualActive)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textSecondary,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        onPressed: _endRitual,
                        child: Text(S.t(context, 'threeAmRitualStop')),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_showInstructionOverlay && _instructions.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    _instructions[_instructionIndex.clamp(0, _instructions.length - 1)],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.45),
                  ),
                ),
              ),
            ),
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
        child: Text(
          S.t(context, 'samhsaCrisis'),
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
                  _ritualEnding = false;
                  _runStrugglingRitual(provider);
                },
                child: Text(S.t(context, 'iStruggling')),
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
                child: Text(S.t(context, 'iGotThrough')),
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
        SnackBar(content: Text(S.t(context, 'holdOn'))),
      );
    }
  }

  Future<void> _resolveDialog(ThreeAmProvider provider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(S.t(context, 'youMadeIt')),
        content: TextField(
          controller: controller,
          maxLength: AppConstants.maxOutcomeLength,
          maxLines: 3,
          decoration: InputDecoration(hintText: S.t(context, 'howDoYouFeelNow')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(S.t(context, 'cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(S.t(context, 'save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.t(context, 'congrats'))));
    await provider.loadPosts();
  }
}
