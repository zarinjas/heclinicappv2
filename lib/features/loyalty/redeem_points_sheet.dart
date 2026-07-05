import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';

class RedeemPointsSheet extends StatefulWidget {
  const RedeemPointsSheet({
    super.key,
    required this.availablePoints,
    this.onRedeemed,
  });

  final int availablePoints;
  final VoidCallback? onRedeemed;

  static Future<void> show(
    BuildContext context, {
    required int availablePoints,
    VoidCallback? onRedeemed,
  }) {
    return AppBottomSheet.show<void>(
      context,
      title: 'Redeem Points',
      child: RedeemPointsSheet(
        availablePoints: availablePoints,
        onRedeemed: onRedeemed,
      ),
    );
  }

  @override
  State<RedeemPointsSheet> createState() => _RedeemPointsSheetState();
}

class _RedeemPointsSheetState extends State<RedeemPointsSheet> {
  late int _selectedPoints;
  static const int _stepSize = 100;
  static const int _minPoints = 100;
  static const double _redemptionRate = 0.05;

  int get _maxPoints {
    final balanceMax = widget.availablePoints;
    return balanceMax < 1000 ? balanceMax - (balanceMax % _stepSize) : 1000;
  }

  @override
  void initState() {
    super.initState();
    _selectedPoints = _minPoints.clamp(_minPoints, _maxPoints);
  }

  double get _discountValue => _selectedPoints * _redemptionRate;

  void _increment() {
    final next = _selectedPoints + _stepSize;
    if (next <= _maxPoints) {
      setState(() => _selectedPoints = next);
    }
  }

  void _decrement() {
    final next = _selectedPoints - _stepSize;
    if (next >= _minPoints) {
      setState(() => _selectedPoints = next);
    }
  }

  Future<void> _confirmRedemption() async {
    AppDialog.loading(context, message: 'Processing redemption…');

    try {
      await Future.delayed(const Duration(seconds: 1));

      AppDialog.hideLoading(context);
      Navigator.of(context).pop();

      if (mounted) {
        AppDialog.redemptionCode(
          context,
          code: 'HEC-A3F9-2024',
          discount: _discountValue,
          instructions:
              'Show this code to the counter staff.\nValid for today\'s visit only.',
        );
        widget.onRedeemed?.call();
      }
    } catch (e) {
      AppDialog.hideLoading(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redemption failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Available: ${widget.availablePoints} pts',
            style: AppTextStyles.body1.copyWith(color: secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space24),
          _buildAmountSelector(isDark),
          const SizedBox(height: AppSpacing.space16),
          _buildDiscountPreview(isDark),
          const SizedBox(height: AppSpacing.space20),
          _buildInfoNote(isDark),
          const SizedBox(height: AppSpacing.space20),
          _buildConfirmButton(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.space16),
        ],
      ),
    );
  }

  Widget _buildAmountSelector(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: _selectedPoints > _minPoints ? _decrement : null,
        ),
        const SizedBox(width: AppSpacing.space16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
          ),
          child: Text(
            '$_selectedPoints pts',
            style: AppTextStyles.heading2.copyWith(color: textColor),
          ),
        ),
        const SizedBox(width: AppSpacing.space16),
        _StepperButton(
          icon: Icons.add,
          onTap: _selectedPoints < _maxPoints ? _increment : null,
        ),
      ],
    );
  }

  Widget _buildDiscountPreview(bool isDark) {
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      children: [
        Text(
          '= RM ${_discountValue.toStringAsFixed(2)} discount',
          style: AppTextStyles.heading3.copyWith(color: AppColors.accent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          'Discount applied to your next invoice',
          style: AppTextStyles.body2.copyWith(color: secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoNote(bool isDark) {
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.scaffoldBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
      ),
      child: Text(
        'Show your redemption code to the staff at the counter.\n'
        'Code is valid for this visit only.',
        style: AppTextStyles.body2.copyWith(color: secondaryText),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isDisabled = _selectedPoints < _minPoints;

    return AppButton(
      label: 'Confirm Redemption',
      onPressed: isDisabled ? null : _confirmRedemption,
      variant: AppButtonVariant.primary,
      isFullWidth: true,
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onTap == null;
    final borderColor = isDisabled
        ? (isDark ? AppColors.dividerDark : AppColors.divider)
        : AppColors.accent;
    final iconColor = isDisabled
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
        : AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
