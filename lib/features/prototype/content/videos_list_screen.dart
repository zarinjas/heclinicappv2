import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/video_card.dart';

class VideosListScreen extends StatelessWidget {
  const VideosListScreen({super.key});

  static const _videos = [
    _VideoData(
      placeholderGradient: [Color(0xFF3B8DFF), Color(0xFF131C3C)],
      title: '5 heart health tips everyone should know',
    ),
    _VideoData(
      placeholderGradient: [Color(0xFF27F5A3), Color(0xFF2868F5)],
      title: 'What to expect at your health screening',
    ),
    _VideoData(
      placeholderGradient: [Color(0xFFF5A623), Color(0xFFF54636)],
      title: 'Quick stress relief breathing exercise',
    ),
    _VideoData(
      placeholderGradient: [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
      title: 'Understanding your blood test results',
    ),
    _VideoData(
      placeholderGradient: [Color(0xFF131C3C), Color(0xFF27F5A3)],
      title: 'Healthy meal prep in 15 minutes',
    ),
    _VideoData(
      placeholderGradient: [Color(0xFF2868F5), Color(0xFFF5A623)],
      title: 'How to read nutrition labels like a pro',
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
        title: const Text('Videos'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.45,
          crossAxisSpacing: AppSpacing.space12,
          mainAxisSpacing: AppSpacing.space12,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final v = _videos[index];
          return VideoCard(
            thumbnailUrl: '',
            placeholderGradient: v.placeholderGradient,
            title: v.title,
            author: '@heclinic',
            durationLabel: '0:30',
            videoAspectRatio: 9 / 16,
            platformLabel: 'TikTok',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening TikTok...')),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoData {
  final List<Color> placeholderGradient;
  final String title;

  const _VideoData({
    required this.placeholderGradient,
    required this.title,
  });
}
