import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog._({required this.child, this.barrierDismissible = true});

  final Widget child;
  final bool barrierDismissible;

  static Future<bool?> confirm(
    BuildContext context, {
    String title = 'Are you sure?',
    String message = '',
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog._(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    message,
                    style: AppTextStyles.body1.copyWith(color: secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.space24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.ghost(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(false),
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: isDestructive
                          ? AppButton.destructive(
                              label: confirmLabel,
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              isFullWidth: true,
                            )
                          : AppButton.primary(
                              label: confirmLabel,
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              isFullWidth: true,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> success(
    BuildContext context, {
    String title = 'Done!',
    String message = '',
    String buttonLabel = 'OK',
    VoidCallback? onDone,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AppDialog._(
          child: _AnimatedCheckmarkDialog(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      message,
                      style:
                          AppTextStyles.body1.copyWith(color: secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    label: buttonLabel,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDone?.call();
                    },
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static OverlayEntry? _loadingOverlay;

  static void loading(BuildContext context, {String message = 'Please wait…'}) {
    hideLoading(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    _loadingOverlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: const Color(0x66000000),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space32,
                vertical: AppSpacing.space24,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius:
                    BorderRadius.circular(AppRadius.radiusXL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    message,
                    style:
                        AppTextStyles.body1.copyWith(color: secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_loadingOverlay!);
  }

  static void hideLoading(BuildContext context) {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  static void redemptionCode(
    BuildContext context, {
    required String code,
    required double discount,
    String instructions = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AppDialog._(
          child: _AnimatedCheckmarkDialog(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Your Redemption Code',
                    style: AppTextStyles.heading3.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppRadius.radiusMD),
                      border: Border.all(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      code,
                      style: AppTextStyles.heading1.copyWith(
                        color: textColor,
                        fontFamily: 'monospace',
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    'RM ${discount.toStringAsFixed(2)} discount',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (instructions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      instructions,
                      style:
                          AppTextStyles.body2.copyWith(color: secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    label: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space32,
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  BorderRadius.circular(AppRadius.radiusXL),
              boxShadow: AppShadows.shadowHigh,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckmarkDialog extends StatefulWidget {
  const _AnimatedCheckmarkDialog({required this.child});

  final Widget child;

  @override
  State<_AnimatedCheckmarkDialog> createState() =>
      _AnimatedCheckmarkDialogState();
}

class _AnimatedCheckmarkDialogState extends State<_AnimatedCheckmarkDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space8),
          const Icon(
            Icons.check_circle,
            size: 64,
            color: AppColors.accent,
          ),
          widget.child,
        ],
      ),
    );
  }
}
