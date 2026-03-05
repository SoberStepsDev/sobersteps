class AppConstants {
  static const bool isDevelopment = true;

  static const String supabaseUrl = 'https://kznhbcwozpjflewlzxnu.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bmhiY3dvenBqZmxld2x6eG51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMTU4NTcsImV4cCI6MjA4NzU5MTg1N30.CRgPK-BExwci8l6EHmJ3V9jH-ElABom62hejiBqyN_4';

  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  static const String monthlyProductId = 'sobersteps_monthly_699';
  static const String annualProductId = 'sobersteps_annual_5999';
  static const String familyProductId = 'sobersteps_family_999';
  static const String lifetimeProductId = 'sobersteps_lifetime_8999';

  static const List<int> milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365, 730, 1825];

  static const int maxNoteLength = 2000;
  static const int maxPostLength = 1000;
  static const int maxOutcomeLength = 500;

  static const String contactEmail = 'sobersteps@pm.me';
  static const String samhsaPhone = '1-800-662-4357';

  static final RegExp urlRegex = RegExp(r'(https?://|bit\.ly|t\.co)', caseSensitive: false);

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
