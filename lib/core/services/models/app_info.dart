class AppInfo {
  final String appName;
  final String appShortName;
  final String tagline;
  final String? logoUrl;
  final String appDescription;
  final String appVersion;
  final String companyName;
  final String supportEmail;
  final String phone;
  final String website;
  final String address;
  final List<String> operatingHours;

  const AppInfo({
    required this.appName,
    required this.appShortName,
    required this.tagline,
    this.logoUrl,
    required this.appDescription,
    required this.appVersion,
    required this.companyName,
    required this.supportEmail,
    required this.phone,
    required this.website,
    required this.address,
    required this.operatingHours,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      appName: json['app_name'] as String? ?? 'He Medical Clinic',
      appShortName: json['app_short_name'] as String? ?? 'HE',
      tagline: json['tagline'] as String? ?? 'Your Health, Simplified',
      logoUrl: json['logo_url'] as String?,
      appDescription: json['app_description'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '',
      companyName: json['company_name'] as String? ?? 'He Medical Clinic',
      supportEmail: json['support_email'] as String? ?? 'info@heclinic.com',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      address: json['address'] as String? ?? '',
      operatingHours: (json['operating_hours'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'app_name': appName,
    'app_short_name': appShortName,
    'tagline': tagline,
    'logo_url': logoUrl,
    'app_description': appDescription,
    'app_version': appVersion,
    'company_name': companyName,
    'support_email': supportEmail,
    'phone': phone,
    'website': website,
    'address': address,
    'operating_hours': operatingHours,
  };

  static const fallback = AppInfo(
    appName: 'He Medical Clinic',
    appShortName: 'HE',
    tagline: 'Your Health, Simplified',
    logoUrl: null,
    appDescription: '',
    appVersion: '',
    companyName: 'He Medical Clinic',
    supportEmail: 'info@heclinic.com',
    phone: '',
    website: '',
    address: '',
    operatingHours: [],
  );
}
