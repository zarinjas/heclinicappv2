import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Health Packages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        children: [
          _PackageCard(
            gradient: const [Color(0xFF131C3C), Color(0xFF3B8DFF)],
            title: 'Basic Health Screening',
            price: 'RM 199',
            items: 'Blood test, Urine test, BMI, BP check',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening package details...')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.space16),
          _PackageCard(
            gradient: const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
            title: 'Comprehensive Health Check',
            price: 'RM 399',
            items: 'Full blood work, ECG, Chest X-Ray, Doctor consultation',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening package details...')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.space16),
          _PackageCard(
            gradient: const [Color(0xFFF5A623), Color(0xFFF54636)],
            title: "Women's Wellness",
            price: 'RM 299',
            items: 'Pap smear, Breast exam, Pelvic ultrasound, Blood test',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening package details...')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.space16),
          _PackageCard(
            gradient: const [Color(0xFF1D2B5F), Color(0xFF27F5A3)],
            title: 'Cardiac Screening',
            price: 'RM 499',
            items: 'ECG, Echocardiogram, Stress test, Cardiologist review',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening package details...')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String price;
  final String items;
  final VoidCallback onTap;

  const _PackageCard({
    required this.gradient,
    required this.title,
    required this.price,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: isDark
            ? Border.all(color: AppColors.dividerDark, width: 1)
            : Border.all(color: AppColors.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  price,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Includes:',
                  style: AppTextStyles.label.copyWith(color: secondaryText),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  items,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                AppButton.ghost(
                  label: 'Learn More',
                  onPressed: onTap,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
