import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF2868F5), Color(0xFF131C3C)]),
                    ),
                    alignment: Alignment.center,
                    child: const Text('AR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Text('Dr. Ahmad Rizal', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.space4),
                  Text('GP', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('TTDI Branch', style: AppTextStyles.body2),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: AppSpacing.space16),
                  _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: '14 July 2026'),
                  const SizedBox(height: AppSpacing.space12),
                  _DetailRow(icon: Icons.access_time_outlined, label: 'Time', value: '10:30 AM'),
                  const SizedBox(height: AppSpacing.space12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.space12),
                      Text('Status', style: AppTextStyles.body1),
                      const Spacer(),
                      const AppChip(label: 'Confirmed', type: AppChipType.status, statusVariant: StatusChipVariant.confirmed),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: AppSpacing.space16),
                  Text('Branch Address', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.space4),
                  Text('Jalan Burhanuddin Helmi, TTDI', style: AppTextStyles.body1),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.destructive(
              label: 'Cancel Appointment',
              onPressed: () => _showCancelDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusLG)),
        title: Text('Cancel Appointment?', style: AppTextStyles.heading3),
        content: Text(
          'This action cannot be undone.',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Back', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.space12),
        Text(label, style: AppTextStyles.body1),
        const Spacer(),
        Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
