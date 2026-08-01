import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/article_service.dart';
import '../../core/services/cms_api.dart';
import '../../core/services/models/article.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/article_card.dart';
import '../../core/widgets/html_content_view.dart';
import '../../core/widgets/section_header.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, this.articleTitle, this.articleSlug});

  static const String routeName = '/articleDetail';

  final String? articleTitle;
  final String? articleSlug;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  Article? _article;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      Article? article;
      if (widget.articleSlug != null && widget.articleSlug!.isNotEmpty) {
        article = await CmsApi.fetchArticleBySlug(widget.articleSlug!);
      }
      article ??= ArticleService.instance.articles.isNotEmpty
          ? ArticleService.instance.articles.first
          : Article.fallbackList.first;

      if (mounted) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
          _article = Article.fallbackList.first;
        });
      }
    }
  }

  void _shareArticle() {
    if (_article == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${_article!.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 240, color: shimmerColor),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity, height: 24,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                Container(
                  width: 200, height: 14,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                for (int i = 0; i < 6; i++) ...[
                  Container(
                    width: double.infinity, height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Article',
        onBack: () {},
        trailing: IconButton(
          onPressed: _article != null ? _shareArticle : null,
          icon: Icon(
            Icons.share_outlined,
            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          ),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError && _article == null) {
      return AppErrorState(
        title: 'Could not load article',
        subtitle: _errorMessage,
        onRetry: _loadArticle,
      );
    }

    final article = _article!;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bodyTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final imageUrl = article.featuredImage ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              child: Image.network(
                imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: isDark ? AppColors.surfaceDark : AppColors.divider,
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: article.placeholderGradient,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.category != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space8,
                        vertical: AppSpacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                      child: Text(
                        article.category!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                Text(
                  article.title,
                  style: AppTextStyles.heading2.copyWith(color: titleColor),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  '${article.authorName ?? ''}${article.dateDisplay.isNotEmpty ? ' • ${article.dateDisplay}' : ''}',
                  style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(height: AppSpacing.space16),
                HtmlContentView(
                  html: article.body,
                  textColor: bodyTextColor,
                ),
              ],
            ),
          ),
          _buildSuggestedArticles(isDark),
          const SizedBox(height: AppSpacing.space24),
        ],
      ),
    );
  }

  Widget _buildSuggestedArticles(bool isDark) {
    if (_article == null) return const SizedBox.shrink();

    final current = _article!;
    final suggested = ArticleService.instance.articles
        .where((a) => a.slug != current.slug)
        .toList();
    suggested.sort((a, b) {
      final aMatch = a.category != null &&
          a.category!.toLowerCase() == (current.category ?? '').toLowerCase();
      final bMatch = b.category != null &&
          b.category!.toLowerCase() == (current.category ?? '').toLowerCase();
      if (aMatch != bMatch) return aMatch ? -1 : 1;
      return 0;
    });
    final items = suggested.take(6).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Suggested for you',
            onSeeAll: () => context.pushNamed('/articlesList'),
          ),
          const SizedBox(height: AppSpacing.space12),
          SizedBox(
            height: 296,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space12),
              itemBuilder: (_, i) {
                final a = items[i];
                return SizedBox(
                  width: 220,
                  child: ArticleCard(
                    imageUrl: a.featuredImage ?? '',
                    placeholderGradient: a.placeholderGradient,
                    title: a.title,
                    excerpt: a.excerpt,
                    author: a.authorName ?? '',
                    date: a.dateDisplay,
                    categoryLabel: a.category,
                    onTap: () => context.pushNamed(
                      '/articleDetail',
                      queryParameters: {'articleSlug': a.slug},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
