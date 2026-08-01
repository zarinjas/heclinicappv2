import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingSlide {
  final int id;
  final String title;
  final String subtitle;
  final String gradientStartHex;
  final String gradientEndHex;
  final int sortOrder;

  const OnboardingSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradientStartHex,
    required this.gradientEndHex,
    required this.sortOrder,
  });

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) {
    return OnboardingSlide(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      gradientStartHex: json['gradient_start'] as String? ?? '#3B8DFF',
      gradientEndHex: json['gradient_end'] as String? ?? '#27F5A3',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'gradient_start': gradientStartHex,
    'gradient_end': gradientEndHex,
    'sort_order': sortOrder,
  };

  Color get gradientStart => _parseHex(gradientStartHex);
  Color get gradientEnd => _parseHex(gradientEndHex);

  static Color _parseHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    if (h.length == 8) return Color(int.parse(h, radix: 16));
    return const Color(0xFF3B8DFF);
  }

  static const fallbackList = <OnboardingSlide>[
    OnboardingSlide(
      id: 1, title: 'Your Health, Simplified',
      subtitle: 'Book appointments and track your health in one place',
      gradientStartHex: '#3B8DFF', gradientEndHex: '#27F5A3', sortOrder: 1,
    ),
    OnboardingSlide(
      id: 2, title: 'Book in Minutes',
      subtitle: 'See real available slots and connect with your doctor instantly',
      gradientStartHex: '#131C3C', gradientEndHex: '#1D2B5F', sortOrder: 2,
    ),
    OnboardingSlide(
      id: 3, title: 'Stay in the Loop',
      subtitle: 'Get instant updates on your appointments and health records',
      gradientStartHex: '#2868F5', gradientEndHex: '#3B8DFF', sortOrder: 3,
    ),
  ];
}
