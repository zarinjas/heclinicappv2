import 'package:flutter/material.dart';

class HeroBanner {
  final int id;
  final String imageUrl;
  final String title;
  final String? linkUrl;
  final int sortOrder;

  const HeroBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.linkUrl,
    required this.sortOrder,
  });

  factory HeroBanner.fromJson(Map<String, dynamic> json) {
    return HeroBanner(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image'] as String? ?? '',
      title: json['title'] as String? ?? '',
      linkUrl: json['link_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': imageUrl,
    'title': title,
    'link_url': linkUrl,
    'sort_order': sortOrder,
  };

  static const fallbackList = <HeroBanner>[
    HeroBanner(
      id: 1,
      imageUrl: '',
      title: 'Book your annual\nhealth check today',
      linkUrl: null,
      sortOrder: 1,
    ),
    HeroBanner(
      id: 2,
      imageUrl: '',
      title: 'Telehealth consultation\nin minutes',
      linkUrl: null,
      sortOrder: 2,
    ),
    HeroBanner(
      id: 3,
      imageUrl: '',
      title: 'Earn points on every\nclinic visit',
      linkUrl: null,
      sortOrder: 3,
    ),
  ];

  String get subtitle {
    switch (id) {
      case 1:
        return 'Comprehensive screening from RM 199';
      case 2:
        return 'Connect with a doctor from home';
      case 3:
        return 'Redeem for discounts and rewards';
      default:
        return '';
    }
  }

  String get cta {
    switch (id) {
      case 1:
        return 'Book Now';
      case 2:
        return 'Start Now';
      case 3:
        return 'Learn More';
      default:
        return 'Learn More';
    }
  }

  List<Color> get gradient {
    switch (id % 5) {
      case 1:
        return const [Color(0xFF131C3C), Color(0xFF3B8DFF)];
      case 2:
        return const [Color(0xFF2868F5), Color(0xFF27F5A3)];
      case 3:
        return const [Color(0xFF1D2B5F), Color(0xFFF5A623)];
      case 4:
        return const [Color(0xFF3B8DFF), Color(0xFF2868F5)];
      default:
        return const [Color(0xFF131C3C), Color(0xFF3B8DFF)];
    }
  }
}
