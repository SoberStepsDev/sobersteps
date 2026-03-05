import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Spotkania i wsparcie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: const Text('Nie jesteś sam/sama. Tysiące spotkań odbywa się każdego dnia — stacjonarnie i online.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
            ),
            const SizedBox(height: 24),
            const Text('Znajdź spotkanie', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _MeetingCard(title: 'Anonimowi Alkoholicy (AA)', subtitle: 'Największa społeczność 12 kroków na świecie', url: 'https://www.aa.org/find-aa', icon: Icons.groups),
            _MeetingCard(title: 'Anonimowi Narkomani (NA)', subtitle: 'Wsparcie dla osób uzależnionych od narkotyków', url: 'https://www.na.org/meetingsearch/', icon: Icons.groups),
            _MeetingCard(title: 'SMART Recovery', subtitle: 'Podejście oparte na nauce i CBT. Spotkania online i stacjonarnie', url: 'https://www.smartrecovery.org/community/calendar.php', icon: Icons.psychology),
            _MeetingCard(title: 'Refuge Recovery / Recovery Dharma', subtitle: 'Buddyjskie podejście do zdrowienia. Medytacja i uważność', url: 'https://recoverydharma.org/meetings', icon: Icons.self_improvement),
            _MeetingCard(title: 'In The Rooms (Online)', subtitle: '130+ spotkań online tygodniowo. Darmowe. Bez wychodzenia z domu', url: 'https://www.intherooms.com', icon: Icons.computer),
            const SizedBox(height: 32),
            const Text('Linie kryzysowe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _PhoneCard(title: 'SAMHSA National Helpline', phone: '1-800-662-4357', subtitle: 'USA — 24/7, darmowa, poufna'),
            _PhoneCard(title: 'Telefon Zaufania', phone: '116 123', subtitle: 'Polska — wsparcie emocjonalne'),
            _PhoneCard(title: 'Pogotowie ratunkowe', phone: '112', subtitle: 'Europa — nagłe wypadki'),
            const SizedBox(height: 32),
            const Text('Wskazówki', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _tipTile('Nie musisz mówić na pierwszym spotkaniu. Wystarczy przyjść i słuchać.'),
            _tipTile('Spróbuj minimum 3 różnych grup zanim zdecydujesz, która pasuje.'),
            _tipTile('Spotkania online są tak samo wartościowe jak stacjonarne.'),
            _tipTile('Sponsor to ktoś, kto przeszedł tę drogę — poproś o pomoc.'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static Widget _tipTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5))),
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;

  const _MeetingCard({required this.title, required this.subtitle, required this.url, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PhoneCard extends StatelessWidget {
  final String title;
  final String phone;
  final String subtitle;

  const _PhoneCard({required this.title, required this.phone, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('tel:$phone')),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.crisisRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.crisisRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone, color: AppColors.crisisRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text('$phone — $subtitle', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
