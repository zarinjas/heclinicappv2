import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/article_card.dart';

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({super.key});

  static const String routeName = '/articlesList';

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final List<_ArticleData> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _articles.clear();
      _articles.addAll(_generateMockArticles());
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<_ArticleData> _generateMockArticles() {
    return [
      _ArticleData(
        title: '5 Tips Kesihatan Jantung Yang Perlu Anda Tahu',
        excerpt: 'Jantung adalah organ paling penting dalam badan. Ketahui 5 cara mudah untuk menjaga kesihatan jantung...',
        author: 'Dr. Ahmad Rizal',
        date: '15 Jun 2026',
        imageUrl: 'https://via.placeholder.com/400x140/3B8DFF/FFFFFF?text=Kesihatan+Jantung',
        category: 'Kesihatan',
      ),
      _ArticleData(
        title: 'Panduan Lengkap Pemeriksaan Kesihatan Tahunan',
        excerpt: 'Pemeriksaan kesihatan secara berkala dapat mengesan penyakit lebih awal. Baca panduan lengkap di sini...',
        author: 'Dr. Siti Nurhaliza',
        date: '10 Jun 2026',
        imageUrl: 'https://via.placeholder.com/400x140/27F5A3/131C3C?text=Pemeriksaan+Tahunan',
        category: 'Panduan',
      ),
      _ArticleData(
        title: 'Makanan Untuk Mengawal Tekanan Darah Tinggi',
        excerpt: 'Diet yang betul memainkan peranan penting dalam mengawal tekanan darah. Ini adalah senarai makanan yang disyorkan...',
        author: 'Dr. Ahmad Rizal',
        date: '5 Jun 2026',
        imageUrl: 'https://via.placeholder.com/400x140/F5A623/131C3C?text=Diet+Darah+Tinggi',
        category: 'Pemakanan',
      ),
      _ArticleData(
        title: 'Kepentingan Vaksinasi Untuk Dewasa',
        excerpt: 'Vaksin bukan sahaja untuk kanak-kanak. Orang dewasa juga memerlukan vaksin untuk perlindungan berterusan...',
        author: 'Dr. Mohd Farid',
        date: '1 Jun 2026',
        imageUrl: 'https://via.placeholder.com/400x140/F54636/FFFFFF?text=Vaksinasi+Dewasa',
        category: 'Vaksinasi',
      ),
      _ArticleData(
        title: 'Senaman Ringkas Di Rumah Untuk Kekal Aktif',
        excerpt: 'Tiada masa ke gym? Jangan risau. Senaman ringkas ini boleh dilakukan di rumah tanpa peralatan khas...',
        author: 'Dr. Siti Nurhaliza',
        date: '28 Mei 2026',
        imageUrl: 'https://via.placeholder.com/400x140/8B7380/FFFFFF?text=Senaman+Di+Rumah',
        category: 'Kecergasan',
      ),
    ];
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: const ArticleCardSkeleton(),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: AppEmptyState.noArticles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Health Tips',
        onBack: () {},
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Could not load articles',
        subtitle: _errorMessage,
        onRetry: _loadInitialData,
      );
    }

    if (_articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: ArticleCard(
              imageUrl: article.imageUrl,
              title: article.title,
              excerpt: article.excerpt,
              author: article.author,
              date: article.date,
              categoryLabel: article.category,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class _ArticleData {
  final String title;
  final String excerpt;
  final String author;
  final String date;
  final String imageUrl;
  final String? category;

  _ArticleData({
    required this.title,
    required this.excerpt,
    required this.author,
    required this.date,
    required this.imageUrl,
    this.category,
  });
}
