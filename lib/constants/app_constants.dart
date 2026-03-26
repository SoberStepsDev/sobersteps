class AppConstants {
  static const bool isDevelopment = false;

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://kznhbcwozpjflewlzxnu.supabase.co');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bmhiY3dvenBqZmxld2x6eG51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMTU4NTcsImV4cCI6MjA4NzU5MTg1N30.CRgPK-BExwci8l6EHmJ3V9jH-ElABom62hejiBqyN_4');

  static const String revenueCatApiKey =
      String.fromEnvironment('REVENUE_CAT_KEY', defaultValue: '');
  static const String oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: 'YOUR_ONESIGNAL_APP_ID');
  static const String elevenLabsApiKey =
      String.fromEnvironment('ELEVENLABS_API_KEY', defaultValue: '');
  /// Sentry; empty = disabled. Build: `--dart-define=SENTRY_DSN=...`
  static const String sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  /// Deep link host (Universal Links / App Links), without scheme.
  static const String deepLinkDomain =
      String.fromEnvironment('DEEP_LINK_DOMAIN', defaultValue: 'sobersteps.app');
  static const String elevenLabsVoiceId = '2Hw5QTX3wstf1sLYfhhk'; // Patryk

  /// RevenueCat dashboard entitlement id for Recovery+ / PRO access.
  static const String revenueCatEntitlementId = 'pro';

  static const String monthlyProductId = 'sobersteps_monthly_699';
  static const String annualProductId = 'sobersteps_annual_5999';
  static const String familyProductId = 'sobersteps_family_999';
  static const String lifetimeProductId = 'sobersteps_lifetime_8999';

  static const List<int> milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365, 730, 1825];

  static const int maxNoteLength = 2000;
  static const int maxPostLength = 1000;
  static const int maxOutcomeLength = 500;

  static const String contactEmail = 'sobersteps@pm.me';
  /// Deep link for auth callback; must match Android/iOS intent filters. Do not use for arbitrary URLs.
  static const String authRedirectScheme = 'com.patryk.sobersteps';
  static const String authRedirectHost = 'login-callback';
  static String get authRedirectUrl => '$authRedirectScheme://$authRedirectHost';
  static const String samhsaPhone = '1-800-662-4357';

  static final RegExp urlRegex = RegExp(r'(https?://|bit\.ly|t\.co)', caseSensitive: false);

  // --- Addiction categories (v2026 spec) ---
  static const Map<String, String> substanceTypes = {
    'alcohol': 'Alkohol',
    'marijuana_thc': 'Marihuana / THC',
    'cocaine': 'Kokaina',
    'heroin': 'Heroina',
    'crack': 'Crack',
    'methamphetamine': 'Metamfetamina',
    'opioids': 'Opioids',
    'other_substance': 'Inne / własne',
  };

  static const Map<String, String> behavioralTypes = {
    'gambling': 'Hazard',
    'sex_pornography': 'Seks i Pornografia',
    'social_media': 'Social Media / Scrolling',
    'shopping': 'Zakupy',
    'gaming': 'Gry wideo',
    'workaholism': 'Pracoholizm',
  };

  static const Map<String, String> returnToSelfTypes = {
    'self_hatred': 'Nienawiść do siebie',
    'perfectionism': 'Perfekcjonizm',
    'toxic_relationships': 'Toksyczne Relacje',
  };

  /// Return to Self types that require PRO subscription
  static const Set<String> returnToSelfProOnly = {
    'perfectionism',
    'toxic_relationships',
  };

  static const List<String> defaultTriggers = [
    'loneliness',
    'stress',
    'boredom',
    'pain',
    'other',
  ];

  static const Map<String, String> communityCategories = {
    'wins': 'Sukcesy',
    'hard': 'Trudne chwile',
    'advice': 'Rady',
    'milestones': 'Milestones',
  };
}
