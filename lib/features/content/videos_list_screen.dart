import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
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
  final List<_VideoData> _videos = [];

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
      _videos.clear();
      _videos.addAll(_generateMockVideos());
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

  List<_VideoData> _generateMockVideos() {
    return [
      _VideoData(
        title: 'Cara Cuci Tangan Dengan Betul',
        author: '@heclinic_my',
        thumbnailUrl: 'https://via.placeholder.com/320x180/3B8DFF/FFFFFF?text=Cuci+Tangan',
        tiktokUrl: 'https://www.tiktok.com',
      ),
      _VideoData(
        title: '5 Senaman Ringkas Di Pejabat',
        author: '@dr_ahmad_rizal',
        thumbnailUrl: 'https://via.placeholder.com/320x180/27F5A3/131C3C?text=Senaman+Pejabat',
        tiktokUrl: 'https://www.tiktok.com',
      ),
      _VideoData(
        title: 'Makanan Super Untuk Imuniti',
        author: '@heclinic_my',
        thumbnailUrl: 'https://via.placeholder.com/320x180/F5A623/131C3C?text=Makanan+Imuniti',
        tiktokUrl: 'https://www.tiktok.com',
      ),
      _VideoData(
        title: 'Kenali Simptom Awal Diabetes',
        author: '@dr_siti_haliza',
        thumbnailUrl: 'https://via.placeholder.com/320x180/F54636/FFFFFF?text=Diabetes',
        tiktokUrl: 'https://www.tiktok.com',
      ),
      _VideoData(
        title: 'Tips Tidur Berkualiti Malam Ini',
        author: '@heclinic_my',
        thumbnailUrl: 'https://via.placeholder.com/320x180/8B7380/FFFFFF?text=Tidur+Berkualiti',
        tiktokUrl: 'https://www.tiktok.com',
      ),
      _VideoData(
        title: 'Pemeriksaan Kesihatan Percuma',
        author: '@heclinic_my',
        thumbnailUrl: 'https://via.placeholder.com/320x180/3B8DFF/FFFFFF?text=Pemeriksaan+Sihat',
        tiktokUrl: 'https://www.tiktok.com',
      ),
    ];
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
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
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
      child: AppEmptyState.noVideos(),
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

    if (_hasError) {
      return AppErrorState(
        title: 'Could not load videos',
        subtitle: _errorMessage,
        onRetry: _loadInitialData,
      );
    }

    if (_videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.space12,
          mainAxisSpacing: AppSpacing.space16,
          childAspectRatio: 0.7,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return VideoCard(
            thumbnailUrl: video.thumbnailUrl,
            title: video.title,
            author: video.author,
            onTap: () => _openVideo(video.tiktokUrl),
          );
        },
      ),
    );
  }
}

class _VideoData {
  final String title;
  final String author;
  final String thumbnailUrl;
  final String tiktokUrl;

  _VideoData({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.tiktokUrl,
  });
}
