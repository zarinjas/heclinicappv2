import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
  List<String> _categories = [];
  String _selectedCategory = '';

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
      await service.refreshCategories();

      if (mounted) {
        setState(() {
          _articles = service.articles;
          _categories = service.remoteCategories;
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
          _categories = ArticleService.instance.categories;
        });
      }
    }
  }

  List<Article> get _filtered {
    if (_selectedCategory.isEmpty) return _articles;
    return _articles
        .where((a) =>
            a.category != null && a.category!.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
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
        itemCount: (_categories.length > 1 ? 1 : 0) + _filtered.length,
        itemBuilder: (context, index) {
          if (_categories.length > 1 && index == 0) {
            return _buildCategoryChips();
          }
          final article = _filtered[index - (_categories.length > 1 ? 1 : 0)];
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
                '/articleDetail',
                queryParameters: {'articleSlug': article.slug},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    final labels = ['All', ..._categories];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space8),
          itemBuilder: (context, i) {
            final isSelected = (i == 0 && _selectedCategory.isEmpty) ||
                (i > 0 && _categories[i - 1].toLowerCase() == _selectedCategory.toLowerCase());
            return ChoiceChip(
              label: Text(labels[i]),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = i == 0 ? '' : _categories[i - 1];
                });
              },
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : textColor,
              ),
              selectedColor: AppColors.accent,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              side: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }
}
