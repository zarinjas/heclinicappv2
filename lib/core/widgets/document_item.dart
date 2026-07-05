import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';
import 'app_card.dart';
import 'app_skeleton.dart';

enum DocumentFileType { pdf, image, other }

class DocumentItem extends StatelessWidget {
  final String name;
  final DocumentFileType fileType;
  final String typeLabel;
  final String uploadedAt;
  final int sizeBytes;
  final VoidCallback? onTap;

  const DocumentItem({
    super.key,
    required this.name,
    required this.fileType,
    required this.typeLabel,
    required this.uploadedAt,
    this.sizeBytes = 0,
    this.onTap,
  });

  IconData get _icon {
    switch (fileType) {
      case DocumentFileType.pdf:
        return Icons.picture_as_pdf;
      case DocumentFileType.image:
        return Icons.image;
      case DocumentFileType.other:
        return Icons.insert_drive_file;
    }
  }

  String get _formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space12),
      child: Row(
        children: [
          _LeadingIcon(isDark: isDark),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  typeLabel,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  '$uploadedAt · $_formattedSize',
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _LeadingIcon({required bool isDark}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
      child: Icon(
        _icon,
        color: AppColors.accent,
        size: 20,
      ),
    );
  }
}

class DocumentItemSkeleton extends StatelessWidget {
  const DocumentItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.space12),
      child: Row(
        children: [
          const _SkeletonCircle(),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonBar(widthFraction: 0.7, height: 16),
                SizedBox(height: AppSpacing.space8),
                _SkeletonBar(widthFraction: 0.4, height: 12),
                SizedBox(height: AppSpacing.space4),
                _SkeletonBar(widthFraction: 0.6, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          const _SkeletonBar(widthFraction: 1.0, height: 14, width: 16),
        ],
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double widthFraction;
  final double height;
  final double? width;

  const _SkeletonBar({this.widthFraction = 1.0, this.height = 12, this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(AppRadius.radiusXS),
      ),
    );
    if (width != null) {
      return SizedBox(width: width, child: bar);
    }
    return FractionallySizedBox(widthFactor: widthFraction, child: bar);
  }
}
