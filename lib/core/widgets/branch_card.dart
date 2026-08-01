import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum BranchCardVariant { vertical, horizontal }

class BranchCard extends StatelessWidget {
  final String name;
  final String address;
  final String? distance;
  final bool isSelected;
  final VoidCallback? onTap;
  final List<Color>? leadingGradient;
  final String? leadingLabel;
  final IconData? leadingIcon;
  final String? imageUrl;
  final BranchCardVariant variant;

  const BranchCard({
    super.key,
    required this.name,
    required this.address,
    this.distance,
    this.isSelected = false,
    this.onTap,
    this.leadingGradient,
    this.leadingLabel,
    this.leadingIcon,
    this.imageUrl,
    this.variant = BranchCardVariant.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == BranchCardVariant.horizontal) {
      return _HorizontalBranchCard(
        name: name,
        address: address,
        distance: distance,
        isSelected: isSelected,
        onTap: onTap,
        leadingGradient: leadingGradient,
        leadingLabel: leadingLabel,
        leadingIcon: leadingIcon,
        imageUrl: imageUrl,
      );
    }
    return _VerticalBranchCard(
      name: name,
      address: address,
      isSelected: isSelected,
      onTap: onTap,
      imageUrl: imageUrl,
      leadingGradient: leadingGradient,
      leadingIcon: leadingIcon,
      leadingLabel: leadingLabel,
    );
  }
}

class _VerticalBranchCard extends StatelessWidget {
  final String name;
  final String address;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? imageUrl;
  final List<Color>? leadingGradient;
  final IconData? leadingIcon;
  final String? leadingLabel;

  const _VerticalBranchCard({
    required this.name,
    required this.address,
    this.isSelected = false,
    this.onTap,
    this.imageUrl,
    this.leadingGradient,
    this.leadingIcon,
    this.leadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? AppColors.accent
        : (isDark ? AppColors.dividerDark : AppColors.divider);
    final borderWidth = isSelected ? 1.5 : 1.0;
    final bgColor = isSelected
        ? AppColors.accent.withValues(alpha: isDark ? 0.10 : 0.05)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: AppShadows.shadowLow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: _buildVerticalImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.3,
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

  Widget _buildVerticalImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildVerticalGradient(),
      );
    }
    return _buildVerticalGradient();
  }

  Widget _buildVerticalGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: leadingGradient ??
              const [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        leadingIcon ?? Icons.location_on_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _HorizontalBranchCard extends StatelessWidget {
  final String name;
  final String address;
  final String? distance;
  final bool isSelected;
  final VoidCallback? onTap;
  final List<Color>? leadingGradient;
  final String? leadingLabel;
  final IconData? leadingIcon;
  final String? imageUrl;

  const _HorizontalBranchCard({
    required this.name,
    required this.address,
    this.distance,
    this.isSelected = false,
    this.onTap,
    this.leadingGradient,
    this.leadingLabel,
    this.leadingIcon,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final borderColor = isSelected
        ? AppColors.accent
        : (isDark ? AppColors.dividerDark : AppColors.divider);
    final borderWidth = isSelected ? 1.5 : 1.0;
    final bgColor = isSelected
        ? AppColors.accent.withValues(alpha: isDark ? 0.10 : 0.05)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: AppShadows.shadowLow,
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 88,
                child: _buildLeading(),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (distance != null && distance!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              distance!,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: 88,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildLeadingGradient(),
      );
    }
    return _buildLeadingGradient();
  }

  Widget _buildLeadingGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: leadingGradient ??
              const [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              leadingIcon ?? Icons.location_on_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            leadingLabel ?? 'Branch',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class BranchCardSkeleton extends StatelessWidget {
  const BranchCardSkeleton({super.key});

  Widget _bar(BuildContext context, double width, double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(AppRadius.radiusXS),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(context, 160, 18),
          const SizedBox(height: AppSpacing.space8),
          _bar(context, 220, 13),
          const SizedBox(height: AppSpacing.space8),
          _bar(context, 140, 13),
        ],
      ),
    );
  }
}
