class AppConfig {
  static const String appName = 'Ubantu';
  static const String appVersion = '1.0.0';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://orpilmyjifanjwpxxmdi.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-key',
  );

  static const bool confirmEmailEnabled = bool.fromEnvironment(
    'CONFIRM_EMAIL_ENABLED',
    defaultValue: true,
  );

  static const String ubEmailDomain = 'student.ub.ac.id';

  static bool isUbEmail(String email) {
    return email.toLowerCase().endsWith('@$ubEmailDomain');
  }
}
