import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../l10n/strings.dart';
import 'inner_critic_log_screen.dart';
import 'daily_self_act_screen.dart';

class SelfCompassionHubScreen extends StatelessWidget {
  const SelfCompassionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.t(context, 'selfCompassionHub'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(context, Icons.psychology_outlined, S.t(context, 'scCardCritic'), S.t(context, 'scCardCriticSub'), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InnerCriticLogScreen()));
          }),
          _card(context, Icons.science_outlined, S.t(context, 'scCardExperiment'), S.t(context, 'scCardExperimentSub'), () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.t(context, 'scComingSoon'))));
          }),
          _card(context, Icons.splitscreen, S.t(context, 'scCardPerspective'), S.t(context, 'scCardPerspectiveSub'), () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.t(context, 'scPerspectiveHint'))));
          }),
          _card(context, Icons.favorite_outline, S.t(context, 'scCardActivation'), S.t(context, 'scCardActivationSub'), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySelfActScreen()));
          }),
          _card(context, Icons.filter_center_focus, S.t(context, 'scCardFilter'), S.t(context, 'scCardFilterSub'), () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.t(context, 'scFilterHint'))));
          }),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
