import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/sobriety_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/future_letter_provider.dart';
import '../providers/journal_provider.dart';
import '../screens/checkin_screen.dart';
import '../screens/three_am_screen.dart';
import '../screens/milestones_screen.dart';
import '../screens/community_screen.dart';
import '../screens/profile_screen.dart';
import '../models/future_letter.dart';
import '../screens/future_letter_read_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _navIndex = 0;
  Timer? _timer;
  final _screens = const [
    _HomeTab(),
    CheckinScreen(),
    MilestonesScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<SobrietyProvider>().refresh();
    });
    _initData();
  }

  Future<void> _initData() async {
    final sobriety = context.read<SobrietyProvider>();
    await sobriety.loadFromLocal();
    if (!mounted) return;
    sobriety.loadFromSupabase();
    context.read<JournalProvider>().loadEntries();
    context.read<JournalProvider>().syncPendingData();
    context.read<FutureLetterProvider>().loadLetters();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SobrietyProvider>().loadFromSupabase();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(key: ValueKey<int>(_navIndex), child: _screens[_navIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          HapticFeedback.lightImpact();
          setState(() => _navIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Milestones'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _returnToSelfEnabled = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _returnToSelfEnabled = p.getBool('return_to_self_enabled') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sobriety = context.watch<SobrietyProvider>();
    final purchase = context.watch<PurchaseProvider>();
    final letterProvider = context.watch<FutureLetterProvider>();
    final isNight = DateTime.now().hour >= 22 || DateTime.now().hour < 6;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final letter = letterProvider.pendingDelivery;
      if (letter != null) {
        letterProvider.clearPendingDelivery();
        _showLetterDialog(context, letter);
      }
    });

    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/SoberStepsLogo.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shield_rounded,
                      size: 48,
                      color: purchase.isPremium ? AppColors.streakBlue : AppColors.textSecondary,
                    ),
                  ),
                ).animate(onPlay: (c) => purchase.isPremium ? c.repeat() : null).shimmer(
                      duration: 2000.ms,
                      color: purchase.isPremium ? AppColors.streakBlue.withValues(alpha: 0.3) : Colors.transparent,
                    ),
                const SizedBox(height: 24),
                Text(
                  '${sobriety.daysSober}',
                  style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w800, letterSpacing: -4, color: AppColors.textPrimary, height: 1),
                ).animate().fadeIn(duration: 400.ms),
                Text(
                  'and ${sobriety.hoursSober} hours',
                  style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _ProgressBar(progress: sobriety.progressToNextMilestone, daysToGo: sobriety.daysToNextMilestone, nextMilestone: sobriety.nextMilestone),
                const SizedBox(height: 16),
                _SavingsCard(days: sobriety.daysSober),
                const SizedBox(height: 16),
                _QuoteCard(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Check-in Now'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pushNamed('/checkin');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SosButton(isNight: isNight),
                if (_returnToSelfEnabled) ...[  
                  const SizedBox(height: 16),
                  _ReturnToSelfCard(),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        if (isNight) Positioned.fill(child: IgnorePointer(child: Container(color: AppColors.nightOverlay))),
      ],
    );
  }

  void _showLetterDialog(BuildContext context, FutureLetter letter) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Masz list od siebie'),
        content: const Text('Otworzyć?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Później')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => FutureLetterReadScreen(letter: letter)));
            },
            child: const Text('Otwórz'),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int daysToGo;
  final int? nextMilestone;

  const _ProgressBar({required this.progress, required this.daysToGo, this.nextMilestone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nextMilestone != null ? '$daysToGo days to $nextMilestone-day milestone' : 'All milestones achieved!',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/data/quotes.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final quotes = jsonDecode(snapshot.data!) as List;
        final idx = DateTime.now().day % quotes.length;
        final q = quotes[idx];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '"${q['text']}"\n— ${q['author']}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary.withValues(alpha: 0.85),
            ),
          ),
        );
      },
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final int days;
  const _SavingsCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/savings'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.savings_rounded, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${(days * 15).toStringAsFixed(0)} zaoszczędzone', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 16)),
                  const Text('Kliknij aby zobaczyć szczegóły zdrowia', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReturnToSelfCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/return-to-self');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.self_improvement, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Return to Self', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('Twoja 30-dniowa ścieżka', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _SosButton extends StatelessWidget {
  final bool isNight;
  const _SosButton({required this.isNight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.sos_rounded),
        label: const Text('3 AM SOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isNight ? AppColors.crisisRed : AppColors.crisisRed.withValues(alpha: 0.7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThreeAmScreen()));
        },
      ),
    ).animate(onPlay: (c) => isNight ? c.repeat(reverse: true) : null).scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.04, 1.04),
          duration: 1200.ms,
        );
  }
}
