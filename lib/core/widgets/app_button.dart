import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive, whatsapp }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.ghost,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.destructive({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.destructive,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.whatsApp({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.whatsapp,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  Color _backgroundColor() {
    final isDisabled = onPressed == null;
    if (isDisabled) return const Color(0xFFE5E7EB);
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.accent;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return AppColors.error;
      case AppButtonVariant.whatsapp:
        return AppColors.whatsappGreen;
    }
  }

  Color _foregroundColor() {
    final isDisabled = onPressed == null;
    if (isDisabled) return const Color(0xFF9CA3AF);
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.accent;
      case AppButtonVariant.ghost:
        return AppColors.accent;
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.whatsapp:
        return Colors.white;
    }
  }

  Border? _border() {
    final isDisabled = onPressed == null;
    if (isDisabled) return null;
    switch (variant) {
      case AppButtonVariant.secondary:
        return Border.all(color: AppColors.accent, width: 1.5);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final button = SizedBox(
      height: 52,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor(),
          foregroundColor: _foregroundColor(),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          ),
          side: _border(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: _foregroundColor(),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );

    return _AppButtonPressable(isDisabled: isDisabled, child: button);
  }
}

class _AppButtonPressable extends StatefulWidget {
  const _AppButtonPressable({
    required this.isDisabled,
    required this.child,
  });

  final bool isDisabled;
  final Widget child;

  @override
  State<_AppButtonPressable> createState() => _AppButtonPressableState();
}

class _AppButtonPressableState extends State<_AppButtonPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled) _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
