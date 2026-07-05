class EnvConfig {
  EnvConfig._();

  static const String medicalAppsBaseUrl = String.fromEnvironment(
    'MEDICAL_APPS_URL',
    defaultValue: 'https://hemedicalapps.com/api',
  );

  static const String platomBaseUrl = String.fromEnvironment(
    'PLATOM_URL',
    defaultValue: 'https://heclinic.cyberoket.cloud/api/v2/plato',
  );

  static const String laravelBaseUrl = String.fromEnvironment(
    'LARAVEL_API_URL',
    defaultValue: 'https://heclinic.cyberoket.cloud/api',
  );

  static const String wordpressBaseUrl = String.fromEnvironment(
    'WORDPRESS_URL',
    defaultValue: 'https://hemedicalclinic.com/wp-json/wp/v2',
  );

  static bool get isMock =>
      medicalAppsBaseUrl.contains('localhost') ||
      medicalAppsBaseUrl.contains('127.0.0.1');
}
