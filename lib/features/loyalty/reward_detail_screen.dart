import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/loyalty_api.dart';
import '../../core/services/models/loyalty_reward.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_toast.dart';
import '../../pages/booking/booking_flow_model.dart';
import '../content/widgets/voucher_code_sheet.dart';

class RewardDetailScreen extends StatefulWidget {
  const RewardDetailScreen({super.key, required this.reward});

  final LoyaltyReward reward;

  @override
  State<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends State<RewardDetailScreen> {
  bool _isProcessing = false;

  LoyaltyReward get reward => widget.reward;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: 'Reward Details'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(imageUrl: reward.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.pointsGradientStart, AppColors.pointsGradientEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              reward.name,
                              style: AppTextStyles.heading2.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: AppTextStyles.heading2.copyWith(color: titleColor),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        if (reward.description.isNotEmpty) ...[
                          Text(
                            reward.description,
                            style: AppTextStyles.body1.copyWith(color: titleColor, height: 1.5),
                          ),
                          const SizedBox(height: AppSpacing.space16),
                        ],
                        _buildInfoRow(
                          Icons.stars_rounded,
                          'Cost',
                          '${reward.pointsCost} points',
                          titleColor,
                          secondaryColor,
                        ),
                        if (reward.isService && reward.servicePackageName != null)
                          _buildInfoRow(
                            Icons.medical_services_outlined,
                            'Service',
                            reward.servicePackageName!,
                            titleColor,
                            secondaryColor,
                          ),
                        if (reward.stockLabel.isNotEmpty)
                          _buildInfoRow(
                            Icons.inventory_2_outlined,
                            'Availability',
                            reward.stockLabel,
                            titleColor,
                            reward.isOutOfStock ? AppColors.error : secondaryColor,
                          ),
                        const SizedBox(height: AppSpacing.space16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.space12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                              const SizedBox(width: AppSpacing.space8),
                              Expanded(
                                child: Text(
                                  reward.isService
                                      ? 'After redeeming, book your appointment and show the code at the counter.'
                                      : 'Show your redemption code to the staff at the counter to collect your reward.',
                                  style: AppTextStyles.body2.copyWith(color: secondaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider),
              ),
            ),
            child: SafeArea(
              top: false,
              child: AppButton.primary(
                label: '${reward.ctaLabel} (${reward.pointsCost} pts)',
                onPressed: reward.isOutOfStock || _isProcessing ? null : _onRedeem,
                isLoading: _isProcessing,
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color titleColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.space8),
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.body2.copyWith(color: titleColor)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(color: valueColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRedeem() async {
    if (FFAppState().tokenauth.isEmpty) {
      final goLogin = await AppDialog.confirm(
        context,
        title: 'Login Required',
        message: 'Please login to redeem rewards with your points.',
        confirmLabel: 'Login',
      );
      if (goLogin == true && mounted) {
        context.go('/login');
      }
      return;
    }

    final confirmed = await AppDialog.confirm(
      context,
      title: 'Redeem this reward?',
      message: '${reward.pointsCost} points will be deducted from your balance.',
      confirmLabel: 'Redeem',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    AppDialog.loading(context, message: 'Redeeming…');

    try {
      final response = await LoyaltyApi.redeemLoyaltyRewardCall.call(rewardId: reward.id);
      if (!mounted) return;
      AppDialog.hideLoading(context);

      if (response.succeeded && RedeemLoyaltyRewardCall.status(response.jsonBody) == true) {
        final code = RedeemLoyaltyRewardCall.redemptionCode(response.jsonBody) ?? 'RDM-REDEEM';
        setState(() => _isProcessing = false);

        await VoucherCodeSheet.show(
          context,
          code: code,
          discount: '${reward.name} · ${reward.pointsCost} pts',
          title: 'Reward Redeemed',
        );

        if (mounted && reward.isService) {
          _offerBooking(code);
        }
      } else {
        setState(() => _isProcessing = false);
        final message = RedeemLoyaltyRewardCall.message(response.jsonBody) ??
            'Unable to redeem this reward. Please try again.';
        if (response.statusCode == 401) {
          context.go('/login');
        } else {
          AppToast.error(context, message: message);
        }
      }
    } catch (_) {
      if (!mounted) return;
      AppDialog.hideLoading(context);
      setState(() => _isProcessing = false);
      AppToast.error(context, message: 'Something went wrong. Please try again.');
    }
  }

  Future<void> _offerBooking(String code) async {
    final book = await AppDialog.confirm(
      context,
      title: 'Book an appointment?',
      message: 'Book an appointment for "${reward.name}". Your redemption code will be noted in your booking.',
      confirmLabel: 'Book Now',
    );
    if (book == true && mounted) {
      final model = BookingFlowModel();
      model.setRemark('He Rewards: ${reward.name} (Code: $code)');
      context.push('/branchSelectionScreen');
    }
  }
}
