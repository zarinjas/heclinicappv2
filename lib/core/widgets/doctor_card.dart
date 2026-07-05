import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_chip.dart';

enum DoctorCardVariant { horizontal, vertical }

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    this.photoUrl,
    required this.name,
    required this.specialty,
    this.rating,
    this.isAvailable = false,
    this.isSelected = false,
    this.variant = DoctorCardVariant.horizontal,
    this.onTap,
  });

  final String? photoUrl;
  final String name;
  final String specialty;
  final double? rating;
  final bool isAvailable;
  final bool isSelected;
  final DoctorCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      DoctorCardVariant.horizontal => _HorizontalDoctorCard(
          photoUrl: photoUrl,
          name: name,
          specialty: specialty,
          rating: rating,
          isAvailable: isAvailable,
          isSelected: isSelected,
          onTap: onTap,
        ),
      DoctorCardVariant.vertical => _VerticalDoctorCard(
          photoUrl: photoUrl,
          name: name,
          specialty: specialty,
          rating: rating,
          isAvailable: isAvailable,
          isSelected: isSelected,
          onTap: onTap,
        ),
    };
  }
}

class _HorizontalDoctorCard extends StatelessWidget {
  const _HorizontalDoctorCard({
    this.photoUrl,
    required this.name,
    required this.specialty,
    this.rating,
    this.isAvailable = false,
    this.isSelected = false,
    this.onTap,
  });

  final String? photoUrl;
  final String name;
  final String specialty;
  final double? rating;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return SizedBox(
      width: 160,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            border: isDark
                ? Border.all(color: AppColors.dividerDark, width: 1)
                : Border.all(color: AppColors.divider, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DoctorAvatar(photoUrl: photoUrl, size: 80),
              const SizedBox(height: AppSpacing.space12),
              Text(
                name,
                style: AppTextStyles.heading3.copyWith(color: primaryTextColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                specialty,
                style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (rating != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.space4),
                    Text(
                      rating!.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (isAvailable) ...[
                const SizedBox(height: AppSpacing.space8),
                AppChip(
                  label: 'Available Today',
                  type: AppChipType.status,
                  statusVariant: StatusChipVariant.confirmed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDoctorCard extends StatelessWidget {
  const _VerticalDoctorCard({
    this.photoUrl,
    required this.name,
    required this.specialty,
    this.rating,
    this.isAvailable = false,
    this.isSelected = false,
    this.onTap,
  });

  final String? photoUrl;
  final String name;
  final String specialty;
  final double? rating;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                border: Border.all(color: AppColors.accent, width: 1.5),
                color: AppColors.accent.withOpacity(isDark ? 0.10 : 0.05),
              )
            : null,
        child: Row(
        children: [
          _DoctorAvatar(photoUrl: photoUrl, size: 72),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3.copyWith(color: primaryTextColor),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  specialty,
                  style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                ),
                if (rating != null) ...[
                  const SizedBox(height: AppSpacing.space4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.space4),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isAvailable) ...[
                  const SizedBox(height: AppSpacing.space8),
                  AppChip(
                    label: 'Available Today',
                    type: AppChipType.status,
                    statusVariant: StatusChipVariant.confirmed,
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.space8),
            Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
              size: 20,
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.photoUrl, required this.size});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.divider,
      child: Icon(
        Icons.person,
        size: size * 0.45,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class DoctorCardSkeleton extends StatelessWidget {
  const DoctorCardSkeleton({super.key, this.variant = DoctorCardVariant.horizontal});

  final DoctorCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      DoctorCardVariant.horizontal => _HorizontalSkeleton(),
      DoctorCardVariant.vertical => _VerticalSkeleton(),
    };
  }
}

class _HorizontalSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: isDark
              ? Border.all(color: AppColors.dividerDark, width: 1)
              : Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: shimmerColor,
            ),
            const SizedBox(height: AppSpacing.space12),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Container(
              width: 70,
              height: 12,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: isDark
            ? Border.all(color: AppColors.dividerDark, width: 1)
            : Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: shimmerColor,
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(AppRadius.radiusSM),
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
