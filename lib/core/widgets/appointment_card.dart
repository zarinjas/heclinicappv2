import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_chip.dart';
import 'countdown_badge.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    this.doctorPhotoUrl,
    this.doctorInitials,
    this.doctorGradient,
    required this.doctorName,
    required this.specialty,
    required this.branchName,
    required this.date,
    required this.time,
    required this.status,
    this.countdownDueAt,
    this.onTap,
    this.onDetailsTap,
    this.onAddToCalendar,
  });

  final String? doctorPhotoUrl;
  final String? doctorInitials;
  final List<Color>? doctorGradient;
  final String doctorName;
  final String specialty;
  final String branchName;
  final String date;
  final String time;
  final StatusChipVariant status;
  final DateTime? countdownDueAt;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: AppTextStyles.heading3.copyWith(color: primaryTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialty,
                        style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branchName,
                            style: AppTextStyles.body2.copyWith(color: secondaryTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
          ),
          if (countdownDueAt != null) ...[
            const SizedBox(height: AppSpacing.space16),
            _buildCountdownBar(),
          ],
          if (onAddToCalendar != null) ...[
            const SizedBox(height: AppSpacing.space12),
            GestureDetector(
              onTap: onAddToCalendar,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Add to Calendar',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.accent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (doctorInitials != null && doctorInitials!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: doctorGradient ?? const [AppColors.accent, AppColors.primary],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          doctorInitials!,
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: doctorPhotoUrl != null && doctorPhotoUrl!.isNotEmpty
            ? Image.network(
                doctorPhotoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _avatarPlaceholder();
                },
              )
            : _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppColors.divider,
      child: const Icon(Icons.person, size: 28, color: AppColors.textSecondary),
    );
  }

  Widget _buildStatusChip() {
    return AppChip(
      label: switch (status) {
        StatusChipVariant.confirmed => 'Confirmed',
        StatusChipVariant.pending => 'Pending',
        StatusChipVariant.cancelled => 'Cancelled',
        StatusChipVariant.completed => 'Completed',
      },
      type: AppChipType.status,
      statusVariant: status,
    );
  }

  Widget _buildCountdownBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.space8),
          Text(
            'Starts in',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Flexible(
            child: CountdownBadge(dueAt: countdownDueAt!),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDetailsTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'Details',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.accent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
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
                _ShimmerBox(width: 160, height: 16, color: isDark),
                const SizedBox(height: AppSpacing.space8),
                _ShimmerBox(width: 100, height: 12, color: isDark),
                const SizedBox(height: AppSpacing.space8),
                _ShimmerBox(width: 140, height: 12, color: isDark),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShimmerBox(width: 120, height: 14, color: isDark),
                    _ShimmerBox(width: 80, height: 24, color: isDark),
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
  const _ShimmerBox({required this.width, required this.height, this.color = false});
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
