import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/article_card.dart';

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  static const _articles = [
    _ArticleData(
      placeholderGradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
      title: '10 habits for a healthier heart',
      excerpt: 'Small daily changes...',
      author: 'Dr. Sarah Lim',
      date: '4 min read',
      categoryLabel: 'Wellness',
    ),
    _ArticleData(
      placeholderGradient: [Color(0xFFF5A623), Color(0xFFF54636)],
      title: 'Mediterranean diet, simplified',
      excerpt: 'A practical starter guide...',
      author: 'Chef Aina Yusof',
      date: '6 min read',
      categoryLabel: 'Nutrition',
    ),
    _ArticleData(
      placeholderGradient: [Color(0xFF2868F5), Color(0xFF131C3C)],
      title: 'Sleep and stress: the loop',
      excerpt: 'Why poor sleep amplifies anxiety...',
      author: 'Dr. Kavita Menon',
      date: '5 min read',
      categoryLabel: 'Mental Health',
    ),
    _ArticleData(
      placeholderGradient: [Color(0xFF27F5A3), Color(0xFF131C3C)],
      title: 'Understanding blood pressure',
      excerpt: 'What the numbers mean...',
      author: 'Dr. Ahmad Rizal',
      date: '3 min read',
      categoryLabel: 'Heart',
    ),
    _ArticleData(
      placeholderGradient: [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
      title: 'Diabetes prevention tips',
      excerpt: 'Simple lifestyle changes...',
      author: 'Dr. Sarah Lim',
      date: '7 min read',
      categoryLabel: 'Wellness',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Health Tips'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final a = _articles[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _articles.length - 1 ? AppSpacing.space16 : 0,
            ),
            child: ArticleCard(
              imageUrl: '',
              placeholderGradient: a.placeholderGradient,
              title: a.title,
              excerpt: a.excerpt,
              author: a.author,
              date: a.date,
              categoryLabel: a.categoryLabel,
              onTap: () => Navigator.pushNamed(context, '/article-detail'),
            ),
          );
        },
      ),
    );
  }
}

class _ArticleData {
  final List<Color> placeholderGradient;
  final String title;
  final String excerpt;
  final String author;
  final String date;
  final String categoryLabel;

  const _ArticleData({
    required this.placeholderGradient,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.date,
    required this.categoryLabel,
  });
}
