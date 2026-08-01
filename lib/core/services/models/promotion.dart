import 'package:flutter/material.dart';

class Promotion {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? ctaText;
  final String? ctaLink;
  final String? promoCode;
  final int sortOrder;

  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.ctaText,
    this.ctaLink,
    this.promoCode,
    required this.sortOrder,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image'] as String?,
      ctaText: json['cta_text'] as String?,
      ctaLink: json['cta_link'] as String?,
      promoCode: json['promo_code'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image': imageUrl,
    'cta_text': ctaText,
    'cta_link': ctaLink,
    'promo_code': promoCode,
    'sort_order': sortOrder,
  };

  List<Color> get placeholderGradient {
    final colors = [
      const [Color(0xFFF5A623), Color(0xFFF54636)],
      const [Color(0xFF2868F5), Color(0xFF27F5A3)],
      const [Color(0xFF3B8DFF), Color(0xFF2868F5)],
      const [Color(0xFF27F5A3), Color(0xFF131C3C)],
    ];
    return colors[id % colors.length];
  }

  static const fallbackList = <Promotion>[
    Promotion(
      id: 1,
      title: 'Pakej Kesihatan Asas',
      description: 'Pemeriksaan fizikal lengkap, ujian darah, ujian air kencing, dan konsultasi doktor.',
      ctaText: 'RM 99',
      ctaLink: null,
      promoCode: 'BASIC99',
      sortOrder: 1,
    ),
    Promotion(
      id: 2,
      title: 'Pakej Kesihatan Premium',
      description: 'Pemeriksaan komprehensif termasuk ECG, X-Ray dada, ujian fungsi hati & buah pinggang.',
      ctaText: 'RM 299',
      ctaLink: null,
      promoCode: 'PREMIUM299',
      sortOrder: 2,
    ),
    Promotion(
      id: 3,
      title: 'Pakej Vaksinasi Dewasa',
      description: 'Vaksinasi Influenza, Hepatitis B, Tetanus sekali dengan konsultasi doktor.',
      ctaText: 'RM 199',
      ctaLink: null,
      promoCode: 'VAKSIN199',
      sortOrder: 3,
    ),
    Promotion(
      id: 4,
      title: 'Saringan Kesihatan Wanita',
      description: 'Pap smear, ultrasound pelvis, pemeriksaan payudara. Pengesanan awal menyelamatkan nyawa.',
      ctaText: 'RM 249',
      ctaLink: null,
      promoCode: 'WANITA249',
      sortOrder: 4,
    ),
  ];
}
