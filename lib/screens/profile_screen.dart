import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/sobriety_provider.dart';
import '../providers/purchase_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sobriety = context.watch<SobrietyProvider>();
    final purchase = context.watch<PurchaseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, auth, sobriety, purchase),
          const SizedBox(height: 24),
          if (!auth.isLoggedIn) _tile(context, Icons.login, 'Zaloguj się', () => Navigator.pushNamed(context, '/auth')),
          if (!auth.isLoggedIn) _tile(context, Icons.person_add, 'Zarejestruj się', () => Navigator.pushNamed(context, '/register')),
          if (!purchase.isPremium) _tile(context, Icons.star, 'Recovery+', () => Navigator.pushNamed(context, '/paywall'), color: AppColors.gold),
          const _SectionLabel('Narzędzia'),
          _tile(context, Icons.savings_rounded, 'Oszczędności i zdrowie', () => Navigator.pushNamed(context, '/savings')),
          _tile(context, Icons.bar_chart_rounded, 'Analiza wzorców', () => Navigator.pushNamed(context, '/triggers')),
          _tile(context, Icons.school_rounded, 'Mini-lekcje', () => Navigator.pushNamed(context, '/lessons')),
          _tile(context, Icons.map_rounded, 'Spotkania AA/NA/SMART', () => Navigator.pushNamed(context, '/meetings')),
          _tile(context, Icons.people_alt_rounded, 'Accountability Partner', () => Navigator.pushNamed(context, '/accountability'),
              badge: purchase.isPremium ? null : 'PRO'),
          _tile(context, Icons.mail_outline, 'Listy do siebie', () => Navigator.pushNamed(context, '/future-letter-list')),
          _tile(context, Icons.waves, 'Craving Surf', () => Navigator.pushNamed(context, '/craving-surf')),
          const _SectionLabel('Ustawienia'),
          _tile(context, Icons.calendar_today, 'Zmień datę trzeźwości', () => _showDatePicker(context, sobriety)),
          _tile(context, Icons.notifications_outlined, 'Powiadomienia', () => Navigator.pushNamed(context, '/notifications')),
          const _SectionLabel('Informacje'),
          _tile(context, Icons.description_outlined, 'Regulamin', () => Navigator.pushNamed(context, '/terms')),
          _tile(context, Icons.privacy_tip_outlined, 'Polityka prywatności', () => Navigator.pushNamed(context, '/privacy')),
          _tile(context, Icons.email_outlined, 'Kontakt: sobersteps@pm.me', () => launchUrl(Uri.parse('mailto:${AppConstants.contactEmail}'))),
          _tile(context, Icons.phone, 'SAMHSA: 1-800-662-4357', () => launchUrl(Uri.parse('tel:1-800-662-4357')), color: AppColors.crisisRed),
          if (auth.isLoggedIn) ...[
            const SizedBox(height: 16),
            _tile(context, Icons.restore, 'Przywróć zakupy', () => purchase.restore()),
            _tile(context, Icons.logout, 'Wyloguj', () async {
              await auth.signOut();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/onboarding');
            }, color: AppColors.error),
          ],
          const SizedBox(height: 32),
          const Center(child: Text('SoberSteps v1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth, SobrietyProvider sobriety, PurchaseProvider purchase) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: purchase.isPremium ? AppColors.gold : AppColors.primary,
            child: Icon(purchase.isPremium ? Icons.shield : Icons.person, size: 36, color: AppColors.background),
          ),
          const SizedBox(height: 12),
          Text(auth.user?.email ?? 'Gość', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('${sobriety.daysSober} dni trzeźwości', style: const TextStyle(color: AppColors.textSecondary)),
          if (purchase.isPremium) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text('Recovery+', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color, String? badge}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(badge, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _showDatePicker(BuildContext context, SobrietyProvider sobriety) async {
    final date = await showDatePicker(
      context: context,
      initialDate: sobriety.sobrietyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (date != null) await sobriety.setSobrietyStartDate(date);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 16),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
    );
  }
}
