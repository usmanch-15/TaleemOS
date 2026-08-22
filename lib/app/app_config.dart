class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vgxegpdrholxqyjlehjd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_IwdRRLQ9Ibs3ms_Vh8awWg_6VXS-VU8',
  );

  static const String appName = 'TaleemOS';
}