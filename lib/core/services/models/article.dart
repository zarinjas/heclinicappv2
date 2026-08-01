import 'package:flutter/material.dart';

class Article {
  final int id;
  final String title;
  final String slug;
  final String body;
  final String excerpt;
  final String? featuredImage;
  final String? category;
  final String? authorName;
  final String? publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.body,
    required this.excerpt,
    this.featuredImage,
    this.category,
    this.authorName,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      body: json['body'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      featuredImage: json['featured_image'] as String?,
      category: json['category'] as String?,
      authorName: json['author_name'] as String?,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'body': body,
    'excerpt': excerpt,
    'featured_image': featuredImage,
    'category': category,
    'author_name': authorName,
    'published_at': publishedAt,
  };

  String get dateDisplay {
    if (publishedAt == null || publishedAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(publishedAt!);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return publishedAt!;
    }
  }

  String get initials {
    final parts = (authorName ?? '').trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  List<Color> get placeholderGradient {
    final colors = [
      const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
      const [Color(0xFFF5A623), Color(0xFFF54636)],
      const [Color(0xFF2868F5), Color(0xFF131C3C)],
      const [Color(0xFF27F5A3), Color(0xFF2868F5)],
      const [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
    ];
    return colors[id % colors.length];
  }

  static const fallbackList = <Article>[
    Article(
      id: 1,
      title: '10 habits for a healthier heart',
      slug: 'healthier-heart',
      body: '<p>Small daily changes that protect your cardiovascular system.</p>',
      excerpt: 'Small daily changes that protect your cardiovascular system.',
      category: 'Wellness',
      authorName: 'Dr. Sarah Lim',
      publishedAt: '2026-06-15 08:00:00',
    ),
    Article(
      id: 2,
      title: 'Mediterranean diet, simplified',
      slug: 'mediterranean-diet',
      body: '<p>A practical starter guide for busy adults living in KL.</p>',
      excerpt: 'A practical starter guide for busy adults living in KL.',
      category: 'Nutrition',
      authorName: 'Chef Aina Yusof',
      publishedAt: '2026-06-10 10:00:00',
    ),
    Article(
      id: 3,
      title: 'Sleep and stress: the loop',
      slug: 'sleep-stress',
      body: '<p>Why poor sleep amplifies anxiety and how to break the cycle.</p>',
      excerpt: 'Why poor sleep amplifies anxiety and how to break the cycle.',
      category: 'Mental Health',
      authorName: 'Dr. Kavita Menon',
      publishedAt: '2026-06-05 09:00:00',
    ),
    Article(
      id: 4,
      title: '5 Tips Kesihatan Jantung Yang Perlu Anda Tahu',
      slug: 'tips-kesihatan-jantung',
      body: '<p>Jantung adalah organ paling penting dalam badan. Ketahui 5 cara mudah untuk menjaga kesihatan jantung...</p>',
      excerpt: 'Jantung adalah organ paling penting dalam badan. Ketahui 5 cara mudah untuk menjaga kesihatan jantung...',
      category: 'Health Tips',
      authorName: 'Dr. Ahmad Rizal',
      publishedAt: '2026-06-15 08:00:00',
    ),
    Article(
      id: 5,
      title: 'Panduan Lengkap Pemeriksaan Kesihatan Tahunan',
      slug: 'pemeriksaan-tahunan',
      body: '<p>Pemeriksaan kesihatan secara berkala dapat mengesan penyakit lebih awal.</p>',
      excerpt: 'Pemeriksaan kesihatan secara berkala dapat mengesan penyakit lebih awal. Baca panduan lengkap di sini...',
      category: 'Health Tips',
      authorName: 'Dr. Siti Nurhaliza',
      publishedAt: '2026-06-10 10:00:00',
    ),
  ];

  static Article? fallbackBySlug(String slug) {
    final lower = slug.toLowerCase();
    for (final a in fallbackList) {
      if (a.slug.toLowerCase() == lower) return a;
    }
    return null;
  }
}
