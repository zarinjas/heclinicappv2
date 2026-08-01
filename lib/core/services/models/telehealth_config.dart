class TelehealthConfig {
  final String title;
  final String description;
  final List<String> features;
  final String whatsappNumber;
  final String price;
  final String hoursText;
  final String buttonLabel;

  const TelehealthConfig({
    required this.title,
    required this.description,
    required this.features,
    required this.whatsappNumber,
    required this.price,
    required this.hoursText,
    required this.buttonLabel,
  });

  factory TelehealthConfig.fromJson(Map<String, dynamic> json) {
    return TelehealthConfig(
      title: json['title'] as String? ?? 'Telehealth Consultation',
      description: json['description'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      whatsappNumber: json['whatsapp_number'] as String? ?? '60136254528',
      price: json['price'] as String? ?? 'RM 30 per 15-minute consultation',
      hoursText: json['hours_text'] as String? ?? 'Available Monday - Friday, 8am - 8pm',
      buttonLabel: json['button_label'] as String? ?? 'Start WhatsApp Consultation',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'features': features,
    'whatsapp_number': whatsappNumber,
    'price': price,
    'hours_text': hoursText,
    'button_label': buttonLabel,
  };

  static const fallback = TelehealthConfig(
    title: 'Telehealth Consultation',
    description: 'Speak with a doctor from the comfort of your home via video call. Our telehealth service connects you to experienced practitioners for non-emergency consultations.',
    features: [
      'Available Monday - Friday, 8am - 8pm',
      'RM 30 per 15-minute consultation',
      'Prescriptions and MC provided where appropriate',
    ],
    whatsappNumber: '60136254528',
    price: 'RM 30 per 15-minute consultation',
    hoursText: 'Available Monday - Friday, 8am - 8pm',
    buttonLabel: 'Start WhatsApp Consultation',
  );
}
