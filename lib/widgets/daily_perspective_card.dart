import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';
import '../l10n/strings.dart';

class DailyPerspectiveCard extends StatelessWidget {
  const DailyPerspectiveCard({super.key, required this.daysSober});

  final int daysSober;

  static const _keys = [
    'perspectiveDaily1',
    'perspectiveDaily2',
    'perspectiveDaily3',
    'perspectiveDaily4',
    'perspectiveDaily5',
  ];

  @override
  Widget build(BuildContext context) {
    final idx = daysSober.abs() % _keys.length;
    final text = S.t(context, _keys[idx]);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => HapticFeedback.lightImpact(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.t(context, 'perspectiveDailyTitle'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(fontSize: 14, height: 1.35, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
