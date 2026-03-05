import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/sobriety_provider.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _emailController = TextEditingController();
  final _analytics = AnalyticsService();
  int _currentStep = 0;
  String? _substanceType;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _analytics.track('onboarding_step_complete', {'step': _currentStep + 1});
    if (_currentStep < 4) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    _analytics.track('onboarding_complete', {'substance_type': _substanceType});
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final sobriety = context.watch<SobrietyProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(sobriety),
                  _buildStep2(),
                  _buildStep3(sobriety),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= _currentStep ? AppColors.primary : AppColors.surfaceLight,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(SobrietyProvider sobriety) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${sobriety.daysSober}',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              letterSpacing: -4,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
          const Text('Days', style: TextStyle(fontSize: 24, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Icon(Icons.local_fire_department, size: 64, color: AppColors.gold)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms, color: AppColors.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 48),
          const Text('Your journey starts now',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                sobriety.setSobrietyStartDate(DateTime.now());
                _nextPage();
              },
              child: const Text('Zacznij liczyć dni'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final substances = [
      ('alcohol', 'Alkohol', Icons.local_bar),
      ('drugs', 'Narkotyki', Icons.medication),
      ('other', 'Inne', Icons.more_horiz),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Co chcesz zostawić za sobą?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          ...substances.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: _SubstanceCard(
                    label: s.$2,
                    icon: s.$3,
                    selected: _substanceType == s.$1,
                    onTap: () async {
                      setState(() => _substanceType = s.$1);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('substance_type', s.$1);
                      _nextPage();
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStep3(SobrietyProvider sobriety) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Kiedy był Twój ostatni dzień?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Text(
            '${sobriety.daysSober} dni',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: AppColors.gold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Wybierz datę'),
              onPressed: () async {
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
                if (date != null) {
                  sobriety.setSobrietyStartDate(date);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          TextButton(onPressed: _nextPage, child: const Text('Dalej →', style: TextStyle(color: AppColors.primary, fontSize: 18))),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mail_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text('Wyślemy Ci list od siebie za 30 dni',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Twój email'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  await context.read<AuthProvider>().insertEmailLead(email);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_email', email);
                }
                _nextPage();
              },
              child: const Text('Kontynuuj'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: _nextPage, child: const Text('Pomiń', style: TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active, size: 64, color: AppColors.gold),
          const SizedBox(height: 24),
          const Text('Powiadomimy Cię 1 dzień przed każdym milestone\'m.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await NotificationService().requestPermission();
                _nextPage();
              },
              child: const Text('Tak, powiadamiaj'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _nextPage,
            child: const Text('Może później', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _SubstanceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SubstanceCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.surfaceLight, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
