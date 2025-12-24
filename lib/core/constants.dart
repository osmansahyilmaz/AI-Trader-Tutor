class AppConstants {
  // These should be replaced with the actual values from the Supabase dashboard
  // or injected via --dart-define during build for security.
  // For MVP local dev, we can keep placeholders or ask user to update them.
  
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_ID.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String defaultAssetClass = String.fromEnvironment(
    'DEFAULT_ASSET_CLASS',
    defaultValue: 'crypto',
  );

  static const String defaultTimeframe = String.fromEnvironment(
    'DEFAULT_TIMEFRAME',
    defaultValue: '1h',
  );
}
