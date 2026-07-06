import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  static const _gradient = [Color(0xFF3B8DFF), Color(0xFF27F5A3)];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Article'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share tapped')),
                  );
                },
              ),
            ],
            expandedHeight: 240,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradient,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '10 habits for a healthier heart',
                    style: AppTextStyles.heading2.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Dr. Sarah Lim \u2022 4 min read \u2022 July 2026',
                    style: AppTextStyles.body2.copyWith(color: secondaryText),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Your heart works tirelessly every second of every day, pumping blood to every corner of your body. Taking care of it doesn\'t require a complete life overhaul \u2014 small, consistent habits can add years to your life.',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    '1. Move your body daily. Aim for at least 30 minutes of moderate activity \u2014 walking, cycling, or swimming all count. Consistency matters far more than intensity.',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    '2. Eat the rainbow. Fill your plate with colourful fruits and vegetables. Each colour provides different antioxidants and nutrients that protect your cardiovascular system.',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    '3. Sleep 7-9 hours nightly. Poor sleep is linked to higher blood pressure, increased inflammation, and weight gain \u2014 all risk factors for heart disease.',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Small changes compound over time. You don\'t need to transform overnight. Pick one habit, master it for two weeks, then stack another. Before you know it, you\'ll have built a lifestyle your heart will thank you for.',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
