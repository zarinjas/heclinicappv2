import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_shadows.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class DoctorDetailSheet extends StatelessWidget {
  const DoctorDetailSheet({
    super.key,
    required this.doctorName,
    this.specialty,
    this.qualifications,
    this.branchName,
    this.photoUrl,
    this.bio,
    this.onBookAppointment,
  });

  final String doctorName;
  final String? specialty;
  final String? qualifications;
  final String? branchName;
  final String? photoUrl;
  final String? bio;
  final VoidCallback? onBookAppointment;

  static void show(
    BuildContext context, {
    required String doctorName,
    String? specialty,
    String? qualifications,
    String? branchName,
    String? photoUrl,
    String? bio,
    VoidCallback? onBookAppointment,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: DoctorDetailSheet(
          doctorName: doctorName,
          specialty: specialty,
          qualifications: qualifications,
          branchName: branchName,
          photoUrl: photoUrl,
          bio: bio,
          onBookAppointment: onBookAppointment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.radiusXL),
        ),
        boxShadow: AppShadows.shadowHigh,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handleBar(isDark),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space20,
                0,
                AppSpacing.space20,
                AppSpacing.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _avatar(isDark),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    doctorName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading2.copyWith(color: textColor),
                  ),
                  if (specialty != null && specialty!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      specialty!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body1.copyWith(color: secondary),
                    ),
                  ],
                  if (branchName != null && branchName!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Flexible(
                          child: Text(
                            branchName!,
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.body2.copyWith(color: secondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (qualifications != null &&
                      qualifications!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space16),
                    _sectionTitle('Qualifications', textColor),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      qualifications!,
                      style: AppTextStyles.body1.copyWith(color: textColor),
                    ),
                  ],
                  if (bio != null && bio!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space16),
                    _sectionTitle('About', textColor),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      bio!,
                      style: AppTextStyles.body1.copyWith(color: textColor),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    label: 'Book Appointment',
                    onPressed: () {
                      if (onBookAppointment != null) {
                        onBookAppointment!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.heading3.copyWith(color: color)),
    );
  }

  Widget _handleBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        ),
      ),
    );
  }

  Widget _avatar(bool isDark) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.surfaceDark : AppColors.scaffoldBg,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(photoUrl!),
            onError: (_, __) {},
          ),
        ),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Text(
          _initials(doctorName),
          style: AppTextStyles.heading1.copyWith(color: AppColors.accent),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
