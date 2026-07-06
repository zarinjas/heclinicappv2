import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_skeleton.dart';

enum HealthRecordType { note, letter, lab, mc }

class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({
    super.key,
    required this.recordType,
    required this.title,
    required this.doctorName,
    required this.date,
    this.onTap,
  });

  final HealthRecordType recordType;
  final String title;
  final String doctorName;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _TypeIcon(type: recordType),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  doctorName,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Text(
            date,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final HealthRecordType type;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(isDark ? 0.2 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _icon,
        size: 20,
        color: AppColors.accent,
      ),
    );
  }

  IconData get _icon {
    return switch (type) {
      HealthRecordType.note => Icons.description_outlined,
      HealthRecordType.letter => Icons.mail_outlined,
      HealthRecordType.lab => Icons.science_outlined,
      HealthRecordType.mc => Icons.assignment_outlined,
    };
  }
}

class HealthRecordCardSkeleton extends StatelessWidget {
  const HealthRecordCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    Widget box(double w, double h) => Container(
      width: w, height: h,
      decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(4)),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(160, 14),
                const SizedBox(height: AppSpacing.space8),
                box(120, 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          box(72, 12),
        ],
      ),
    );
  }
}
