import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/loyalty_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/transaction_item.dart';

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  static const String routeName = '/myPoints';

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  int _pointsBalance = 0;
  int _lifetimeEarned = 0;
  LoyaltyTier _tier = LoyaltyTier.standard;
  int _expiringPoints = 0;
  String? _expiryDate;

  _TransactionFilter _activeFilter = _TransactionFilter.all;

  final List<_TransactionData> _transactions = [];
  final List<_TransactionData> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _pointsBalance = 1250;
      _lifetimeEarned = 4250;
      _tier = LoyaltyTier.standard;
      _expiringPoints = 150;
      _expiryDate = '01 Aug 2025';

      _transactions.clear();
      _transactions.addAll([
        _TransactionData(
          description: 'Earned from visit',
          invoiceRef: 'Invoice #INV-20250714',
          date: '14 Jul 2025',
          points: 100,
          type: TransactionType.earned,
        ),
        _TransactionData(
          description: 'Earned from visit',
          invoiceRef: 'Invoice #INV-20250710',
          date: '10 Jul 2025',
          points: 200,
          type: TransactionType.earned,
        ),
        _TransactionData(
          description: 'Points redeemed',
          invoiceRef: 'Code HEC-A3F9-2001',
          date: '08 Jul 2025',
          points: 500,
          type: TransactionType.redeemed,
        ),
        _TransactionData(
          description: 'Points expired',
          invoiceRef: 'Monthly expiry sweep',
          date: '01 Jan 2025',
          points: 50,
          type: TransactionType.expired,
        ),
        _TransactionData(
          description: 'Earned from visit',
          invoiceRef: 'Invoice #INV-20250620',
          date: '20 Jun 2025',
          points: 450,
          type: TransactionType.earned,
        ),
      ]);

      _applyFilter();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    _filteredTransactions.clear();
    if (_activeFilter == _TransactionFilter.all) {
      _filteredTransactions.addAll(_transactions);
    } else {
      final type = _activeFilter.toTransactionType();
      if (type != null) {
        _filteredTransactions
            .addAll(_transactions.where((t) => t.type == type));
      }
    }
  }

  void _setFilter(_TransactionFilter filter) {
    if (_activeFilter == filter) return;
    setState(() {
      _activeFilter = filter;
      _applyFilter();
    });
  }

  void _onRedeemTapped() {
    Navigator.of(context).pushNamed('/redeemPoints');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppAppBar.sub(
        title: 'My Points',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? _buildSkeleton(isDark)
          : _hasError
              ? AppErrorState(
                  title: 'Failed to load points',
                  subtitle: _errorMessage,
                  onRetry: _loadInitialData,
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPointsSummaryCard(isDark),
                        const SizedBox(height: AppSpacing.space16),
                        _buildRedeemButton(),
                        if (_transactions.isEmpty)
                          _buildEmptyTransactions()
                        else ...[
                          const SizedBox(height: AppSpacing.space24),
                          _buildTransactionHistory(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPointsSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.pointsGradientStart,
            AppColors.pointsGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
        boxShadow: AppShadows.shadowMid,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTierBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),
          Center(
            child: Text(
              _formatBalance(_pointsBalance),
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Center(
            child: Text(
              'Patient Appreciation Points',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          _buildTierProgress(),
          if (_expiringPoints > 0 && _expiryDate != null) ...[
            const SizedBox(height: AppSpacing.space12),
            _buildExpiryNotice(),
          ],
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    return AppChip(
      label: _tierLabel,
      type: AppChipType.tier,
      tierVariant: _tierChipVariant,
    );
  }

  TierChipVariant get _tierChipVariant {
    switch (_tier) {
      case LoyaltyTier.standard:
        return TierChipVariant.standard;
      case LoyaltyTier.silver:
        return TierChipVariant.silver;
      case LoyaltyTier.gold:
        return TierChipVariant.gold;
    }
  }

  String get _tierLabel {
    switch (_tier) {
      case LoyaltyTier.standard:
        return 'Standard';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
    }
  }

  Widget _buildTierProgress() {
    final (nextTierLabel, targetPoints, currentForTier) = _tierProgressData();

    if (_tier == LoyaltyTier.gold) {
      return Text(
        'Maximum tier reached',
        style: AppTextStyles.body2.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      );
    }

    final progress = targetPoints > 0 ? currentForTier / targetPoints : 0.0;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$currentForTier / $targetPoints pts to $nextTierLabel',
          style: AppTextStyles.body2.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radiusSM),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ],
    );
  }

  (String, int, int) _tierProgressData() {
    switch (_tier) {
      case LoyaltyTier.standard:
        return ('Silver', 5000, _lifetimeEarned);
      case LoyaltyTier.silver:
        return ('Gold', 20000, _lifetimeEarned);
      case LoyaltyTier.gold:
        return ('Gold', 0, 0);
    }
  }

  Widget _buildExpiryNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              '$_expiringPoints points expiring on $_expiryDate',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemButton() {
    final canRedeem = _pointsBalance >= 100;

    return AppButton(
      label: canRedeem
          ? 'Redeem Points (min. 100 pts)'
          : 'Insufficient Points (min. 100 pts)',
      onPressed: canRedeem ? _onRedeemTapped : null,
      variant: AppButtonVariant.primary,
      icon: const Icon(Icons.card_giftcard, size: 20),
      isFullWidth: true,
    );
  }

  Widget _buildEmptyTransactions() {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.space32),
      child: AppEmptyState(
        icon: Icons.history,
        title: 'No points activity yet',
        subtitle:
            'Points are earned automatically when your invoice is finalized',
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Transaction History',
        ),
        const SizedBox(height: AppSpacing.space12),
        _buildFilterChips(),
        const SizedBox(height: AppSpacing.space16),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _TransactionFilter.values.map((filter) {
            final isActive = _activeFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space8),
              child: AppChip(
                label: filter.label,
                type: AppChipType.filter,
                isSelected: isActive,
                onTap: () => _setFilter(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.space24),
        child: AppEmptyState(
          icon: Icons.receipt_long,
          title: 'No transactions found',
          subtitle: 'Try selecting a different filter',
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radiusLG)),
        child: Column(
          children: [
            for (int i = 0; i < _filteredTransactions.length; i++) ...[
              TransactionItem(
                description: _filteredTransactions[i].description,
                date: _filteredTransactions[i].date,
                points: _filteredTransactions[i].points,
                type: _filteredTransactions[i].type,
              ),
              if (i < _filteredTransactions.length - 1)
                Divider(
                  height: 1,
                  color: dividerColor,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final shimmerColor =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(AppRadius.radius2XL),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(AppRadius.radiusXL),
            ),
          ),
          const SizedBox(height: AppSpacing.space32),
          for (int i = 0; i < 5; i++) ...[
            AppSkeleton.listItem(),
            if (i < 4) const SizedBox(height: AppSpacing.space4),
          ],
        ],
      ),
    );
  }

  String _formatBalance(int points) {
    if (points >= 1000) {
      final k = points / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}

enum _TransactionFilter {
  all('All'),
  earned('Earned'),
  redeemed('Redeemed'),
  expired('Expired');

  const _TransactionFilter(this.label);

  final String label;

  TransactionType? toTransactionType() {
    switch (this) {
      case _TransactionFilter.earned:
        return TransactionType.earned;
      case _TransactionFilter.redeemed:
        return TransactionType.redeemed;
      case _TransactionFilter.expired:
        return TransactionType.expired;
      case _TransactionFilter.all:
        return null;
    }
  }
}

class _TransactionData {
  final String description;
  final String? invoiceRef;
  final String? date;
  final int points;
  final TransactionType type;

  const _TransactionData({
    required this.description,
    this.invoiceRef,
    this.date,
    required this.points,
    required this.type,
  });
}
