import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/package_service.dart';
import '../../core/services/models/service_package.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import 'package_detail_screen.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  static const String routeName = '/packages';

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<ServicePackage> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = PackageService.instance;
      await service.refresh();

      if (mounted) {
        setState(() {
          _packages = service.packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
          _packages = ServicePackage.fallbackList;
        });
      }
    }
  }

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            boxShadow: AppShadows.shadowLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radiusLG),
                  topRight: Radius.circular(AppRadius.radiusLG),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: shimmerColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, height: 18,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      width: double.infinity, height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Container(
                      width: 160, height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    Container(
                      width: 100, height: 22,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<String> items, bool isDark) {
    const visible = 3;
    final shown = items.take(visible).toList();
    final remaining = items.length - shown.length;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return [
      for (final item in shown)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.accent),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyles.body2.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      if (remaining > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space4),
          child: Text(
            '+$remaining more',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ];
  }

  Widget _buildEmpty() {
    return const Center(
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No packages available',
        subtitle: 'Check back later for our service packages',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Service Packages',
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError && _packages.isEmpty) {
      return AppErrorState(
        title: 'Could not load packages',
        subtitle: _errorMessage,
        onRetry: _loadPackages,
      );
    }

    if (_packages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPackages,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return RefreshIndicator(
      onRefresh: _loadPackages,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final pkg = _packages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                boxShadow: AppShadows.shadowLow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: pkg.placeholderGradient,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.radiusLG),
                        topRight: Radius.circular(AppRadius.radiusLG),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.name,
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                          ),
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
                          pkg.description,
                          style: AppTextStyles.body1.copyWith(
                            color: titleColor,
                          ),
                        ),
                        if (pkg.items.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space16),
                          Text(
                            'Includes:',
                            style: AppTextStyles.label.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          ..._buildItems(pkg.items, isDark),
                        ],
                        const SizedBox(height: AppSpacing.space16),
                        Text(
                          'Price available on request',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton.ghost(
                            label: 'Learn More',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PackageDetailScreen(package: pkg),
                                ),
                              );
                            },
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
