import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/article_service.dart';
import '../../core/services/models/article.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
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
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = ArticleService.instance;
      await service.refresh();

      if (mounted) {
        setState(() {
          _articles = service.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
          _articles = Article.fallbackList;
        });
      }
    }
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
      child: AppEmptyState.noArticles,
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

    if (_hasError && _articles.isEmpty) {
      return AppErrorState(
        title: 'Could not load articles',
        subtitle: _errorMessage,
        onRetry: _loadArticles,
      );
    }

    if (_articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
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
              imageUrl: article.featuredImage ?? '',
              placeholderGradient: article.placeholderGradient,
              title: article.title,
              excerpt: article.excerpt,
              author: article.authorName ?? '',
              date: article.dateDisplay,
              categoryLabel: article.category,
              onTap: () => context.pushNamed(
                'ArticleDetailPageWidget',
                queryParameters: {'slug': article.slug},
              ),
            ),
          );
        },
      ),
    );
  }
}
