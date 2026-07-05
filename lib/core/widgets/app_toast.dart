import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppToast {
  AppToast._();

  static void success(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      leftBarColor: AppColors.toastSuccessBar,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.toastSuccessBar,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      leftBarColor: AppColors.toastErrorBar,
      icon: Icons.error_outline,
      iconColor: AppColors.toastErrorBar,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      leftBarColor: AppColors.toastWarningBar,
      icon: Icons.warning_amber,
      iconColor: AppColors.toastWarningBar,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      icon: Icons.info_outline,
      iconColor: Colors.white,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    Color? leftBarColor,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    final effectiveBg = backgroundColor ?? surface;
    final effectiveText =
        textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.primary);

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _ToastWidget(
          message: message,
          leftBarColor: leftBarColor,
          backgroundColor: effectiveBg,
          textColor: effectiveText,
          icon: icon,
          iconColor: iconColor ?? effectiveText,
          onDismiss: () {
            try {
              entry.remove();
            } catch (_) {}
          },
        );
      },
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.leftBarColor,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.onDismiss,
  });

  final String message;
  final Color? leftBarColor;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + 64 + AppSpacing.space12;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Positioned(
          left: AppSpacing.space16,
          right: AppSpacing.space16,
          bottom: bottomPadding,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child!,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius:
                BorderRadius.circular(AppRadius.radiusXL),
            boxShadow: AppShadows.shadowMid,
          ),
          clipBehavior: Clip.hardEdge,
          child: widget.leftBarColor != null
              ? Row(
                  children: [
                    Container(
                      width: 4,
                      height: double.infinity,
                      color: widget.leftBarColor,
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: _buildContent(),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                  ),
                  child: _buildContent(),
                ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: widget.iconColor),
          const SizedBox(width: AppSpacing.space8),
          Flexible(
            child: Text(
              widget.message,
              style: AppTextStyles.body2.copyWith(color: widget.textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
