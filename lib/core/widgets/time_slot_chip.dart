import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class TimeSlotChip extends StatefulWidget {
  final String time;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<TimeSlotChip> createState() => _TimeSlotChipState();
}

class _TimeSlotChipState extends State<TimeSlotChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.isSelected;

    final bgColor = selected
        ? AppColors.accent
        : (isDark ? AppColors.surfaceDark : AppColors.chipFilterDefaultBg);
    final textColor = selected ? Colors.white : AppColors.chipFilterDefaultText;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.radiusSM),
            border: selected
                ? Border.all(color: AppColors.accent, width: 1)
                : Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    width: 1,
                  ),
          ),
          child: Text(
            widget.time,
            style: AppTextStyles.label.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
