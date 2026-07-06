import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/step_indicator.dart';

class BookingDoctorScreen extends StatefulWidget {
  const BookingDoctorScreen({super.key});

  @override
  State<BookingDoctorScreen> createState() => _BookingDoctorScreenState();
}

class _BookingDoctorScreenState extends State<BookingDoctorScreen> {
  int _selectedIndex = -1;

  static const _doctors = [
    _DoctorData('Dr. Ahmad Rizal', 'GP', 'AR', [Color(0xFF2868F5), Color(0xFF131C3C)]),
    _DoctorData('Dr. Sarah Lim', 'Cardiologist', 'SL', [Color(0xFF3B8DFF), Color(0xFF27F5A3)]),
    _DoctorData('Dr. Tan Wei Ming', 'Dermatologist', 'TW', [Color(0xFFF5A623), Color(0xFFF54636)]),
    _DoctorData('Dr. Wong Mei Ling', 'Pediatrician', 'WM', [Color(0xFF27F5A3), Color(0xFF2868F5)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Doctor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space24,
              AppSpacing.space16,
              AppSpacing.space24,
              AppSpacing.space16,
            ),
            child: const StepIndicator(
              currentStep: 2,
              totalSteps: 4,
              labels: ['Branch', 'Doctor', 'Time', 'Confirm'],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = -1),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                      border: Border.all(
                        color: _selectedIndex == -1 ? AppColors.accent : AppColors.divider,
                        width: _selectedIndex == -1 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_alt_outlined, color: AppColors.accent, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No Preference', style: AppTextStyles.heading3),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                "We'll find the earliest available slot",
                                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                ...List.generate(_doctors.length, (index) {
                  final doctor = _doctors[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < _doctors.length - 1 ? AppSpacing.space12 : 0),
                    child: DoctorCard(
                      variant: DoctorCardVariant.vertical,
                      name: doctor.name,
                      specialty: doctor.specialty,
                      initials: doctor.initials,
                      avatarGradient: doctor.gradient,
                      isSelected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: AppButton.primary(
            label: 'Next',
            onPressed: _selectedIndex >= 0 || _selectedIndex == -1
                ? () => Navigator.pushNamed(context, '/booking-datetime')
                : null,
          ),
        ),
      ),
    );
  }
}

class _DoctorData {
  final String name;
  final String specialty;
  final String initials;
  final List<Color> gradient;

  const _DoctorData(this.name, this.specialty, this.initials, this.gradient);
}
