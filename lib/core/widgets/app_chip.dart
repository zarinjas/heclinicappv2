import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum AppChipType { status, filter, tier }

enum StatusChipVariant { confirmed, pending, cancelled, completed }

enum TierChipVariant { standard, silver, gold }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.type,
    this.statusVariant,
    this.tierVariant,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final AppChipType type;
  final StatusChipVariant? statusVariant;
  final TierChipVariant? tierVariant;
  final bool isSelected;
  final VoidCallback? onTap;

  Color _backgroundColor() {
    switch (type) {
      case AppChipType.status:
        switch (statusVariant!) {
          case StatusChipVariant.confirmed:
            return AppColors.chipConfirmedBg;
          case StatusChipVariant.pending:
            return AppColors.chipPendingBg;
          case StatusChipVariant.cancelled:
            return AppColors.chipCancelledBg;
          case StatusChipVariant.completed:
            return AppColors.chipCompletedBg;
        }
      case AppChipType.filter:
        return isSelected
            ? AppColors.accent
            : AppColors.chipFilterDefaultBg;
      case AppChipType.tier:
        switch (tierVariant!) {
          case TierChipVariant.standard:
            return AppColors.chipFilterDefaultBg;
          case TierChipVariant.silver:
            return const Color(0xFFF0F0F0);
          case TierChipVariant.gold:
            return AppColors.chipPendingBg;
        }
    }
  }

  Color _textColor() {
    switch (type) {
      case AppChipType.status:
        switch (statusVariant!) {
          case StatusChipVariant.confirmed:
            return AppColors.chipConfirmedText;
          case StatusChipVariant.pending:
            return AppColors.chipPendingText;
          case StatusChipVariant.cancelled:
            return AppColors.chipCancelledText;
          case StatusChipVariant.completed:
            return AppColors.chipCompletedText;
        }
      case AppChipType.filter:
        return isSelected
            ? Colors.white
            : AppColors.chipFilterDefaultText;
      case AppChipType.tier:
        switch (tierVariant!) {
          case TierChipVariant.standard:
            return AppColors.chipFilterDefaultText;
          case TierChipVariant.silver:
            return const Color(0xFF9CA3AF);
          case TierChipVariant.gold:
            return AppColors.tierGold;
        }
    }
  }

  double _height() {
    switch (type) {
      case AppChipType.status:
        return 24;
      case AppChipType.filter:
        return 32;
      case AppChipType.tier:
        return 24;
    }
  }

  EdgeInsetsGeometry _padding() {
    switch (type) {
      case AppChipType.status:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case AppChipType.filter:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
      case AppChipType.tier:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: _height(),
      padding: _padding(),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: _textColor(),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}
