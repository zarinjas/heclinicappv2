import '/backend/api_requests/api_calls.dart';
import '/components/reference_modal_widget.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'article_detail_page_model.dart';
export 'article_detail_page_model.dart';

class ArticleDetailPageWidget extends StatefulWidget {
  const ArticleDetailPageWidget({
    super.key,
    this.title,
    this.content,
    this.imageUrl,
    this.referenceLabel,
    this.referenceUrl,
    this.articleSlug,
    this.authorName,
    this.publishedAt,
  });

  final String? title;
  final String? content;
  final String? imageUrl;
  final String? referenceLabel;
  final String? referenceUrl;
  final String? articleSlug;
  final String? authorName;
  final String? publishedAt;

  static String routeName = 'ArticleDetailPage';
  static String routePath = '/articleDetailPage';

  @override
  State<ArticleDetailPageWidget> createState() =>
      _ArticleDetailPageWidgetState();
}

class _ArticleDetailPageWidgetState extends State<ArticleDetailPageWidget> {
  late ArticleDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _hasError = false;
  String _title = '';
  String _body = '';
  String _imageUrl = '';
  String _authorName = '';
  String _publishedAt = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ArticleDetailPageModel());

    if (widget.articleSlug != null && widget.articleSlug!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadArticleFromCms());
    } else {
      _title = widget.title ?? '';
      _body = widget.content ?? '';
      _imageUrl = widget.imageUrl ?? '';
      _authorName = widget.authorName ?? '';
      _publishedAt = widget.publishedAt ?? '';
    }
  }

  Future<void> _loadArticleFromCms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await GetCmsArticleDetailCall.call(widget.articleSlug!);
      if (mounted) {
        if (response.succeeded) {
          final json = response.jsonBody;
          setState(() {
            _title = GetCmsArticleDetailCall.title(json) ?? widget.title ?? '';
            _body = GetCmsArticleDetailCall.body(json) ?? widget.content ?? '';
            _imageUrl = GetCmsArticleDetailCall.featuredImage(json) ?? widget.imageUrl ?? '';
            _authorName = GetCmsArticleDetailCall.authorName(json) ?? widget.authorName ?? '';
            _publishedAt = GetCmsArticleDetailCall.publishedAt(json) ?? widget.publishedAt ?? '';
            _isLoading = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
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
        floatingActionButton: (widget.referenceLabel != null && widget.referenceUrl != null)
            ? FloatingActionButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return WebViewAware(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: ReferenceModalWidget(
                              referenceLabel: widget.referenceLabel!,
                              referenceUrl: widget.referenceUrl!,
                            ),
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));
                },
                backgroundColor: AppColors.primary,
                elevation: 8.0,
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 34.0,
                ),
              )
            : null,
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
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonCard(height: 240.0),
            const SizedBox(height: 16.0),
            const SkeletonTextBlock(lineCount: 2),
            const SizedBox(height: 24.0),
            const SkeletonTextBlock(lineCount: 5),
            const SizedBox(height: 24.0),
            const SkeletonTextBlock(lineCount: 3),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: ErrorStateWidget(
          onRetry: () {
            if (widget.articleSlug != null && widget.articleSlug!.isNotEmpty) {
              _loadArticleFromCms();
            }
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              height: 240.0,
              color: AppColors.divider,
              child: Image.network(
                _imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.article_outlined,
                  size: 64.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title.isNotEmpty ? _title : (widget.title ?? 'Article'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (_authorName.isNotEmpty || _publishedAt.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      if (_authorName.isNotEmpty)
                        Text(
                          _authorName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (_authorName.isNotEmpty && _publishedAt.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('·',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      if (_publishedAt.isNotEmpty)
                        Text(
                          _publishedAt,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
                if (widget.referenceLabel != null &&
                    widget.referenceLabel!.isNotEmpty &&
                    widget.referenceUrl != null &&
                    widget.referenceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.referenceLabel!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        GestureDetector(
                          onTap: () async {
                            await launchURL(widget.referenceUrl!);
                          },
                          child: Text(
                            'Source',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20.0),
                Text(
                  _body.isNotEmpty ? _body : (widget.content ?? ''),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
