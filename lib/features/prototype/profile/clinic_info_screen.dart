import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/services/branding_service.dart';

class ClinicInfoScreen extends StatelessWidget {
  const ClinicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${BrandingService.instance.appShortName} Clinic Info'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About ${BrandingService.instance.appName}',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Founded in 2015, ${BrandingService.instance.appName} has grown from a '
                    'single practice in Taman Tun Dr Ismail into a trusted '
                    'healthcare provider with three branches across the '
                    'Klang Valley. Our team of experienced doctors and '
                    'nurses is dedicated to delivering compassionate, '
                    'evidence-based care for patients of all ages. We '
                    'offer a wide range of services including general '
                    'consultations, health screenings, vaccinations, '
                    'antenatal care, and chronic disease management. With '
                    'modern facilities and a patient-first philosophy, He '
                    'Medical Clinic is committed to making quality '
                    'healthcare accessible to every family.',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Our Branches',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/branch-detail'),
                    child: const _BranchCard(
                      name: 'TTDI',
                      address: 'No. 12, Jalan Burhanuddin Helmi,\nTaman Tun Dr Ismail, 60000 KL',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/branch-detail'),
                    child: const _BranchCard(
                      name: 'Bangsar',
                      address: 'No. 45, Jalan Telawi 3,\nBangsar Baru, 59100 KL',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/branch-detail'),
                    child: const _BranchCard(
                      name: 'PJ',
                      address: 'No. 88, Jalan SS 21/56,\nDamansara Utama, 47400 PJ',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Operating Hours',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Monday - Friday: 8:00 AM - 8:00 PM',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Saturday: 8:00 AM - 4:00 PM',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Sunday & Public Holidays: Closed',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
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

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.name,
    required this.address,
  });

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
        color: AppColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent, AppColors.accentBlue],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinic',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    name,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    address,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.space16),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
