import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../providers/purchase_provider.dart';
import '../services/analytics_service.dart';

class PaywallScreen extends StatefulWidget {
  final String trigger;
  const PaywallScreen({super.key, this.trigger = 'manual'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlan = AppConstants.annualProductId;
  Timer? _fomoTimer;
  Duration _remaining = const Duration(hours: 23, minutes: 59, seconds: 59);
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    final purchase = context.read<PurchaseProvider>();
    _analytics.track('paywall_view', {'trigger': widget.trigger, 'ab_variant': purchase.abVariant});
    if (purchase.daysSinceInstall > 3) {
      _fomoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining.inSeconds > 0) {
          setState(() => _remaining -= const Duration(seconds: 1));
        }
      });
    }
  }

  @override
  void dispose() {
    _fomoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildHeadline(purchase.abVariant),
              const SizedBox(height: 24),
              ..._buildBenefitCards(),
              const SizedBox(height: 24),
              _buildSocialProof(),
              const SizedBox(height: 24),
              _buildPlanCard('Monthly', '\$6.99/mo', AppConstants.monthlyProductId, false),
              const SizedBox(height: 12),
              _buildPlanCard('Annual', '\$59.99/yr', AppConstants.annualProductId, true, badge: 'BEST VALUE', strikethrough: '\$83.88'),
              const SizedBox(height: 12),
              _buildPlanCard('Family', '\$9.99/mo', AppConstants.familyProductId, false),
              if (purchase.daysSinceInstall >= 90) ...[
                const SizedBox(height: 12),
                _buildPlanCard('Lifetime', '\$89.99', AppConstants.lifetimeProductId, false, subtitle: '234 osoby wybrały trzeźwość na zawsze'),
              ],
              if (purchase.daysSinceInstall > 3) ...[
                const SizedBox(height: 16),
                _buildFomoTimer(),
              ],
              const SizedBox(height: 24),
              _buildCtaButton(purchase),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await purchase.restore();
                  if (purchase.isPremium && mounted) Navigator.pop(context);
                },
                child: const Text('Przywróć zakupy', style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(String variant) {
    final texts = {
      'A': 'Unlock Recovery+ — Free for 7 Days',
      'B': '847 osób zaczęło dziś. Dołącz.',
      'C': 'Twój dzień 30 zasługuje na głos.',
    };
    return Text(
      texts[variant] ?? texts['A']!,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }

  List<Widget> _buildBenefitCards() {
    final benefits = [
      (Icons.mic, 'Wyobraź sobie słysząc mój głos w Dniu 90'),
      (Icons.nightlight_round, 'O 3 w nocy — 847 osób tu przeszło'),
      (Icons.mail_outline, 'Napisz list do siebie za 6 miesięcy'),
      (Icons.shield, 'Nie pozwól jednej ciężkiej nocy zniszczyć streaka'),
    ];
    return benefits.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(b.$1, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(b.$2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
              ],
            ),
          ),
        )).toList();
  }

  Widget _buildSocialProof() {
    return Text(
      'Dołącz do 12,847 osób na drodze do zdrowienia',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    );
  }

  Widget _buildPlanCard(String name, String price, String productId, bool highlighted, {String? badge, String? strikethrough, String? subtitle}) {
    final selected = _selectedPlan == productId;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = productId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? AppColors.gold : (selected ? AppColors.primary : AppColors.surfaceLight),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.background)),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (strikethrough != null) Text(strikethrough, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: highlighted ? AppColors.gold : AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFomoTimer() {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Text('Oferta trialu wygasa za $h:$m:$s', style: const TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w600));
  }

  Widget _buildCtaButton(PurchaseProvider purchase) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: AppColors.gold,
        ),
        onPressed: () async {
          final success = await purchase.purchase(_selectedPlan);
          if (success && mounted) {
            Navigator.of(context).pushReplacementNamed('/premium-welcome');
          }
        },
        child: const Text('Start Free Trial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    ).animate(onPlay: (c) => c.repeat(period: 3000.ms)).shimmer(duration: 800.ms, color: Colors.white.withValues(alpha: 0.3));
  }
}
