import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/step_indicator.dart';

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirm'),
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
              currentStep: 4,
              totalSteps: 4,
              labels: ['Branch', 'Doctor', 'Time', 'Confirm'],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
              children: [
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(label: 'Branch', value: 'TTDI Clinic'),
                      const SizedBox(height: AppSpacing.space12),
                      _InfoRow(label: 'Doctor', value: 'Dr. Ahmad Rizal'),
                      const SizedBox(height: AppSpacing.space12),
                      _InfoRow(label: 'Date', value: '14 July 2026'),
                      const SizedBox(height: AppSpacing.space12),
                      _InfoRow(label: 'Time', value: '10:30 AM'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.space12),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _InfoRow(label: 'Patient', value: 'Alia Rahman'),
                      const SizedBox(height: AppSpacing.space12),
                      _InfoRow(label: 'NRIC', value: '900101-14-1234'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentBlue]),
                    borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Text(
                          'Your preferred slot is not confirmed until our team responds via WhatsApp.',
                          style: AppTextStyles.body2.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                AppButton.whatsApp(
                  label: 'Book via WhatsApp',
                  icon: const Icon(Icons.call, size: 18, color: Colors.white),
                  onPressed: () => _showSuccessDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusLG)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.chipConfirmedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.chipConfirmedText, size: 28),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text('Booking request sent!', style: AppTextStyles.heading3, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Our team will confirm your appointment shortly.',
                style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).then((_) => Navigator.pushNamed(context, '/my-bookings'));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700)),
        Text(value, style: AppTextStyles.body1, textAlign: TextAlign.right),
      ],
    );
  }
}
