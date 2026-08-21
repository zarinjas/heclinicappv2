import 'package:flutter/material.dart';
import '/core/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/voucher_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/promotion_service.dart';
import '../../core/services/models/promotion.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_dialog.dart';
import 'widgets/voucher_code_sheet.dart';

class VouchersListScreen extends StatefulWidget {
  const VouchersListScreen({super.key});

  @override
  State<VouchersListScreen> createState() => _VouchersListScreenState();
}

class _VouchersListScreenState extends State<VouchersListScreen> {
  List<Promotion> _promos = Promotion.fallbackList;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await PromotionService.instance.init();
    if (mounted) setState(() => _promos = PromotionService.instance.promotions);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Offers & Vouchers',
        trailing: TextButton.icon(
          onPressed: () => context.pushNamed('/my-vouchers'),
          icon: const Icon(Icons.confirmation_num_outlined, size: 18),
          label: Text(
            'My Vouchers',
            style: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _promos.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildVoucherCard(p, isDark),
        )).toList(),
      ),
    );
  }

  Widget _buildVoucherCard(Promotion p, bool isDark) {
    final gradient = p.placeholderGradient;
    return GestureDetector(
      onTap: () => _onClaim(context, p),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(right: -20, top: -20,
              child: Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.ctaText ?? p.title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description,
                  style: AppTextStyles.body2.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                      ),
                      child: Text('Claim', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[0])),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onClaim(BuildContext ctx, Promotion p) async {
    if (FFAppState().tokenauth.isEmpty) {
      final goLogin = await AppDialog.confirm(
        ctx,
        title: 'Login Required',
        message: 'Please login to claim this voucher.',
        confirmLabel: 'Login',
      );
      if (goLogin == true && ctx.mounted) {
        ctx.go('/login');
      }
      return;
    }

    AppDialog.loading(ctx, message: 'Claiming…');

    try {
      final response = await VoucherApi.claimVoucherCall.call(
        promotionId: p.id,
      );
      if (!ctx.mounted) return;
      AppDialog.hideLoading(ctx);

      if (response.succeeded && ClaimVoucherCall.status(response.jsonBody) == true) {
        final code = ClaimVoucherCall.code(response.jsonBody) ?? p.promoCode ?? 'HEC-VOUCHER';
        await VoucherCodeSheet.show(
          ctx,
          code: code,
          discount: p.ctaText,
          title: 'Voucher Claimed',
        );
      } else {
        final message = ClaimVoucherCall.message(response.jsonBody) ??
            'Unable to claim this voucher. Please try again.';
        if (response.statusCode == 401) {
          ctx.go('/login');
        } else {
          AppToast.error(ctx, message: message);
        }
      }
    } catch (_) {
      if (!ctx.mounted) return;
      AppDialog.hideLoading(ctx);
      AppToast.error(ctx, message: 'Something went wrong. Please try again.');
    }
  }
}
