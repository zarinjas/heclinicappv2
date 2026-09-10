import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '/app_state.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_radius.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dialog.dart';
import '/core/widgets/app_toast.dart';
import '/utils/whatsapp_helper.dart';
import 'booking_flow_model.dart';

class BookingConfirmationScreenWidget extends StatelessWidget {
  const BookingConfirmationScreenWidget({super.key});

  static const String routeName = 'bookingConfirmation';
  static const String routePath = '/bookingConfirmation';

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (_) {}
    return time;
  }

  String _getDoctorDisplay(BookingFlowModel model) {
    if (model.isNoPreference) {
      return 'No Preference';
    }
    return model.selectedDoctorName.isNotEmpty
        ? model.selectedDoctorName
        : 'No Preference';
  }

  Future<void> _onBookViaWhatsApp(BuildContext context) async {
    final bookingModel = BookingFlowModel();
    final appState = FFAppState();

    final whatsAppNumber = bookingModel.selectedBranchWhatsApp;
    if (whatsAppNumber.isEmpty) {
      if (context.mounted) {
        AppToast.error(
          context,
          message: 'WhatsApp number not available for this branch.',
        );
      }
      return;
    }

    final doctorDisplay = _getDoctorDisplay(bookingModel);
    final formattedDate = bookingModel.selectedDate != null
        ? _formatDate(bookingModel.selectedDate!)
        : 'Not selected';
    final formattedTime = bookingModel.selectedTime.isNotEmpty
        ? _formatTime(bookingModel.selectedTime)
        : 'Not selected';
    final patientName = appState.name.isNotEmpty ? appState.name : '—';
    final patientNric = appState.nationalman.isNotEmpty
        ? appState.nationalman
        : '—';

    final message = WhatsAppHelper.buildPreFilledMessage(
      branchName: bookingModel.selectedBranchName,
      patientName: patientName,
      patientNric: patientNric,
      doctorName: doctorDisplay,
      date: formattedDate,
      time: formattedTime,
      remark: bookingModel.bookingRemark,
    );

    final deepLink = WhatsAppHelper.buildDeepLink(
      phoneNumber: whatsAppNumber,
      message: message,
    );

    final uri = Uri.parse(deepLink);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch && context.mounted) {
        _showWhatsAppNotInstalledDialog(context);
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        _showWhatsAppNotInstalledDialog(context);
      }
    }
  }

  Future<void> _showWhatsAppNotInstalledDialog(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'WhatsApp Not Found',
      message:
          'WhatsApp is not installed. Please install WhatsApp to complete your booking.',
      confirmLabel: 'Install WhatsApp',
    );
    if (confirmed == true) {
      final installUrl = WhatsAppHelper.getWhatsAppInstallUrl();
      try {
        await launchUrl(
          Uri.parse(installUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
  }

  Widget _buildStepIndicator() {
    final steps = [
      _StepData(1, 'Branch'),
      _StepData(2, 'Doctor'),
      _StepData(3, 'Date & Time'),
      _StepData(4, 'Confirm'),
    ];

    const accentColor = AppColors.accent;

    return Row(
      children: steps.map((step) {
        final isLastStep = step.number == 4;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  border: Border.all(
                    color: accentColor,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: AppTextStyles.caption.copyWith(
                  color: isLastStep ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight:
                      isLastStep ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = FFAppState();
    final bookingModel = BookingFlowModel();

    final doctorDisplay = _getDoctorDisplay(bookingModel);
    final formattedDate = bookingModel.selectedDate != null
        ? _formatDate(bookingModel.selectedDate!)
        : 'Not selected';
    final formattedTime = bookingModel.selectedTime.isNotEmpty
        ? _formatTime(bookingModel.selectedTime)
        : 'Not selected';
    final patientName = appState.name.isNotEmpty ? appState.name : '—';
    final patientNric = appState.nationalman.isNotEmpty
        ? appState.nationalman
        : '—';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Appointment',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              0,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            child: _buildStepIndicator(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(
                    isDark,
                    bookingModel,
                    doctorDisplay,
                    formattedDate,
                    formattedTime,
                    patientName,
                    patientNric,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  _buildInfoBanner(isDark),
                ],
              ),
            ),
          ),
          _buildBookButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    bool isDark,
    BookingFlowModel model,
    String doctorDisplay,
    String formattedDate,
    String formattedTime,
    String patientName,
    String patientNric,
  ) {
    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Summary',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildSummaryRow(
            'Branch',
            model.selectedBranchName.isNotEmpty
                ? model.selectedBranchName
                : '—',
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Doctor',
            doctorDisplay,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Date',
            formattedDate,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Time',
            formattedTime,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Patient',
            '$patientName, $patientNric',
            dividerColor,
            secondaryColor,
            primaryColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color dividerColor,
    Color secondaryColor,
    Color primaryColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: AppTextStyles.body2.copyWith(color: secondaryColor),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.body1.copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            color: dividerColor,
          ),
      ],
    );
  }

  Widget _buildInfoBanner(bool isDark) {
    const accentColor = AppColors.accent;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: accentColor,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              'The time you pick is your preference — our team will confirm the final slot via WhatsApp.',
              style: AppTextStyles.body2.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Builder(
          builder: (context) => AppButton.whatsApp(
            label: 'Book via WhatsApp',
            onPressed: () => _onBookViaWhatsApp(context),
            icon: const Icon(Icons.chat, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final int number;
  final String label;

  _StepData(this.number, this.label);
}
