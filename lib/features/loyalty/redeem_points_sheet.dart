import 'package:flutter/material.dart';

import '../../backend/api_requests/loyalty_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_toast.dart';

class RedeemPointsSheet extends StatefulWidget {
  final int pointsBalance;
  final double redemptionRate;
  final int minRedemption;

  const RedeemPointsSheet({
    super.key,
    required this.pointsBalance,
    this.redemptionRate = 0.05,
    this.minRedemption = 100,
  });

  /// Returns true when a redemption completed successfully.
  static Future<bool?> show(
    BuildContext context,
    int balance, {
    double redemptionRate = 0.05,
    int minRedemption = 100,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RedeemPointsSheet(
        pointsBalance: balance,
        redemptionRate: redemptionRate,
        minRedemption: minRedemption,
      ),
    );
  }

  @override
  State<RedeemPointsSheet> createState() => _RedeemPointsSheetState();
}

class _RedeemPointsSheetState extends State<RedeemPointsSheet> {
  late int _selectedPoints;
  bool _isProcessing = false;
  int get _min => widget.minRedemption;
  int get _max {
    final cap = _min > 0 ? ((widget.pointsBalance ~/ _min) * _min) : widget.pointsBalance;
    return cap < 1000 ? cap : 1000;
  }

  double get _discount => _selectedPoints * widget.redemptionRate;

  @override
  void initState() {
    super.initState();
    _selectedPoints = _min;
  }

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
              const SizedBox(height: 4),
              Text('Available: ${widget.pointsBalance} pts',
                style: AppTextStyles.body2.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  onPressed: _selectedPoints > _min ? () => setState(() => _selectedPoints -= _min) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded), iconSize: 40,
                  color: _selectedPoints > _min ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 24),
                Text('$_selectedPoints pts', style: AppTextStyles.heading1.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _selectedPoints + _min <= _max ? () => setState(() => _selectedPoints += _min) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded), iconSize: 40,
                  color: _selectedPoints + _min <= _max ? AppColors.accent : AppColors.textSecondary,
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
    AppDialog.loading(context, message: 'Please wait…');

    try {
      final response = await LoyaltyApi.redeemLoyaltyPointsCall.call(points: _selectedPoints);
      if (!mounted) return;
      AppDialog.hideLoading(context);

      if (response.succeeded && (RedeemLoyaltyPointsCall.status(response.jsonBody) == true)) {
        final code = RedeemLoyaltyPointsCall.redemptionCode(response.jsonBody) ?? 'RDM-REDEEM';
        final discount = RedeemLoyaltyPointsCall.discount(response.jsonBody) ?? _discount;

        Navigator.pop(context, true);
        AppDialog.redemptionCode(
          context,
          code: code,
          discount: discount,
          instructions: 'Show your code to the staff at the counter',
        );
      } else {
        setState(() => _isProcessing = false);
        final message = RedeemLoyaltyPointsCall.message(response.jsonBody) ?? 'Redemption failed. Please try again.';
        AppToast.error(context, message: message);
      }
    } catch (_) {
      if (!mounted) return;
      AppDialog.hideLoading(context);
      setState(() => _isProcessing = false);
      AppToast.error(context, message: 'Something went wrong. Please try again.');
    }
  }
}
