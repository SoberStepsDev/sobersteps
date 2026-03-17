import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/theme.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dailyCheckin = true;
  bool _milestoneReminder = true;
  bool _streakWarning = true;
  bool _letterDelivery = true;
  bool _communityUpdates = false;
  bool _nightReminder = false;
  int _reminderHour = 21;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _dailyCheckin = prefs.getBool('notif_daily_checkin') ?? true;
        _milestoneReminder = prefs.getBool('notif_milestone') ?? true;
        _streakWarning = prefs.getBool('notif_streak') ?? true;
        _letterDelivery = prefs.getBool('notif_letter') ?? true;
        _communityUpdates = prefs.getBool('notif_community') ?? false;
        _nightReminder = prefs.getBool('notif_night') ?? false;
        _reminderHour = prefs.getInt('checkin_reminder_hour') ?? 21;
      });
    } catch (_) {}
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Powiadomienia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Przypomnienia'),
          _buildSwitch('Codzienny check-in', 'Przypomnienie o godzinie $_reminderHour:00', _dailyCheckin, (v) {
            setState(() => _dailyCheckin = v);
            _save('notif_daily_checkin', v);
          }),
          _buildTimeSelector(),
          _buildSwitch('Ostrzeżenie o streaku', 'Gdy brak check-inu godzinę po przypomnieniu', _streakWarning, (v) {
            setState(() => _streakWarning = v);
            _save('notif_streak', v);
          }),
          _buildSwitch('Nocne przypomnienie', 'O 22:30, jeśli nie było check-inu', _nightReminder, (v) {
            setState(() => _nightReminder = v);
            _save('notif_night', v);
          }),
          const SizedBox(height: 16),
          const _SectionHeader('Milestones i listy'),
          _buildSwitch('Milestone (dzień wcześniej)', '\"Jutro: X dni. Jeden z tych dni które pamiętasz.\"', _milestoneReminder, (v) {
            setState(() => _milestoneReminder = v);
            _save('notif_milestone', v);
          }),
          _buildSwitch('Dostarczenie listu', 'Powiadomienie gdy list z przeszłości dotrze', _letterDelivery, (v) {
            setState(() => _letterDelivery = v);
            _save('notif_letter', v);
          }),
          const SizedBox(height: 16),
          const _SectionHeader('Społeczność'),
          _buildSwitch('Aktualizacje społeczności', 'Nowe posty i polubienia', _communityUpdates, (v) {
            setState(() => _communityUpdates = v);
            _save('notif_community', v);
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await NotificationService().requestPermission();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uprawnienia do powiadomień zaktualizowane')),
                  );
                }
              },
              child: const Text('Włącz/odśwież uprawnienia systemowe'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: Row(
        children: [
          const Text('Godzina przypomnienia: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: _reminderHour, minute: 0),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)),
                  child: child!,
                ),
              );
              if (time != null) {
                setState(() => _reminderHour = time.hour);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('checkin_reminder_hour', time.hour);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
              child: Text('$_reminderHour:00', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }
}
