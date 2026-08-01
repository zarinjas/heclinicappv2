import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';

class RedeemPointsSheet extends StatefulWidget {
  final int pointsBalance;
  const RedeemPointsSheet({super.key, required this.pointsBalance});

  static Future<void> show(BuildContext context, int balance) {
    return showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => RedeemPointsSheet(pointsBalance: balance),
    );
  }

  @override
  State<RedeemPointsSheet> createState() => _RedeemPointsSheetState();
}

class _RedeemPointsSheetState extends State<RedeemPointsSheet> {
  late int _selectedPoints;
  bool _isProcessing = false;
  int get _min => 100;
  int get _max => widget.pointsBalance < 1000 ? widget.pointsBalance : 1000;
  double get _discount => _selectedPoints * 0.05;

  @override
  void initState() { super.initState(); _selectedPoints = _min; }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4,
                decoration: BoxDecoration(color: isDark ? AppColors.dividerDark : AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('Redeem Points', style: AppTextStyles.heading2.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  onPressed: _selectedPoints > _min ? () => setState(() => _selectedPoints -= 100) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded), iconSize: 40,
                  color: _selectedPoints > _min ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 24),
                Text('$_selectedPoints pts', style: AppTextStyles.heading1.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _selectedPoints + 100 <= _max ? () => setState(() => _selectedPoints += 100) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded), iconSize: 40,
                  color: _selectedPoints + 100 <= _max ? AppColors.accent : AppColors.textSecondary,
                ),
              ]),
              const SizedBox(height: 12),
              Text('= RM ${_discount.toStringAsFixed(2)} discount', style: AppTextStyles.heading3.copyWith(color: AppColors.accent)),
              const SizedBox(height: 16),
              Text('Show your code to the staff at the counter',
                style: AppTextStyles.body1.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                label: 'Confirm Redemption', onPressed: _isProcessing ? null : _onConfirm,
                isLoading: _isProcessing, isFullWidth: true,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.pop(context);
    AppDialog.redemptionCode(
      context,
      code: 'HEC-A3F9-2024',
      discount: _discount,
      instructions: 'Show your code to the staff at the counter',
    );
  }
}
