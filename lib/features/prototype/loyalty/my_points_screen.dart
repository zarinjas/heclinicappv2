import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_chip.dart';
import '/core/widgets/loyalty_card.dart';
import '/core/widgets/transaction_item.dart';

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
    _PointsTransaction(description: 'Earned from visit', date: '14 Jul 2025', points: 245, type: TransactionType.earned),
    _PointsTransaction(description: 'Redeemed at TTDI', date: '01 Jul 2025', points: -100, type: TransactionType.redeemed),
    _PointsTransaction(description: 'Earned from visit', date: '15 Jun 2025', points: 380, type: TransactionType.earned),
    _PointsTransaction(description: 'Points expired', date: '01 Jan 2025', points: -50, type: TransactionType.expired),
    _PointsTransaction(description: 'Earned from visit', date: '20 Dec 2024', points: 520, type: TransactionType.earned),
    _PointsTransaction(description: 'Welcome bonus', date: '01 Dec 2024', points: 100, type: TransactionType.earned),
  ];

  List<_PointsTransaction> get _filteredTransactions {
    switch (_activeFilter) {
      case 'Earned':
        return _allTransactions.where((t) => t.type == TransactionType.earned).toList();
      case 'Redeemed':
        return _allTransactions.where((t) => t.type == TransactionType.redeemed).toList();
      case 'Expired':
        return _allTransactions.where((t) => t.type == TransactionType.expired).toList();
      default:
        return _allTransactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Points'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoyaltyCard(
              pointsBalance: _balance,
              tier: LoyaltyTier.gold,
              showProgress: true,
              progressValue: 2450 / 3000,
              progressLabel: '550 pts to Platinum tier',
              variant: LoyaltyCardVariant.full,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppButton.primary(
              label: 'Redeem Points (min. 100 pts)',
              onPressed: () => RedeemPointsSheet.show(context, _balance),
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.space24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Earned', 'Redeemed', 'Expired'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.space8),
                    child: AppChip(
                      label: filter,
                      type: AppChipType.filter,
                      isSelected: _activeFilter == filter,
                      onTap: () => setState(() => _activeFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final t = _filteredTransactions[index];
                return TransactionItem(
                  description: t.description,
                  date: t.date,
                  points: t.points,
                  type: t.type,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsTransaction {
  final String description;
  final String date;
  final int points;
  final TransactionType type;

  const _PointsTransaction({
    required this.description,
    required this.date,
    required this.points,
    required this.type,
  });
}
