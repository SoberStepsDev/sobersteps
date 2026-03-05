import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/app_constants.dart';
import 'app/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/sobriety_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/milestone_provider.dart';
import 'providers/community_provider.dart';
import 'providers/future_letter_provider.dart';
import 'providers/three_am_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/premium_welcome_screen.dart';
import 'screens/three_am_screen.dart';
import 'screens/craving_surf_screen.dart';
import 'screens/milestones_screen.dart';
import 'screens/future_letter_write_screen.dart';
import 'screens/future_letter_list_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/savings_health_screen.dart';
import 'screens/trigger_tracker_screen.dart';
import 'screens/lessons_screen.dart';
import 'screens/meetings_screen.dart';
import 'screens/accountability_screen.dart';
import 'screens/notifications_screen.dart';
import 'services/purchase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await PurchaseService().init();
  await NotificationService().init();

  runApp(const SoberStepsApp());
}

class SoberStepsApp extends StatelessWidget {
  const SoberStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SobrietyProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => FutureLetterProvider()),
        ChangeNotifierProvider(create: (_) => ThreeAmProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()..init()),
      ],
      child: MaterialApp(
        title: 'SoberSteps',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/auth': (_) => const AuthScreen(),
          '/home': (_) => const HomeScreen(),
          '/checkin': (_) => const CheckinScreen(),
          '/paywall': (_) => const PaywallScreen(),
          '/premium-welcome': (_) => const PremiumWelcomeScreen(),
          '/three-am': (_) => const ThreeAmScreen(),
          '/craving-surf': (_) => const CravingSurfScreen(),
          '/milestones': (_) => const MilestonesScreen(),
          '/future-letter-write': (_) => const FutureLetterWriteScreen(),
          '/future-letter-list': (_) => const FutureLetterListScreen(),
          '/community': (_) => const CommunityScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/register': (_) => const RegisterScreen(),
          '/terms': (_) => const TermsScreen(),
          '/privacy': (_) => const PrivacyScreen(),
          '/savings': (_) => const SavingsHealthScreen(),
          '/triggers': (_) => const TriggerTrackerScreen(),
          '/lessons': (_) => const LessonsScreen(),
          '/meetings': (_) => const MeetingsScreen(),
          '/accountability': (_) => const AccountabilityScreen(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
