import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/milestone_provider.dart';
import '../providers/sobriety_provider.dart';
import '../providers/purchase_provider.dart';
import '../models/milestone.dart';
import '../services/analytics_service.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MilestoneProvider>().loadMilestones();
  }

  @override
  Widget build(BuildContext context) {
    final milestoneProvider = context.watch<MilestoneProvider>();
    final sobriety = context.watch<SobrietyProvider>();
    final daysSober = sobriety.daysSober;

    if (sobriety.pendingMilestone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCelebration(sobriety.pendingMilestone!);
        sobriety.clearPendingMilestone();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Milestones')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MilestoneData.all.length,
        itemBuilder: (context, i) {
          final data = MilestoneData.all[i];
          final achieved = milestoneProvider.isAchieved(data.days) || daysSober >= data.days;
          final isNext = !achieved && (i == 0 || daysSober >= MilestoneData.all[i - 1].days);
          return _MilestoneCard(data: data, achieved: achieved, isNext: isNext, daysSober: daysSober);
        },
      ),
    );
  }

  void _showCelebration(int days) {
    final data = MilestoneData.forDays(days);
    if (data == null) return;
    final isPremium = context.read<PurchaseProvider>().isPremium;
    context.read<MilestoneProvider>().recordMilestone(days);
    AnalyticsService().track('milestone_celebrate', {'days': days});

    showDialog(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 64))
                .animate()
                .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('${data.days} Days!',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.gold)),
            const SizedBox(height: 8),
            Text(data.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
            Text(data.subMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          if (data.shareText.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Quick Share'),
              onPressed: () => Share.share(data.shareText),
            ),
          if (!isPremium)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/paywall');
              },
              child: const Text('Odblokuj Recovery+', style: TextStyle(color: AppColors.gold)),
            ),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final MilestoneData data;
  final bool achieved;
  final bool isNext;
  final int daysSober;

  const _MilestoneCard({required this.data, required this.achieved, required this.isNext, required this.daysSober});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achieved ? AppColors.gold : (isNext ? AppColors.primary : AppColors.surfaceLight),
          width: achieved ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(data.emoji, style: TextStyle(fontSize: 32, color: achieved ? null : AppColors.textPrimary.withValues(alpha: 0.3))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: achieved ? AppColors.gold : AppColors.textPrimary)),
                if (achieved)
                  const Text('Achieved!', style: TextStyle(color: AppColors.success, fontSize: 12))
                else if (isNext)
                  Text('${data.days - daysSober} days to go', style: const TextStyle(color: AppColors.primary, fontSize: 12))
                else
                  const Text('Locked', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (achieved)
            const Icon(Icons.check_circle, color: AppColors.gold)
          else if (!achieved && !isNext)
            const Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
