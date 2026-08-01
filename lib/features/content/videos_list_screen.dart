import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/video_service.dart';
import '../../core/services/models/video.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/video_card.dart';

class VideosListScreen extends StatefulWidget {
  const VideosListScreen({super.key});

  static const String routeName = '/videosList';

  @override
  State<VideosListScreen> createState() => _VideosListScreenState();
}

class _VideosListScreenState extends State<VideosListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Video> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = VideoService.instance;
      await service.refresh();

      if (mounted) {
        setState(() {
          _videos = service.videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
          _videos = Video.fallbackList;
        });
      }
    }
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.space16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.space12,
        mainAxisSpacing: AppSpacing.space16,
          childAspectRatio: 0.45,
        ),
        itemCount: 6,
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Container(
            width: double.infinity, height: 12,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Container(
            width: 80, height: 10,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: AppEmptyState.noVideos,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Videos',
        onBack: () {},
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError && _videos.isEmpty) {
      return AppErrorState(
        title: 'Could not load videos',
        subtitle: _errorMessage,
        onRetry: _loadVideos,
      );
    }

    if (_videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadVideos,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVideos,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.space12,
          mainAxisSpacing: AppSpacing.space16,
          childAspectRatio: 0.45,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return VideoCard(
            thumbnailUrl: video.thumbnailUrl ?? '',
            placeholderGradient: video.placeholderGradient,
            title: video.title,
            author: video.author,
            videoAspectRatio: 9 / 16,
            platformLabel: 'TikTok',
            durationLabel: '0:30',
            onTap: () => _openVideo(video.tiktokUrl),
          );
        },
      ),
    );
  }
}
