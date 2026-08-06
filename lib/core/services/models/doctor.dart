import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String? qualifications;
  final String? bio;
  final String? photoUrl;
  final bool isVisibleInApp;
  final int? branchId;
  final String? branchName;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.qualifications,
    this.bio,
    this.photoUrl,
    this.isVisibleInApp = true,
    this.branchId,
    this.branchName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      qualifications: json['qualifications'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photo'] as String?,
      isVisibleInApp: json['is_visible_in_app'] as bool? ?? true,
      branchId: _parseIntOrNull(json['branch_id']),
      branchName: json['branch_name'] as String?,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'qualifications': qualifications,
    'bio': bio,
    'photo': photoUrl,
    'is_visible_in_app': isVisibleInApp,
    'branch_id': branchId,
    'branch_name': branchName,
  };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    final filtered = parts
        .where((p) =>
            !['dr.', 'dr', 'md'].contains(p.toLowerCase()))
        .toList();
    if (filtered.isEmpty) {
      return parts[0][0].toUpperCase();
    }
    final first = filtered.first;
    final last = filtered.length > 1 ? filtered.last : '';
    if (last.isEmpty) return first[0].toUpperCase();
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  List<Color> get avatarGradient {
    final gradients = [
      [AppColors.accent, AppColors.primary],
      [const Color(0xFF3B8DFF), const Color(0xFF27F5A3)],
      [const Color(0xFFF5A623), const Color(0xFFF54636)],
      [const Color(0xFF27F5A3), const Color(0xFF2868F5)],
      [const Color(0xFF2868F5), const Color(0xFF131C3C)],
    ];
    return gradients[id % gradients.length];
  }

  static const fallbackList = <Doctor>[
    Doctor(
      id: 1,
      name: 'Dr. Ahmad Rizal',
      specialty: 'General Practitioner',
      bio: 'Experienced GP with 15 years in family medicine.',
    ),
    Doctor(
      id: 2,
      name: 'Dr. Sarah Lim',
      specialty: 'Cardiologist',
      bio: 'Heart health specialist.',
    ),
    Doctor(
      id: 3,
      name: 'Dr. Tan Wei Ming',
      specialty: 'Dermatologist',
      bio: 'Skin and cosmetic dermatology specialist.',
    ),
    Doctor(
      id: 4,
      name: 'Dr. Wong Mei Ling',
      specialty: 'Pediatrician',
      bio: 'Dedicated to children\'s health and development.',
    ),
  ];
}
