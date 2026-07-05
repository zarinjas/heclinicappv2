import '/backend/api_requests/api_calls.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'all_content_media_model.dart';
export 'all_content_media_model.dart';

class AllContentMediaWidget extends StatefulWidget {
  const AllContentMediaWidget({super.key});

  static String routeName = 'allContentMedia';
  static String routePath = '/allContentMedia';

  @override
  State<AllContentMediaWidget> createState() => _AllContentMediaWidgetState();
}

class _AllContentMediaWidgetState extends State<AllContentMediaWidget> {
  late AllContentMediaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _hasError = false;
  List<_CmsVideoItem> _videos = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllContentMediaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVideos());
  }

  Future<void> _loadVideos({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await GetCmsVideosCall.call(limit: 10, page: page);
      if (mounted) {
        if (response.succeeded) {
          final json = response.jsonBody;
          final titles = GetCmsVideosCall.title(json) ?? [];
          final thumbnails = GetCmsVideosCall.thumbnailUrl(json) ?? [];
          final tiktokUrls = GetCmsVideosCall.tiktokUrl(json) ?? [];
          final authors = GetCmsVideosCall.tiktokAuthor(json) ?? [];
          final total = GetCmsVideosCall.total(json) ?? 0;
          final currentPage = GetCmsVideosCall.currentPage(json) ?? 1;
          final lastPage = GetCmsVideosCall.lastPage(json) ?? 1;

          final items = <_CmsVideoItem>[];
          for (int i = 0; i < titles.length; i++) {
            items.add(_CmsVideoItem(
              title: titles[i],
              thumbnailUrl: i < thumbnails.length ? thumbnails[i] : '',
              tiktokUrl: i < tiktokUrls.length ? tiktokUrls[i] : '',
              tiktokAuthor: i < authors.length ? authors[i] : null,
            ));
          }

          setState(() {
            if (page == 1) {
              _videos = items;
            } else {
              _videos.addAll(items);
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
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          title: Text(
            'Videos',
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.2,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => const SkeletonCard(height: 200.0),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: ErrorStateWidget(
          onRetry: () => _loadVideos(),
        ),
      );
    }

    if (_videos.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.video_library_outlined,
        title: 'No videos yet',
        subtitle: 'Check back soon for our latest videos',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.pixels >=
                scrollNotification.metrics.maxScrollExtent - 200 &&
            _currentPage < _lastPage &&
            !_isLoadingMore) {
          _loadVideos(page: _currentPage + 1);
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.2,
        ),
        itemCount: _videos.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _videos.length) {
            return const SkeletonCard(height: 200.0);
          }
          final video = _videos[index];
          return GestureDetector(
            onTap: () => launchURL(video.tiktokUrl),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                color: AppColors.divider,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: video.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.video_library_outlined,
                              size: 40.0,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : const Icon(
                            Icons.video_library_outlined,
                            size: 40.0,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.primary,
                        size: 28.0,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppRadius.lg),
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CmsVideoItem {
  final String title;
  final String thumbnailUrl;
  final String tiktokUrl;
  final String? tiktokAuthor;

  _CmsVideoItem({
    required this.title,
    required this.thumbnailUrl,
    required this.tiktokUrl,
    this.tiktokAuthor,
  });
}
