import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

/// Modern Toast notification with swipe-to-dismiss and queue support
class ModernToast extends StatefulWidget {
  const ModernToast({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
  });

  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;

  @override
  State<ModernToast> createState() => _ModernToastState();
}

enum ToastType { success, error, warning, info }

class _ModernToastState extends State<ModernToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );

    _animController.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animController.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: Colors.transparent,
          child: GestureDetector(
            onPanEnd: (_) => Navigator.of(context).pop(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                0,
                AppSpacing.space16,
                AppSpacing.space12 + MediaQuery.of(context).padding.bottom,
              ),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color getProgressColor() {
      switch (widget.type) {
        case ToastType.success:
          return AppColors.success;
        case ToastType.error:
          return AppColors.error;
        case ToastType.warning:
          return AppColors.warning;
        case ToastType.info:
          return AppColors.primary;
      }
    }

    IconData getIcon() {
      switch (widget.type) {
        case ToastType.success:
          return Icons.check_circle_outline;
        case ToastType.error:
          return Icons.error_outline;
        case ToastType.warning:
          return Icons.warning_amber_rounded;
        case ToastType.info:
          return Icons.info_outline;
      }
    }

    Color getColorForType() {
      switch (widget.type) {
        case ToastType.success:
          return AppColors.success;
        case ToastType.error:
          return AppColors.error;
        case ToastType.warning:
          return AppColors.warning;
        case ToastType.info:
          return AppColors.primary;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: getColorForType().withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (_, __) {
                  return Container(
                    width: _progressAnimation.value *
                        MediaQuery.of(context).size.width *
                        0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          getColorForType(),
                          getColorForType().withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getColorForType().withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getIcon(),
                      color: getColorForType(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: AppTextStyles.body2.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.actionLabel != null && widget.onAction != null)
                          TextButton(
                            onPressed: widget.onAction!,
                            style: TextButton.styleFrom(
                              foregroundColor: getColorForType(),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(widget.actionLabel!),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
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

// Simple toast manager
class ToastManager {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    hide();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ModernToast(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );

    overlay.insert(entry);
    _currentToast = entry;
  }

  static void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }

  static void success(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(context,
        message: message, type: ToastType.success, actionLabel: actionLabel, onAction: onAction);
  }

  static void error(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(context,
        message: message, type: ToastType.error, actionLabel: actionLabel, onAction: onAction);
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(context,
        message: message, type: ToastType.warning, actionLabel: actionLabel, onAction: onAction);
  }

  static void info(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(context,
        message: message, type: ToastType.info, actionLabel: actionLabel, onAction: onAction);
  }
}