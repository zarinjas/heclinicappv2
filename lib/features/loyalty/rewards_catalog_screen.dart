import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../backend/api_requests/loyalty_api.dart';
import '../../core/services/models/loyalty_reward.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loader.dart';
import 'reward_detail_screen.dart';

class RewardsCatalogScreen extends StatefulWidget {
  const RewardsCatalogScreen({super.key});

  static const String routeName = '/rewards';

  @override
  State<RewardsCatalogScreen> createState() => _RewardsCatalogScreenState();
}

class _RewardsCatalogScreenState extends State<RewardsCatalogScreen> {
  List<LoyaltyReward> _rewards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await LoyaltyApi.getLoyaltyRewardsCall.call();
      if (!mounted) return;

      if (response.succeeded) {
        final raw = GetLoyaltyRewardsCall.data(response.jsonBody) ?? [];
        final rewards = raw
            .whereType<Map<String, dynamic>>()
            .map(LoyaltyReward.fromJson)
            .toList();
        setState(() {
          _rewards = rewards;
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _loading = false;
          _error = 'Please login to browse rewards.';
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Unable to load rewards.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppAppBar.sub(title: 'He Rewards'),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: AppLoader());
    }

    if (_error != null) {
      return AppEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load rewards',
        subtitle: _error!,
        ctaLabel: 'Try Again',
        onCtaTap: _load,
      );
    }

    if (_rewards.isEmpty) {
      return const AppEmptyState(
        icon: Icons.card_giftcard_outlined,
        title: 'No rewards available yet',
        subtitle: 'Check back soon — new rewards are added regularly.',
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final reward = _rewards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space16),
            child: _RewardCard(
              reward: reward,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RewardDetailScreen(reward: reward),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final LoyaltyReward reward;
  final bool isDark;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
          boxShadow: AppShadows.shadowLow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: reward.imageUrl!,
                      fit: BoxFit.cover,
                    )
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          reward.name,
                          style: AppTextStyles.heading3.copyWith(color: titleColor),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        '${reward.pointsCost} pts',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    reward.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(color: secondaryColor),
                  ),
                  if (reward.stockLabel.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      reward.stockLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: reward.isOutOfStock ? AppColors.error : secondaryColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: AppSpacing.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                    ),
                    child: Text(
                      reward.ctaLabel,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
