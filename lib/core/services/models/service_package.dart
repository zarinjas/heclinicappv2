import 'package:flutter/material.dart';

class ServicePackage {
  final int id;
  final String name;
  final String description;
  final List<String> items;
  final String? imageUrl;
  final List<String> gallery;
  final String? whatsappNumber;

  const ServicePackage({
    required this.id,
    required this.name,
    required this.description,
    this.items = const [],
    this.imageUrl,
    this.gallery = const [],
    this.whatsappNumber,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as String?;
    final galleryRaw = json['gallery'] as List<dynamic>? ?? const [];
    final itemsRaw = json['items'] as List<dynamic>? ?? const [];

    return ServicePackage(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      items: itemsRaw
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      imageUrl: image,
      gallery: galleryRaw.whereType<String>().where((u) => u.isNotEmpty).toList(),
      whatsappNumber: json['whatsapp_number'] as String?,
    );
  }

  List<String> get galleryImages {
    final images = [
      if (imageUrl != null && imageUrl!.isNotEmpty) imageUrl!,
      ...gallery,
    ];
    return images.toSet().toList();
  }

  String get whatsapp => whatsappNumber?.isNotEmpty == true
      ? whatsappNumber!
      : '60136254528';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'items': items,
    'image': imageUrl,
    'gallery': gallery,
    'whatsapp_number': whatsappNumber,
  };

  List<Color> get placeholderGradient {
    return [
      const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
      const [Color(0xFF131C3C), Color(0xFF3B8DFF)],
      const [Color(0xFF2868F5), Color(0xFF131C3C)],
      const [Color(0xFF27F5A3), Color(0xFF2868F5)],
    ][(id - 1) % 4];
  }

  static const fallbackList = <ServicePackage>[
    ServicePackage(
      id: 1,
      name: 'Pemeriksaan Kesihatan Asas',
      description:
          'Pemeriksaan fizikal lengkap, ujian darah, ujian air kencing, dan konsultasi doktor.',
      items: [
        'Pemeriksaan fizikal lengkap',
        'Ujian darah',
        'Ujian air kencing',
        'Konsultasi doktor',
      ],
    ),
    ServicePackage(
      id: 2,
      name: 'Pemeriksaan Kesihatan Komprehensif',
      description:
          'Termasuk ujian darah lengkap, ujian fungsi hati & buah pinggang, ECG, X-Ray dada, dan konsultasi.',
      items: [
        'Ujian darah lengkap',
        'Ujian fungsi hati & buah pinggang',
        'ECG',
        'X-Ray dada',
        'Konsultasi doktor',
      ],
    ),
    ServicePackage(
      id: 3,
      name: 'Pakej Vaksinasi',
      description:
          'Vaksinasi Influenza, Hepatitis B, Tetanus, dan konsultasi vaksinasi.',
      items: [
        'Vaksin Influenza',
        'Vaksin Hepatitis B',
        'Vaksin Tetanus',
        'Konsultasi vaksinasi',
      ],
    ),
    ServicePackage(
      id: 4,
      name: 'Pakej Saringan Wanita',
      description:
          'Pap Smear, ultrasound pelvis, pemeriksaan payudara, dan konsultasi pakar.',
      items: [
        'Pap Smear',
        'Ultrasound pelvis',
        'Pemeriksaan payudara',
        'Konsultasi pakar',
      ],
    ),
  ];
}
