import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';

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
  final List<_PackageData> _packages = [];

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
      await Future.delayed(const Duration(milliseconds: 800));
      _packages.clear();
      _packages.addAll(_generateMockPackages());
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<_PackageData> _generateMockPackages() {
    return [
      _PackageData(
        name: 'Pemeriksaan Kesihatan Asas',
        description: 'Pemeriksaan fizikal lengkap, ujian darah, ujian air kencing, dan konsultasi doktor.',
        price: 'RM 99',
        imageUrl: 'https://via.placeholder.com/400x180/3B8DFF/FFFFFF?text=Pemeriksaan+Asas',
      ),
      _PackageData(
        name: 'Pemeriksaan Kesihatan Komprehensif',
        description: 'Termasuk ujian darah lengkap, ujian fungsi hati & buah pinggang, ECG, X-Ray dada, dan konsultasi.',
        price: 'RM 299',
        imageUrl: 'https://via.placeholder.com/400x180/27F5A3/131C3C?text=Pemeriksaan+Komprehensif',
      ),
      _PackageData(
        name: 'Pakej Vaksinasi',
        description: 'Vaksinasi Influenza, Hepatitis B, Tetanus, dan konsultasi vaksinasi.',
        price: 'RM 199',
        imageUrl: 'https://via.placeholder.com/400x180/F5A623/131C3C?text=Pakej+Vaksinasi',
      ),
      _PackageData(
        name: 'Pakej Saringan Wanita',
        description: 'Pap Smear, ultrasound pelvis, pemeriksaan payudara, dan konsultasi pakar.',
        price: 'RM 249',
        imageUrl: 'https://via.placeholder.com/400x180/F54636/FFFFFF?text=Saringan+Wanita',
      ),
    ];
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
            boxShadow: [AppShadows.shadowLow],
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
        onBack: () {},
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Could not load packages',
        subtitle: _errorMessage,
        onRetry: _loadInitialData,
      );
    }

    if (_packages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(children: [_buildEmpty()]),
      );
    }

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final pkg = _packages[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                boxShadow: [AppShadows.shadowLow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.radiusLG),
                      topRight: Radius.circular(AppRadius.radiusLG),
                    ),
                    child: Image.network(
                      pkg.imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: isDark ? AppColors.surfaceDark : AppColors.divider,
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.name,
                          style: AppTextStyles.heading3.copyWith(color: titleColor),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          pkg.description,
                          style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          pkg.price,
                          style: AppTextStyles.heading2.copyWith(color: AppColors.accent),
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

class _PackageData {
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  _PackageData({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}
