import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/step_indicator.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({
    super.key,
    this.branchName,
    this.doctorName,
    this.appointmentDate,
    this.appointmentTime,
    this.branchWhatsappNumber,
    this.patientName,
    this.patientNric,
  });

  final String? branchName;
  final String? doctorName;
  final String? appointmentDate;
  final String? appointmentTime;
  final String? branchWhatsappNumber;
  final String? patientName;
  final String? patientNric;

  @override
  State<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  Future<void> _openWhatsApp() async {
    final branchName = widget.branchName ?? 'He Clinic';
    final doctorName =
        widget.doctorName ?? 'No Preference';
    final date = widget.appointmentDate ?? '';
    final time = widget.appointmentTime ?? '';
    final patientName =
        widget.patientName ?? '';
    final patientNric =
        widget.patientNric ?? '';
    final waNumber = widget.branchWhatsappNumber ?? '60136254528';

    final message = 'Hi He Clinic $branchName!\n\n'
        'I would like to book an appointment:\n'
        '- Name: $patientName\n'
        '- NRIC: $patientNric\n'
        '- Branch: $branchName\n'
        '- Doctor: $doctorName\n'
        '- Date: $date\n'
        '- Time: $time\n\n'
        'Please confirm my appointment. Thank you!';

    final uri = Uri.parse(
      'https://wa.me/$waNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Confirm Booking',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: StepIndicator(
              currentStep: 3,
              totalSteps: 4,
              labels: const [
                'Branch',
                'Doctor',
                'Date & Time',
                'Confirm',
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: AppSpacing.space16),
                  _buildDisclaimerBanner(),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: AppTextStyles.heading3.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.space16),
          _summaryRow(
            Icons.location_on,
            'Branch',
            widget.branchName,
            textColor,
            secondaryText,
          ),
          const SizedBox(height: AppSpacing.space12),
          _summaryRow(
            Icons.person,
            'Doctor',
            widget.doctorName,
            textColor,
            secondaryText,
          ),
          const SizedBox(height: AppSpacing.space12),
          _summaryRow(
            Icons.calendar_today,
            'Date',
            widget.appointmentDate,
            textColor,
            secondaryText,
          ),
          const SizedBox(height: AppSpacing.space12),
          _summaryRow(
            Icons.access_time,
            'Time',
            widget.appointmentTime,
            textColor,
            secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String? value,
    Color textColor,
    Color secondaryText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: AppSpacing.space12),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(color: secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value != null && value.isNotEmpty ? value : '—',
            style: AppTextStyles.body1.copyWith(
              color: value != null && value.isNotEmpty
                  ? textColor
                  : secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.accent.withOpacity(0.15)
        : const Color(0xFFE0F4FF);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              'Your preferred slot is not confirmed until our team responds via WhatsApp.',
              style: AppTextStyles.body2.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomBg =
        isDark ? AppColors.surfaceDark : AppColors.surface;
    final topBorder =
        isDark ? AppColors.dividerDark : AppColors.divider;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        top: AppSpacing.space12,
        bottom: AppSpacing.space16 +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bottomBg,
        border: Border(top: BorderSide(color: topBorder)),
      ),
      child: Column(
        children: [
          AppButton.whatsApp(
            label: 'Book via WhatsApp',
            onPressed: _openWhatsApp,
            isFullWidth: true,
            icon: const Icon(Icons.chat, size: 20),
          ),
          const SizedBox(height: AppSpacing.space8),
          AppButton.secondary(
            label: 'Book Another',
            onPressed: () => Navigator.of(context).pop('reselect'),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
