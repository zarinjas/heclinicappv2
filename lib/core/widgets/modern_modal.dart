import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import 'app_button.dart';

/// Modern Modal/Dialog with smooth animations
class ModernModal extends StatelessWidget {
  const ModernModal._({required this.child, this.barrierDismissible = true});

  final Widget child;
  final bool barrierDismissible;

  static Future<bool?> confirm(
    BuildContext context, {
    String title = 'Confirm Action',
    String message = '',
    String? cancelLabel,
    String? confirmLabel,
    bool isDestructive = false,
    Color? accentColor,
  }) async {
    final Color accent = accentColor ?? AppColors.primary;

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => ModernModal._(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: _buildDialogContent(context, title, message, cancelLabel, confirmLabel, isDestructive, accent),
        ),
      ),
    );
  }

  static Widget _buildDialogContent(
    BuildContext context,
    String title,
    String message,
    String? cancelLabel,
    String? confirmLabel,
    bool isDestructive,
    Color accentColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          
          // Icon based on destructiveness
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDestructive 
                      ? AppColors.error.withValues(alpha: 0.8)
                      : accentColor.withValues(alpha: 0.8),
                  isDestructive 
                      ? AppColors.error.withValues(alpha: 0.6)
                      : accentColor.withValues(alpha: 0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDestructive ? AppColors.error : accentColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isDestructive ? Icons.warning_rounded : Icons.confirmation_num_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          
          // Title
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: AppSpacing.space24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            cancelLabel ?? 'Cancel',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDestructive ? AppColors.error : accentColor,
                        (isDestructive ? AppColors.error : accentColor).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: (isDestructive ? AppColors.error : accentColor).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            confirmLabel ?? 'Confirm',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.space20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// Alternative simple modal without confirmation
class SimpleModal extends StatelessWidget {
  const SimpleModal._({required this.child});
  final Widget child;

  static void show(BuildContext context, {required Widget child}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SimpleModal._(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Loading overlay modal
class LoadingModal {
  static OverlayEntry? _overlay;

  static void show(BuildContext context, {String message = 'Please wait...'}) {
    hide();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {}, // Prevent tap-through
        child: Container(
          color: const Color(0x66000000),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                    style: AppTextStyles.body1.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}