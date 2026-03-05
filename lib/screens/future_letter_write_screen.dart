import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../constants/app_constants.dart';
import '../providers/future_letter_provider.dart';

class FutureLetterWriteScreen extends StatefulWidget {
  const FutureLetterWriteScreen({super.key});

  @override
  State<FutureLetterWriteScreen> createState() => _FutureLetterWriteScreenState();
}

class _FutureLetterWriteScreenState extends State<FutureLetterWriteScreen> {
  final _contentController = TextEditingController();
  DateTime? _deliverAt;
  bool _saving = false;

  static const _presets = [
    ('1 miesiąc', 30),
    ('3 miesiące', 90),
    ('6 miesięcy', 180),
    ('1 rok', 365),
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('List do siebie')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Napisz do siebie z przyszłości', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              TextField(
                controller: _contentController,
                maxLength: AppConstants.maxNoteLength,
                maxLines: 8,
                decoration: const InputDecoration(hintText: 'Napisz do siebie za X czasu...'),
              ),
              const SizedBox(height: 24),
              const Text('Kiedy dostarczyć?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((p) {
                  final date = DateTime.now().add(Duration(days: p.$2));
                  final selected = _deliverAt != null &&
                      _deliverAt!.difference(date).inDays.abs() < 2;
                  return ChoiceChip(
                    label: Text(p.$1),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    backgroundColor: AppColors.surfaceLight,
                    labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary),
                    onSelected: (_) => setState(() => _deliverAt = date),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Wyślij list'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Napisz coś!')));
      return;
    }
    if (_deliverAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wybierz datę dostarczenia')));
      return;
    }
    if (AppConstants.urlRegex.hasMatch(content)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Linki są niedozwolone')));
      return;
    }

    setState(() => _saving = true);
    final result = await context.read<FutureLetterProvider>().createLetter(content, _deliverAt!);
    setState(() => _saving = false);

    if (!mounted) return;
    if (result == 'offline') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zapisano lokalnie')));
      Navigator.pop(context);
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List wysłany w przyszłość!')));
      Navigator.pop(context);
    }
  }
}
