import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_chip.dart';
import 'app_skeleton.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    this.doctorPhotoUrl,
    required this.doctorName,
    required this.specialty,
    required this.branchName,
    required this.date,
    required this.time,
    required this.status,
    this.daysToGo,
    this.onTap,
  });

  final String? doctorPhotoUrl;
  final String doctorName;
  final String specialty;
  final String branchName;
  final String date;
  final String time;
  final StatusChipVariant status;
  final int? daysToGo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppCard(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DoctorAvatar(photoUrl: doctorPhotoUrl),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: AppTextStyles.heading3.copyWith(color: primaryTextColor),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      specialty,
                      style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Expanded(
                          child: Text(
                            branchName,
                            style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Flexible(
                                child: Text(
                                  '$date • $time',
                                  style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppChip(
                          label: _statusLabel,
                          type: AppChipType.status,
                          statusVariant: status,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (daysToGo != null && daysToGo! > 0)
          Positioned(
            top: 0,
            right: 0,
            child: _DaysToGoBadge(days: daysToGo!),
          ),
      ],
    );
  }

  String get _statusLabel {
    return switch (status) {
      StatusChipVariant.confirmed => 'Confirmed',
      StatusChipVariant.pending => 'Pending',
      StatusChipVariant.cancelled => 'Cancelled',
      StatusChipVariant.completed => 'Completed',
    };
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: photoUrl != null
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
        size: 28,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _DaysToGoBadge extends StatelessWidget {
  const _DaysToGoBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.radiusLG),
          bottomLeft: Radius.circular(AppRadius.radiusSM),
        ),
      ),
      child: Text(
        '$days ${days == 1 ? "day" : "days"} to go',
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: isDark
            ? Border.all(color: AppColors.dividerDark, width: 1)
            : Border.all(color: AppColors.divider, width: 1),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShimmerCircle(size: 56),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: 160,
                  height: 16,
                  color: isDark,
                ),
                const SizedBox(height: AppSpacing.space8),
                _ShimmerBox(
                  width: 100,
                  height: 12,
                  color: isDark,
                ),
                const SizedBox(height: AppSpacing.space8),
                _ShimmerBox(
                  width: 140,
                  height: 12,
                  color: isDark,
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShimmerBox(
                      width: 120,
                      height: 14,
                      color: isDark,
                    ),
                    _ShimmerBox(
                      width: 80,
                      height: 24,
                      color: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size, this.color = false});

  final double size;
  final bool color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.color = false,
  });

  final double width;
  final double height;
  final bool color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
      ),
    );
  }
}
