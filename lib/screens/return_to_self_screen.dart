import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../core/philosophy_core.dart';
import '../l10n/strings.dart';
import '../models/return_to_self.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/return_to_self_provider.dart';
import 'paywall_screen.dart';
import '../services/analytics_service.dart';

/// Philosophy applied: 30-day path as curiosity journey, not challenge
class ReturnToSelfScreen extends StatefulWidget {
  const ReturnToSelfScreen({super.key});

  @override
  State<ReturnToSelfScreen> createState() => _ReturnToSelfScreenState();
}

class _ReturnToSelfScreenState extends State<ReturnToSelfScreen> {
  bool _routedPaywall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureProReturnToSelf());
    AnalyticsService().track('return_to_self_opened');
  }

  void _ensureProReturnToSelf() {
    if (!mounted || _routedPaywall) return;
    if (!context.read<AuthProvider>().isLoggedIn) return;
    if (!context.read<PurchaseProvider>().isPro) {
      _routedPaywall = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen(trigger: 'return_to_self')),
      );
      return;
    }
    context.read<ReturnToSelfProvider>().loadProgress();
  }

  static const _phases = [
    {
      'type': ReturnToSelfType.awareness,
      'label': 'Awareness',
      'days': '1–7',
      'icon': Icons.visibility_outlined,
      'desc': 'Zaczynasz zauważać siebie bez oceniania. Obserwujesz myśli, emocje, nawyki – jak świadek, nie sędzia.',
    },
    {
      'type': ReturnToSelfType.distance,
      'label': 'Distance',
      'days': '8–14',
      'icon': Icons.zoom_out_map,
      'desc': 'Uczysz się robić krok w tył od reaktywności. Przestrzeń między bodźcem a reakcją to Twoja nowa siła.',
    },
    {
      'type': ReturnToSelfType.repair,
      'label': 'Repair',
      'days': '15–21',
      'icon': Icons.healing_outlined,
      'desc': 'Wracasz do relacji – ze sobą i z innymi. Małe gesty naprawy budują coś trwałego.',
    },
    {
      'type': ReturnToSelfType.integration,
      'label': 'Integration',
      'days': '22–30',
      'icon': Icons.merge_type,
      'desc': 'To, czego się nauczyłeś, staje się częścią Ciebie. Nie próbujesz już "być lepszym" – po prostu jesteś sobą.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    if (!isLoggedIn) return _buildLoginGate(context);

    final provider = context.watch<ReturnToSelfProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.t(context, 'returnToSelf')),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: provider.loading
            ? Center(
                child: Text(
                  PhilosophyCore.loadingMessages[0],
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildIntro(),
                  const SizedBox(height: 24),
                  if (provider.streak != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: AppColors.gold, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              PhilosophyCore.streakMessage(provider.streak!.streakDays),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 24),
                  ],
                  ...List.generate(_phases.length, (i) {
                    final phase = _phases[i];
                    final type = phase['type'] as ReturnToSelfType;
                    final completed = provider.progress
                        .where((p) => p.type == type && p.completed)
                        .length;
                    final total = type == ReturnToSelfType.integration ? 9 : 7;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: completed == total
                              ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(phase['icon'] as IconData, color: AppColors.primary, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  phase['label'] as String,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Dni ${phase['days']}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? completed / total : 0,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation(
                                  completed == total ? AppColors.gold : AppColors.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$completed / $total',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            if (phase['desc'] != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                phase['desc'] as String,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(
                            duration: 500.ms,
                            delay: Duration(milliseconds: i * 100),
                          ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    'Narzędzia',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _ToolCard(
                    icon: Icons.auto_awesome,
                    label: 'Karma Mirror',
                    desc: 'Wieczorne pytanie refleksyjne. Jeden raz dziennie – piszesz szczerą odpowiedź, zostajesz z nią.',
                    onTap: () => Navigator.pushNamed(context, '/karma-mirror'),
                  ),
                  const SizedBox(height: 10),
                  _ToolCard(
                    icon: Icons.psychology_outlined,
                    label: 'Naomi',
                    desc: 'AI coach, który pyta – nigdy nie ocenia. Rotujące pytania z czterech obszarów: współczucie, ciekawość, ciało, przyszłe ja.',
                    onTap: () => Navigator.pushNamed(context, '/naomi'),
                  ),
                  const SizedBox(height: 10),
                  _ToolCard(
                    icon: Icons.format_quote_rounded,
                    label: 'Wall of Strength',
                    desc: 'Anonimowa tablica słów od ludzi na tej samej drodze. Zostaw coś – może jutro ktoś tego potrzebuje.',
                    onTap: () => Navigator.pushNamed(context, '/wall-of-strength'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.self_improvement, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                S.t(context, 'rtsWhatIs'),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            S.t(context, 'rtsIntro'),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 10),
          Text(
            S.t(context, 'rtsDailyTask'),
            style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  /// Philosophy applied: zaproszenie do zalogowania zamiast imperatywu
  Widget _buildLoginGate(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'returnToSelf')), backgroundColor: AppColors.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(S.t(context, 'loginToUse'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  child: Text(S.t(context, 'login')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _ToolCard({required this.icon, required this.label, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
