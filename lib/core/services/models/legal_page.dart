class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class LegalPage {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalPage({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      title: json['title'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
          ?.map((e) => LegalSection.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'last_updated': lastUpdated,
    'sections': sections.map((s) => {'heading': s.heading, 'body': s.body}).toList(),
  };

  static const privacyFallback = LegalPage(
    title: 'Privacy Policy',
    lastUpdated: 'July 2026',
    sections: [
      LegalSection(heading: 'Information We Collect', body: 'We collect personal information that you provide to us when registering for an account, booking an appointment, or updating your profile. This includes your full name, NRIC number, contact details, date of birth, and medical history relevant to the care you receive at He Medical Clinic.'),
      LegalSection(heading: 'How We Use Your Information', body: 'Your information is used to manage appointments, process registrations, communicate important updates, process payments, and improve our services.'),
      LegalSection(heading: 'Data Storage & Security', body: 'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. Your data is stored securely on servers located within Malaysia.'),
      LegalSection(heading: 'Sharing Your Information', body: 'We do not sell your personal information. We may share your data with healthcare providers as necessary for your treatment, with regulatory bodies as required by law, and with service providers who assist in our operations under strict confidentiality agreements.'),
      LegalSection(heading: 'Your Rights', body: 'You have the right to access, correct, or delete your personal data. You may also withdraw consent for certain data processing activities. To exercise these rights, please contact us through the app settings.'),
      LegalSection(heading: 'Policy Updates', body: 'We may update this privacy policy from time to time. We will notify you of any significant changes through the app or via email.'),
    ],
  );

  static const termsFallback = LegalPage(
    title: 'Terms of Service',
    lastUpdated: 'July 2026',
    sections: [
      LegalSection(heading: 'Agreement', body: 'By downloading, installing, or using the He Clinic mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.'),
      LegalSection(heading: 'License', body: 'He Medical Clinic grants you a limited, non-exclusive, non-transferable license to use the application for managing your personal healthcare appointments and records. You may not modify, distribute, or create derivative works based on the application.'),
      LegalSection(heading: 'Account Responsibility', body: 'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorized use.'),
      LegalSection(heading: 'Service Changes', body: 'We reserve the right to modify or discontinue the service at any time. We are not liable for any damages arising from the use or inability to use the service.'),
      LegalSection(heading: 'Disclaimer', body: 'This service is provided as is without any warranty. To the fullest extent permitted by law, He Medical Clinic disclaims all warranties, express or implied.'),
      LegalSection(heading: 'Governing Law', body: 'These terms are governed by the laws of Malaysia. Any disputes shall be resolved in the courts of Kuala Lumpur, Malaysia.'),
    ],
  );
}
