import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class BranchDetailScreen extends StatelessWidget {
  const BranchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('TTDI Clinic'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF131C3C), Color(0xFF1D2B5F)],
                ),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: AppSpacing.space12),
                  Text(
                    'TTDI Clinic',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: secondaryText,
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'Jalan Burhanuddin Helmi, Taman Tun Dr Ismail, 60000 Kuala Lumpur',
                          style: AppTextStyles.body1.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    'Operating Hours',
                    style: AppTextStyles.heading3.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Mon - Fri: 8:00 AM - 8:00 PM',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Saturday: 8:00 AM - 4:00 PM',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Sunday & PH: Closed',
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: 'Get Directions',
                          icon: const Icon(Icons.map_outlined, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening external app...'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: AppButton.whatsApp(
                          label: 'WhatsApp Us',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening external app...'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
