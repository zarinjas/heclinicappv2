import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dialog.dart';

class RedeemPointsSheet extends StatefulWidget {
  final int pointsBalance;

  const RedeemPointsSheet({super.key, required this.pointsBalance});

  static Future<void> show(BuildContext context, int balance) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RedeemPointsSheet(pointsBalance: balance),
    );
  }

  @override
  State<RedeemPointsSheet> createState() => _RedeemPointsSheetState();
}

class _RedeemPointsSheetState extends State<RedeemPointsSheet> {
  late int _selectedPoints;
  bool _isProcessing = false;

  int get _minPoints => 100;
  int get _maxPoints => widget.pointsBalance < 1000 ? widget.pointsBalance : 1000;

  @override
  void initState() {
    super.initState();
    _selectedPoints = _minPoints;
  }

  double get _discount => _selectedPoints * 0.05;

  void _increment() {
    if (_selectedPoints + 100 <= _maxPoints) {
      setState(() => _selectedPoints += 100);
    }
  }

  void _decrement() {
    if (_selectedPoints - 100 >= _minPoints) {
      setState(() => _selectedPoints -= 100);
    }
  }

  Future<void> _onConfirm() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isProcessing = false);
    if (!mounted) return;
    Navigator.pop(context);
    AppDialog.redemptionCode(
      context,
      code: 'HEC-A3F9-2024',
      discount: _discount,
      instructions: 'Show your code to the staff at the counter',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space20,
              AppSpacing.space8,
              AppSpacing.space20,
              AppSpacing.space32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.space20),
                Text(
                  'Redeem Points',
                  style: AppTextStyles.heading2.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _selectedPoints > _minPoints ? _decrement : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      iconSize: 40,
                      color: _selectedPoints > _minPoints
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.space24),
                    Text(
                      '$_selectedPoints pts',
                      style: AppTextStyles.heading1.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space24),
                    IconButton(
                      onPressed: _selectedPoints + 100 <= _maxPoints ? _increment : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      iconSize: 40,
                      color: _selectedPoints + 100 <= _maxPoints
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                Text(
                  '= RM ${_discount.toStringAsFixed(2)} discount',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  'Show your code to the staff at the counter',
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space24),
                AppButton.primary(
                  label: 'Confirm Redemption',
                  onPressed: _isProcessing ? null : _onConfirm,
                  isLoading: _isProcessing,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
