import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaTap,
  });

  static const noAppointments = AppEmptyState(
    icon: Icons.calendar_today,
    title: 'No appointments yet',
    subtitle: 'Book your first visit today',
    ctaLabel: 'Book Now',
  );

  static const noNotifications = AppEmptyState(
    icon: Icons.notifications_none,
    title: "You're all caught up",
    subtitle: "We'll notify you when something's new",
  );

  static const noDocuments = AppEmptyState(
    icon: Icons.description_outlined,
    title: 'No documents yet',
    subtitle: 'Your health records will appear here',
  );

  static const noRecords = AppEmptyState(
    icon: Icons.assignment_outlined,
    title: 'No records found',
    subtitle: 'Your clinical notes will appear here',
  );

  static const noArticles = AppEmptyState(
    icon: Icons.article_outlined,
    title: 'No articles yet',
    subtitle: 'Check back soon for health tips',
  );

  static const noVideos = AppEmptyState(
    icon: Icons.play_circle_outline,
    title: 'No videos yet',
    subtitle: 'Check back soon for our latest videos',
  );

  static const noDoctors = AppEmptyState(
    icon: Icons.person_outline,
    title: 'No doctors available',
    subtitle: 'Please contact the clinic directly',
  );

  static const noSearchResults = AppEmptyState(
    icon: Icons.search_off,
    title: 'No results found',
    subtitle: 'Try a different search term',
  );

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 160,
              color: iconColor.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              subtitle,
              style: AppTextStyles.body1.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && ctaLabel!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space24),
              AppButton.primary(
                label: ctaLabel!,
                onPressed: onCtaTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
