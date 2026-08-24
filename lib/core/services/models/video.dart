import 'package:flutter/material.dart';

import '../cms_api.dart';

class Video {
  final int id;
  final String title;
  final String tiktokUrl;
  final String? thumbnailUrl;
  final String? tiktokAuthor;
  final String? publishedAt;

  const Video({
    required this.id,
    required this.title,
    required this.tiktokUrl,
    this.thumbnailUrl,
    this.tiktokAuthor,
    this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final rawThumbnail = json['thumbnail_url'] as String?;
    return Video(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      tiktokUrl: json['tiktok_url'] as String? ?? '',
      thumbnailUrl: rawThumbnail == null || rawThumbnail.isEmpty
          ? rawThumbnail
          : CmsApi.resolveMediaUrl(rawThumbnail),
      tiktokAuthor: json['tiktok_author'] as String?,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tiktok_url': tiktokUrl,
    'thumbnail_url': thumbnailUrl,
    'tiktok_author': tiktokAuthor,
    'published_at': publishedAt,
  };

  String get author => tiktokAuthor ?? '@heclinic';

  List<Color> get placeholderGradient {
    final colors = [
      const [Color(0xFF3B8DFF), Color(0xFF131C3C)],
      const [Color(0xFF27F5A3), Color(0xFF2868F5)],
      const [Color(0xFFF5A623), Color(0xFFF54636)],
      const [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
      const [Color(0xFF2868F5), Color(0xFF131C3C)],
      const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
    ];
    return colors[id % colors.length];
  }

  static const fallbackList = <Video>[
    Video(
      id: 1,
      title: 'Understanding your blood pressure numbers',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@heclinic',
      publishedAt: '2026-06-20 08:00:00',
    ),
    Video(
      id: 2,
      title: '5-minute morning stretch routine',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@heclinic',
      publishedAt: '2026-06-18 09:00:00',
    ),
    Video(
      id: 3,
      title: 'What to expect at your first visit',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@heclinic',
      publishedAt: '2026-06-15 10:00:00',
    ),
    Video(
      id: 4,
      title: 'Healthy meal prep, KL edition',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@heclinic',
      publishedAt: '2026-06-12 08:00:00',
    ),
    Video(
      id: 5,
      title: 'Cara Cuci Tangan Dengan Betul',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@heclinic_my',
      publishedAt: '2026-06-08 09:00:00',
    ),
    Video(
      id: 6,
      title: '5 Senaman Ringkas Di Pejabat',
      tiktokUrl: 'https://www.tiktok.com',
      tiktokAuthor: '@dr_ahmad_rizal',
      publishedAt: '2026-06-01 10:00:00',
    ),
  ];
}
