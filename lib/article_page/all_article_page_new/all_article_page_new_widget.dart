import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'all_article_page_new_model.dart';
export 'all_article_page_new_model.dart';

class AllArticlePageNewWidget extends StatefulWidget {
  const AllArticlePageNewWidget({super.key});

  static String routeName = 'allArticlePageNew';
  static String routePath = '/allArticlePageNew';

  @override
  State<AllArticlePageNewWidget> createState() =>
      _AllArticlePageNewWidgetState();
}

class _AllArticlePageNewWidgetState extends State<AllArticlePageNewWidget> {
  late AllArticlePageNewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _hasError = false;
  List<_CmsArticleItem> _articles = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllArticlePageNewModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadArticles());
  }

  Future<void> _loadArticles({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await GetCmsArticlesCall.call(limit: 10, page: page);
      if (mounted) {
        if (response.succeeded) {
          final json = response.jsonBody;
          final titles = GetCmsArticlesCall.title(json) ?? [];
          final excerpts = GetCmsArticlesCall.excerpt(json) ?? [];
          final images = GetCmsArticlesCall.featuredImage(json) ?? [];
          final slugs = GetCmsArticlesCall.slug(json) ?? [];
          final categories = GetCmsArticlesCall.category(json) ?? [];
          final authorNames = GetCmsArticlesCall.authorName(json) ?? [];
          final publishedAts = GetCmsArticlesCall.publishedAt(json) ?? [];
          final total = GetCmsArticlesCall.total(json) ?? 0;
          final currentPage = GetCmsArticlesCall.currentPage(json) ?? 1;
          final lastPage = GetCmsArticlesCall.lastPage(json) ?? 1;

          final items = <_CmsArticleItem>[];
          for (int i = 0; i < titles.length; i++) {
            items.add(_CmsArticleItem(
              title: titles[i],
              excerpt: i < excerpts.length ? _stripHtml(excerpts[i]) : '',
              imageUrl: i < images.length ? images[i] : '',
              slug: i < slugs.length ? slugs[i] : '',
              category: i < categories.length ? categories[i] : null,
              authorName: i < authorNames.length ? authorNames[i] : null,
              publishedAt: i < publishedAts.length ? publishedAts[i] : null,
            ));
          }

          setState(() {
            if (page == 1) {
              _articles = items;
            } else {
              _articles.addAll(items);
            }
            _currentPage = currentPage;
            _lastPage = lastPage;
            _isLoading = false;
            _isLoadingMore = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _hasError = true;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = true;
        });
      }
    }
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Health Articles',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: SkeletonCard(height: 300.0),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: ErrorStateWidget(
          onRetry: () => _loadArticles(),
        ),
      );
    }

    if (_articles.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'No articles yet',
        subtitle: 'Check back soon for health tips and updates',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.pixels >=
                scrollNotification.metrics.maxScrollExtent - 200 &&
            _currentPage < _lastPage &&
            !_isLoadingMore) {
          _loadArticles(page: _currentPage + 1);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: SkeletonCard(height: 200.0),
            );
          }
          final article = _articles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _buildArticleCard(article),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(_CmsArticleItem article) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          ArticleDetailPageWidget.routeName,
          queryParameters: {
            'title': serializeParam(article.title, ParamType.String),
            'imageUrl': serializeParam(article.imageUrl, ParamType.String),
            'articleSlug': serializeParam(article.slug, ParamType.String),
            'authorName': serializeParam(article.authorName, ParamType.String),
            'publishedAt': serializeParam(article.publishedAt, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [AppShadows.low],
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200.0,
              width: double.infinity,
              color: AppColors.divider,
              child: article.imageUrl.isNotEmpty
                  ? Image.network(
                      article.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.article_outlined,
                        size: 48.0,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.article_outlined,
                      size: 48.0,
                      color: AppColors.textSecondary,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        article.category!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (article.excerpt.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      article.excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (article.authorName != null || article.publishedAt != null) ...[
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        if (article.authorName != null)
                          Text(
                            article.authorName!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (article.authorName != null && article.publishedAt != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text('·',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        if (article.publishedAt != null)
                          Text(
                            article.publishedAt!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CmsArticleItem {
  final String title;
  final String excerpt;
  final String imageUrl;
  final String slug;
  final String? category;
  final String? authorName;
  final String? publishedAt;

  _CmsArticleItem({
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.slug,
    this.category,
    this.authorName,
    this.publishedAt,
  });
}
