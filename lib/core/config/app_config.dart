class AppConfig {
  static const String appName = 'Ubantu';
  static const String appVersion = '1.0.0';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wbazgdawlakoufkottwm.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndiYXpnZGF3bGFrb3Vma290dHdtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2ODA4MDAsImV4cCI6MjEwODI1NjgwMH0.cBaf-L_QXlBMz_dEQw93LLLbaJmz1cWtmOEcUEFcyao',
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
