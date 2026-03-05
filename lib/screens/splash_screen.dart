import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/sobriety_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final sobriety = context.read<SobrietyProvider>();
    await sobriety.loadFromLocal();

    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;
    if (!onboarded) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, size: 80, color: AppColors.gold),
            const SizedBox(height: 24),
            Text('SoberSteps', style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
