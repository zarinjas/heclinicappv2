import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class VouchersListScreen extends StatelessWidget {
  const VouchersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Offers & Vouchers'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/my-vouchers'),
            icon: const Icon(Icons.confirmation_num_outlined, size: 18),
            label: Text(
              'My Vouchers',
              style: AppTextStyles.label.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        children: [
          // Category filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryChip(label: 'All', isActive: true),
                SizedBox(width: 8),
                _CategoryChip(label: 'Health Check', isActive: false),
                SizedBox(width: 8),
                _CategoryChip(label: 'Consultation', isActive: false),
                SizedBox(width: 8),
                _CategoryChip(label: 'Pharmacy', isActive: false),
                SizedBox(width: 8),
                _CategoryChip(label: 'Beauty', isActive: false),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          ...kAllVouchers.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space16),
            child: _VoucherCardFull(voucher: v, onClaim: () => _showClaimDialog(context, v)),
          )),
        ],
      ),
    );
  }

  void _showClaimDialog(BuildContext context, VoucherData voucher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        ),
        title: Text(
          'Claim Voucher',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: voucher.gradient),
                borderRadius: BorderRadius.circular(AppRadius.radiusMD),
              ),
              child: Row(
                children: [
                  Text(
                    voucher.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      voucher.title,
                      style: AppTextStyles.body2.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'This voucher will be saved to My Vouchers.\nShow it at the counter to redeem.',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radiusXL),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Voucher claimed! Check My Vouchers.'),
                        backgroundColor: AppColors.primary,
                        action: SnackBarAction(
                          label: 'View',
                          textColor: AppColors.accent,
                          onPressed: () => Navigator.pushNamed(context, '/my-vouchers'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Claim', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _CategoryChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.chipFilterDefaultBg,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: isActive ? Colors.white : AppColors.chipFilterDefaultText,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _VoucherCardFull extends StatelessWidget {
  final VoucherData voucher;
  final VoidCallback onClaim;
  const _VoucherCardFull({required this.voucher, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: voucher.gradient,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (voucher.isLimited)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Limited Offer',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      voucher.discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        fontFamilyFallback: ['sans-serif'],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voucher.title,
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.description,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Expires ${voucher.expiryLabel}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClaim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: Text(
                          'Claim',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VOUCHER DATA
// ============================================================================

class VoucherData {
  final String id;
  final String discount;
  final String title;
  final String description;
  final String category;
  final String expiryLabel;
  final List<Color> gradient;
  final bool isLimited;

  const VoucherData({
    required this.id,
    required this.discount,
    required this.title,
    required this.description,
    required this.category,
    required this.expiryLabel,
    required this.gradient,
    this.isLimited = false,
  });
}

const kAllVouchers = <VoucherData>[
  VoucherData(
    id: 'V001',
    discount: 'RM 30 OFF',
    title: 'Basic Health Screening',
    description: 'Get RM 30 off your basic health screening package. Includes blood test, urine test, and BMI check.',
    category: 'Health Check',
    expiryLabel: 'in 3 days',
    gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
    isLimited: true,
  ),
  VoucherData(
    id: 'V002',
    discount: '20% OFF',
    title: 'GP Consultation',
    description: 'Enjoy 20% off your next GP consultation at any He Clinic branch.',
    category: 'Consultation',
    expiryLabel: 'in 7 days',
    gradient: [Color(0xFF131C3C), Color(0xFF3B8DFF)],
  ),
  VoucherData(
    id: 'V003',
    discount: 'FREE',
    title: 'Blood Pressure Check',
    description: 'Complimentary blood pressure screening. Walk in to any branch, no appointment needed.',
    category: 'Health Check',
    expiryLabel: 'in 14 days',
    gradient: [Color(0xFF27F5A3), Color(0xFF2868F5)],
  ),
  VoucherData(
    id: 'V004',
    discount: 'RM 50 OFF',
    title: 'Comprehensive Health Check',
    description: 'Save RM 50 on the Comprehensive Health Check package. Full blood work, ECG, and doctor consultation.',
    category: 'Health Check',
    expiryLabel: 'in 5 days',
    gradient: [Color(0xFFF5A623), Color(0xFFF54636)],
    isLimited: true,
  ),
  VoucherData(
    id: 'V005',
    discount: '15% OFF',
    title: 'Dermatology Visit',
    description: 'First-time dermatology consultation with Dr. Tan Wei Ming at a discounted rate.',
    category: 'Consultation',
    expiryLabel: 'in 10 days',
    gradient: [Color(0xFF2868F5), Color(0xFF131C3C)],
  ),
  VoucherData(
    id: 'V006',
    discount: 'RM 20 OFF',
    title: 'Pharmacy Purchase',
    description: 'RM 20 off on pharmacy purchases above RM 100 at any He Clinic branch.',
    category: 'Pharmacy',
    expiryLabel: 'in 21 days',
    gradient: [Color(0xFF1D2B5F), Color(0xFF27F5A3)],
  ),
];
