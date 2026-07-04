class EnvConfig {
  EnvConfig._();

  static const String medicalAppsBaseUrl = String.fromEnvironment(
    'MEDICAL_APPS_URL',
    defaultValue: 'https://hemedicalapps.com/api',
  );

  static const String platomBaseUrl = String.fromEnvironment(
    'PLATOM_URL',
    defaultValue: 'https://clinic.platomedical.com/api/hemedclinic',
  );

  static const String wordpressBaseUrl = String.fromEnvironment(
    'WORDPRESS_URL',
    defaultValue: 'https://hemedicalclinic.com/wp-json/wp/v2',
  );

  static bool get isMock =>
      medicalAppsBaseUrl.contains('localhost') ||
      medicalAppsBaseUrl.contains('127.0.0.1');
}
