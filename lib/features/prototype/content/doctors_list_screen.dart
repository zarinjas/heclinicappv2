import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/doctor_card.dart';

import 'doctor_detail_sheet.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Our Doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                border: isDark
                    ? Border.all(color: AppColors.dividerDark, width: 1)
                    : Border.all(color: AppColors.divider, width: 1),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.space16,
                      right: AppSpacing.space8,
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search doctors...',
                        hintStyle: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              children: [
                DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  initials: 'AR',
                  avatarGradient: const [Color(0xFF2868F5), Color(0xFF131C3C)],
                  name: 'Dr. Ahmad Rizal',
                  specialty: 'General Practitioner',
                  onTap: () => DoctorDetailSheet.show(context),
                ),
                const SizedBox(height: AppSpacing.space12),
                DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  initials: 'SL',
                  avatarGradient: const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
                  name: 'Dr. Sarah Lim',
                  specialty: 'Cardiologist',
                  onTap: () => DoctorDetailSheet.show(context),
                ),
                const SizedBox(height: AppSpacing.space12),
                DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  initials: 'TW',
                  avatarGradient: const [Color(0xFFF5A623), Color(0xFFF54636)],
                  name: 'Dr. Tan Wei Ming',
                  specialty: 'Dermatologist',
                  onTap: () => DoctorDetailSheet.show(context),
                ),
                const SizedBox(height: AppSpacing.space12),
                DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  initials: 'WM',
                  avatarGradient: const [Color(0xFF27F5A3), Color(0xFF2868F5)],
                  name: 'Dr. Wong Mei Ling',
                  specialty: 'Pediatrician',
                  onTap: () => DoctorDetailSheet.show(context),
                ),
                const SizedBox(height: AppSpacing.space12),
                DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  initials: 'KM',
                  avatarGradient: const [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
                  name: 'Dr. Kavita Menon',
                  specialty: 'Psychiatrist',
                  onTap: () => DoctorDetailSheet.show(context),
                ),
                const SizedBox(height: AppSpacing.space24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
