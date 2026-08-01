import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/loyalty_card.dart';
import '../../core/widgets/transaction_item.dart';
import 'redeem_points_sheet.dart';

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  static const _balance = 2450;
  String _activeFilter = 'All';

  static const _allTransactions = [
    _PT(desc: 'Earned from visit', date: '14 Jul 2025', pts: 245, type: TransactionType.earned),
    _PT(desc: 'Redeemed at TTDI', date: '01 Jul 2025', pts: -100, type: TransactionType.redeemed),
    _PT(desc: 'Earned from visit', date: '15 Jun 2025', pts: 380, type: TransactionType.earned),
    _PT(desc: 'Points expired', date: '01 Jan 2025', pts: -50, type: TransactionType.expired),
    _PT(desc: 'Earned from visit', date: '20 Dec 2024', pts: 520, type: TransactionType.earned),
    _PT(desc: 'Welcome bonus', date: '01 Dec 2024', pts: 100, type: TransactionType.earned),
  ];

  List<_PT> get _filtered {
    switch (_activeFilter) {
      case 'Earned': return _allTransactions.where((t) => t.type == TransactionType.earned).toList();
      case 'Redeemed': return _allTransactions.where((t) => t.type == TransactionType.redeemed).toList();
      case 'Expired': return _allTransactions.where((t) => t.type == TransactionType.expired).toList();
      default: return _allTransactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'My Points', onBack: () {}),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoyaltyCard(
              pointsBalance: _balance, tier: LoyaltyTier.gold,
              showProgress: true, progressValue: 2450 / 3000,
              progressLabel: '550 pts to Platinum tier', variant: LoyaltyCardVariant.full,
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Redeem Points (min. 100 pts)',
              onPressed: () => RedeemPointsSheet.show(context, _balance),
              isFullWidth: true,
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Earned', 'Redeemed', 'Expired'].map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: f, type: AppChipType.filter,
                      isSelected: _activeFilter == f,
                      onTap: () => setState(() => _activeFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final t = _filtered[i];
                return TransactionItem(description: t.desc, date: t.date, points: t.pts, type: t.type);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PT {
  final String desc, date;
  final int pts;
  final TransactionType type;
  const _PT({required this.desc, required this.date, required this.pts, required this.type});
}
