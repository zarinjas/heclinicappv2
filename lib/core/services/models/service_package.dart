import 'package:flutter/material.dart';

class ServicePackage {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;

  const ServicePackage({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image': imageUrl,
  };

  String get price {
    switch (id) {
      case 1:
        return 'RM 99';
      case 2:
        return 'RM 299';
      case 3:
        return 'RM 199';
      case 4:
        return 'RM 249';
      default:
        return 'RM ${(id * 100) + 99}';
    }
  }

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
    ),
    ServicePackage(
      id: 2,
      name: 'Pemeriksaan Kesihatan Komprehensif',
      description:
          'Termasuk ujian darah lengkap, ujian fungsi hati & buah pinggang, ECG, X-Ray dada, dan konsultasi.',
    ),
    ServicePackage(
      id: 3,
      name: 'Pakej Vaksinasi',
      description:
          'Vaksinasi Influenza, Hepatitis B, Tetanus, dan konsultasi vaksinasi.',
    ),
    ServicePackage(
      id: 4,
      name: 'Pakej Saringan Wanita',
      description:
          'Pap Smear, ultrasound pelvis, pemeriksaan payudara, dan konsultasi pakar.',
    ),
  ];
}
