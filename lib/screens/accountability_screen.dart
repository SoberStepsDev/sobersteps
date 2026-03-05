import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/purchase_provider.dart';
import '../providers/auth_provider.dart';

class AccountabilityScreen extends StatelessWidget {
  const AccountabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PurchaseProvider>().isPremium;
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    if (!isPremium) return _buildPremiumGate(context);
    if (!isLoggedIn) return _buildLoginGate(context);
    return _buildMain(context);
  }

  Widget _buildPremiumGate(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Accountability Partner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_alt_rounded, size: 72, color: AppColors.gold),
              const SizedBox(height: 24),
              const Text('Accountability Partner', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              const Text(
                'Znajdź partnera na drodze do trzeźwości. Wspólny streak, codzienne check-iny, prywatny chat — tylko wy dwoje.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                child: const Column(
                  children: [
                    _FeatureRow(icon: Icons.link, text: 'Parowanie przez kod lub email'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.sync, text: 'Wspólny streak — motywacja x2'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.chat_bubble_outline, text: 'Prywatny, szyfrowany chat'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.notifications_active, text: 'Powiadomienia gdy partner zrobi check-in'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.visibility, text: 'Wspólne milestones i celebracje'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                  onPressed: () => Navigator.pushNamed(context, '/paywall'),
                  child: const Text('Odblokuj z Recovery+'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginGate(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Accountability Partner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Zaloguj się, aby używać tej funkcji', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/auth'), child: const Text('Zaloguj się')),
          ],
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Accountability Partner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_alt_rounded, size: 72, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Nie masz jeszcze partnera', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              const Text('Zaproś kogoś kodem lub znajdź partnera w społeczności.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Zaproś partnera'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funkcja parowania będzie dostępna wkrótce!')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Znajdź w społeczności'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.surfaceLight),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Matching będzie dostępny wkrótce!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
      ],
    );
  }
}
