import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class MyVouchersScreen extends StatelessWidget {
  const MyVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('My Vouchers'),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.button.copyWith(fontSize: 13),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Used / Expired'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveTab(context),
            _buildExpiredTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        _ClaimedVoucherCard(
          discount: 'RM 30 OFF',
          title: 'Basic Health Screening',
          code: 'HEC-V001-2025',
          expiryLabel: 'Valid until 20 Jul 2025',
          gradient: const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
          onUse: () => _showVoucherQR(context, 'HEC-V001-2025', 'RM 30 OFF', 'Basic Health Screening'),
        ),
        const SizedBox(height: AppSpacing.space12),
        _ClaimedVoucherCard(
          discount: '20% OFF',
          title: 'GP Consultation',
          code: 'HEC-V002-2025',
          expiryLabel: 'Valid until 25 Jul 2025',
          gradient: const [Color(0xFF131C3C), Color(0xFF3B8DFF)],
          onUse: () => _showVoucherQR(context, 'HEC-V002-2025', '20% OFF', 'GP Consultation'),
        ),
        const SizedBox(height: AppSpacing.space12),
        _ClaimedVoucherCard(
          discount: 'FREE',
          title: 'Blood Pressure Check',
          code: 'HEC-V003-2025',
          expiryLabel: 'Valid until 01 Aug 2025',
          gradient: const [Color(0xFF27F5A3), Color(0xFF2868F5)],
          onUse: () => _showVoucherQR(context, 'HEC-V003-2025', 'FREE', 'Blood Pressure Check'),
        ),
      ],
    );
  }

  Widget _buildExpiredTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        _ExpiredVoucherCard(
          discount: 'RM 20 OFF',
          title: 'Pharmacy Purchase',
          usedDate: 'Used on 10 Jun 2025',
        ),
        const SizedBox(height: AppSpacing.space12),
        _ExpiredVoucherCard(
          discount: '10% OFF',
          title: 'Flu Vaccination',
          usedDate: 'Expired on 01 Jun 2025',
        ),
      ],
    );
  }

  void _showVoucherQR(BuildContext context, String code, String discount, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppSpacing.space16),
        padding: const EdgeInsets.all(AppSpacing.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              'Show at Counter',
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              '$discount — $title',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            // QR Code placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.radiusMD),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Show this to the staff at the counter',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusXL),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedVoucherCard extends StatelessWidget {
  final String discount;
  final String title;
  final String code;
  final String expiryLabel;
  final List<Color> gradient;
  final VoidCallback onUse;

  const _ClaimedVoucherCard({
    required this.discount,
    required this.title,
    required this.code,
    required this.expiryLabel,
    required this.gradient,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUse,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radiusLG),
                  bottomLeft: Radius.circular(AppRadius.radiusLG),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(expiryLabel, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.qr_code_rounded, color: AppColors.accent, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredVoucherCard extends StatelessWidget {
  final String discount;
  final String title;
  final String usedDate;

  const _ExpiredVoucherCard({
    required this.discount,
    required this.title,
    required this.usedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
              ),
              alignment: Alignment.center,
              child: Text(
                discount,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(usedDate, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
