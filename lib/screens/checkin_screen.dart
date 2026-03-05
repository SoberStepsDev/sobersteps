import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/journal_provider.dart';
import '../constants/app_constants.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _mood = 3;
  double _craving = 0;
  final Set<String> _triggers = {};
  final _noteController = TextEditingController();
  bool _saving = false;

  static const _moodEmojis = ['😔', '😕', '😐', '🙂', '😄'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Check-in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jak się dziś czujesz?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildMoodPicker(),
              const SizedBox(height: 32),
              const Text('Poziom głodu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _buildCravingSlider(),
              const SizedBox(height: 32),
              const Text('Triggery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildTriggerChips(),
              const SizedBox(height: 32),
              TextField(
                controller: _noteController,
                maxLength: AppConstants.maxNoteLength,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Za co jesteś dziś wdzięczny?'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Zapisz check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final selected = _mood == i + 1;
        return GestureDetector(
          onTap: () => setState(() => _mood = i + 1),
          child: AnimatedScale(
            scale: selected ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _moodEmojis[i],
              style: TextStyle(fontSize: 40, color: selected ? null : Colors.white.withValues(alpha: 0.5)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCravingSlider() {
    final color = Color.lerp(AppColors.success, AppColors.error, _craving / 10)!;
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: AppColors.surfaceLight,
            trackHeight: 6,
          ),
          child: Slider(
            value: _craving,
            min: 0,
            max: 10,
            divisions: 10,
            label: _craving.round().toString(),
            onChanged: (v) => setState(() => _craving = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0 — brak', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text('10 — ekstremalny', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildTriggerChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.defaultTriggers.map((t) {
        final selected = _triggers.contains(t);
        return FilterChip(
          label: Text(t),
          selected: selected,
          selectedColor: AppColors.primary.withValues(alpha: 0.3),
          checkmarkColor: AppColors.primary,
          backgroundColor: AppColors.surfaceLight,
          labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary),
          onSelected: (v) {
            setState(() {
              if (v) {
                _triggers.add(t);
              } else {
                _triggers.remove(t);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final journal = context.read<JournalProvider>();
    final result = await journal.saveCheckin(
      mood: _mood,
      cravingLevel: _craving.round(),
      triggers: _triggers.toList(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    setState(() => _saving = false);

    if (!mounted) return;
    if (result == 'offline') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zapisano lokalnie — zsynchronizujemy gdy będzie internet')));
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      return;
    }

    _showReaction();
  }

  void _showReaction() {
    final note = _noteController.text.toLowerCase();
    final gratitudeWords = ['wdzięczny', 'grateful', 'thankful', 'dziękuję', 'dziekuje'];
    final hasGratitude = gratitudeWords.any((w) => note.contains(w));
    final consecutive = context.read<JournalProvider>().consecutiveCheckins;

    String message;
    IconData icon;
    Color color;

    if (_mood <= 2) {
      message = 'That was a hard day. I\'m here with you.';
      icon = Icons.local_fire_department;
      color = AppColors.gold;
    } else if (_craving > 7) {
      message = 'The wave will pass. Breathe with me.';
      icon = Icons.waves;
      color = AppColors.primary;
    } else if (_triggers.contains('loneliness')) {
      message = 'You\'re not alone. Many of us walked this road.';
      icon = Icons.local_fire_department;
      color = AppColors.gold;
    } else if (_mood >= 4 && _craving < 4) {
      message = 'This day is YOURS.';
      icon = Icons.celebration;
      color = AppColors.gold;
    } else if (hasGratitude) {
      message = 'Beautiful. These things build your strength.';
      icon = Icons.auto_awesome;
      color = AppColors.gold;
    } else if (consecutive == 3) {
      message = '3 days in a row. This is how habits form.';
      icon = Icons.auto_awesome;
      color = AppColors.primary;
    } else {
      message = 'Check-in saved. One step at a time.';
      icon = Icons.check_circle;
      color = AppColors.success;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color).animate().scale(begin: const Offset(0.3, 0.3), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
