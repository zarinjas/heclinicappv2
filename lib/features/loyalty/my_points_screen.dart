import 'package:flutter/material.dart';

import '../../backend/api_requests/loyalty_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/loyalty_card.dart';
import '../../core/widgets/transaction_item.dart';
import 'redeem_points_sheet.dart';

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  int _balance = 0;
  double _redemptionRate = 0.05;
  int _minRedemption = 100;
  String _activeFilter = 'All';
  List<_PT> _transactions = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final balanceResponse = await LoyaltyApi.getLoyaltyBalanceCall.call();
      final txnResponse = await LoyaltyApi.getLoyaltyTransactionsCall.call(
        type: _apiTypeForFilter(_activeFilter),
      );

      if (!mounted) return;

      setState(() {
        _balance = GetLoyaltyBalanceCall.balance(balanceResponse.jsonBody) ?? 0;
        _redemptionRate =
            GetLoyaltyBalanceCall.redemptionRate(balanceResponse.jsonBody) ??
                _redemptionRate;
        _minRedemption =
            GetLoyaltyBalanceCall.minRedemption(balanceResponse.jsonBody) ??
                _minRedemption;
        _transactions = _parseTransactions(txnResponse.jsonBody);
        _loading = false;
        _error = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String _apiTypeForFilter(String filter) {
    switch (filter) {
      case 'Earned':
        return 'earn';
      case 'Redeemed':
        return 'redeem';
      case 'Expired':
        return 'expire';
      default:
        return '';
    }
  }

  List<_PT> _parseTransactions(dynamic jsonBody) {
    final types = GetLoyaltyTransactionsCall.types(jsonBody) ?? [];
    final points = GetLoyaltyTransactionsCall.points(jsonBody) ?? [];
    final refs = GetLoyaltyTransactionsCall.invoiceRefs(jsonBody) ?? [];
    final reasons = GetLoyaltyTransactionsCall.reasons(jsonBody) ?? [];
    final dates = GetLoyaltyTransactionsCall.createdAt(jsonBody) ?? [];

    final result = <_PT>[];
    final count = types.length;
    for (var i = 0; i < count; i++) {
      final type = types.length > i ? types[i] : '';
      final pts = points.length > i ? points[i] : 0;
      final ref = refs.length > i ? refs[i] : '';
      final reason = reasons.length > i ? reasons[i] : '';
      final date = dates.length > i ? dates[i] : '';

      final (TransactionType txnType, String desc) = _mapType(type, pts, ref, reason);

      result.add(_PT(
        desc: desc,
        date: _formatDate(date),
        pts: pts,
        type: txnType,
      ));
    }
    return result;
  }

  (TransactionType, String) _mapType(String type, int pts, String ref, String reason) {
    switch (type) {
      case 'earn':
        return (
          TransactionType.earned,
          ref.isNotEmpty ? 'Earned · $ref' : 'Earned from visit',
        );
      case 'redeem':
        return (
          TransactionType.redeemed,
          reason.isNotEmpty ? 'Redeemed · $reason' : 'Redeemed at counter',
        );
      case 'expire':
        return (TransactionType.expired, 'Points expired');
      default:
        return (
          pts >= 0 ? TransactionType.earned : TransactionType.redeemed,
          reason.isNotEmpty ? reason : 'Adjustment',
        );
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _openRedeem() async {
    final redeemed = await RedeemPointsSheet.show(
      context,
      _balance,
      redemptionRate: _redemptionRate,
      minRedemption: _minRedemption,
    );
    if (redeemed == true && mounted) {
      _load();
    }
  }

  void _onFilter(String filter) {
    setState(() => _activeFilter = filter);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'My Points', onBack: () {}),
      body: _loading
          ? _buildLoading()
          : _error
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoyaltyCardSkeleton(),
          const SizedBox(height: 16),
          AppSkeleton.card(height: 52),
          const SizedBox(height: 24),
          AppSkeleton.listItem(),
          AppSkeleton.listItem(),
          AppSkeleton.listItem(),
        ],
      ),
    );
  }

  Widget _buildError() {
    return AppEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Could not load points',
      subtitle: 'Check your connection and try again',
      ctaLabel: 'Retry',
      onCtaTap: _load,
    );
  }

  Widget _buildContent() {
    final canRedeem = _balance >= _minRedemption;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoyaltyCard(
              pointsBalance: _balance,
              showTier: false,
              showProgress: false,
              variant: LoyaltyCardVariant.full,
              onRedeem: canRedeem ? _openRedeem : null,
              onViewHistory: () {},
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Redeem Points (min. $_minRedemption pts)',
              onPressed: canRedeem ? _openRedeem : null,
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
                      label: f,
                      type: AppChipType.filter,
                      isSelected: _activeFilter == f,
                      onTap: () => _onFilter(f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: AppEmptyState(
                  icon: Icons.card_giftcard_outlined,
                  title: 'No points activity yet',
                  subtitle:
                      'Points are earned automatically when your invoice is finalized',
                ),
              )
            else
              ..._transactions.map(
                (t) => TransactionItem(
                  description: t.desc,
                  date: t.date,
                  points: t.pts,
                  type: t.type,
                ),
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
