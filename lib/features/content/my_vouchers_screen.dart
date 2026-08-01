import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';

class MyVouchersScreen extends StatelessWidget {
  const MyVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        appBar: AppAppBar.sub(title: 'My Vouchers'),
        body: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Used / Expired'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildActiveTab(context, isDark),
                  _buildExpiredTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClaimedCard(discount: 'RM 30 OFF', title: 'Basic Health Screening',
            code: 'HEC-V001-2025', expiry: 'Valid until 20 Jul 2025',
            gradient: const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
            isDark: isDark, context: context),
        const SizedBox(height: 12),
        _ClaimedCard(discount: '20% OFF', title: 'GP Consultation',
            code: 'HEC-V002-2025', expiry: 'Valid until 25 Jul 2025',
            gradient: const [Color(0xFF131C3C), Color(0xFF3B8DFF)],
            isDark: isDark, context: context),
        const SizedBox(height: 12),
        _ClaimedCard(discount: 'FREE', title: 'Blood Pressure Check',
            code: 'HEC-V003-2025', expiry: 'Valid until 01 Aug 2025',
            gradient: const [Color(0xFF27F5A3), Color(0xFF2868F5)],
            isDark: isDark, context: context),
      ],
    );
  }

  Widget _buildExpiredTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ExpiredCard(discount: 'RM 20 OFF', title: 'Pharmacy Purchase', used: 'Used on 10 Jun 2025', isDark: isDark),
        const SizedBox(height: 12),
        _ExpiredCard(discount: '10% OFF', title: 'Flu Vaccination', used: 'Expired on 01 Jun 2025', isDark: isDark),
      ],
    );
  }
}

class _ClaimedCard extends StatelessWidget {
  final String discount, title, code, expiry;
  final List<Color> gradient;
  final bool isDark;
  final BuildContext context;

  const _ClaimedCard({required this.discount, required this.title, required this.code, required this.expiry, required this.gradient, required this.isDark, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQR(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 100, padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radiusLG),
                  bottomLeft: Radius.circular(AppRadius.radiusLG),
                ),
              ),
              child: Center(
                child: Text(discount, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(code, style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text(expiry, style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
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

  void _showQR(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (c) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: isDark ? AppColors.dividerDark : AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Text('Show at Counter', style: AppTextStyles.heading3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
          const SizedBox(height: 4),
          Text('$discount — $title', style: AppTextStyles.body2.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(width: 200, height: 200,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.radiusMD)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.white),
              const SizedBox(height: 8),
              Text(code, style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1.5)),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.radiusSM)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Show this to the staff at the counter', style: AppTextStyles.body2.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusXL))),
              onPressed: () => Navigator.pop(c),
              child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ExpiredCard extends StatelessWidget {
  final String discount, title, used;
  final bool isDark;
  const _ExpiredCard({required this.discount, required this.title, required this.used, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM)),
              alignment: Alignment.center,
              child: Text(discount, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyles.body1.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
              const SizedBox(height: 2),
              Text(used, style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ])),
          ],
        ),
      ),
    );
  }
}
