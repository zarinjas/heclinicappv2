import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';

class DoctorDetailSheet extends StatelessWidget {
  const DoctorDetailSheet({
    super.key,
    required this.name,
    required this.specialty,
    required this.branchName,
    required this.bio,
    this.photoUrl,
    this.onBookAppointment,
  });

  final String name;
  final String specialty;
  final String branchName;
  final String bio;
  final String? photoUrl;
  final VoidCallback? onBookAppointment;

  static Future<void> show(
    BuildContext context, {
    required String name,
    required String specialty,
    required String branchName,
    required String bio,
    String? photoUrl,
    VoidCallback? onBookAppointment,
  }) {
    return AppBottomSheet.show<void>(
      context,
      child: DoctorDetailSheet(
        name: name,
        specialty: specialty,
        branchName: branchName,
        bio: bio,
        photoUrl: photoUrl,
        onBookAppointment: onBookAppointment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: AppSpacing.space32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space16),
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? AppColors.dividerDark : AppColors.divider,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 48,
                    color: secondaryTextColor,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            name,
            style: AppTextStyles.heading3.copyWith(color: titleColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            specialty,
            style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            branchName,
            style: AppTextStyles.caption.copyWith(color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: AppTextStyles.heading3.copyWith(color: titleColor),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  bio,
                  style: AppTextStyles.body1.copyWith(
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              label: 'Book Appointment',
              onTap: onBookAppointment ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}
