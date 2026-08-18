import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

/// Modern Draggable Bottom Sheet with smooth animations
class ModernBottomSheet extends StatefulWidget {
  const ModernBottomSheet({
    required this.child,
    this.title,
    this.maxHeight = 0.85,
    this.minHeight = 0.3,
    this.showHandle = true,
    this.backgroundColor,
    this.onDismiss,
  });

  final Widget child;
  final String? title;
  final double maxHeight; // Maximum height as fraction of screen
  final double minHeight; // Minimum height as fraction of screen
  final bool showHandle;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    double? maxHeight,
    double? minHeight,
    bool showHandle = true,
    VoidCallback? onDismiss,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: MediaQuery.of(context).size.height * 0.4,
        minChildSize: MediaQuery.of(context).size.height * minHeight,
        maxChildSize: MediaQuery.of(context).size.height * (maxHeight ?? 0.85),
        buildBackdrop: (context) => Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, scrollController) => ModernBottomSheet(
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            children: [child],
          ),
          title: title,
          maxHeight: maxHeight ?? 0.85,
          minHeight: minHeight ?? 0.3,
          showHandle: showHandle,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  @override
  State<ModernBottomSheet> createState() => _ModernBottomSheetState();
}

class _ModernBottomSheetState extends State<ModernBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surface),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.showHandle) ...[
            const SizedBox(height: AppSpacing.space12),
            _buildHandle(isDark),
            const SizedBox(height: AppSpacing.space8),
          ],
          if (widget.title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                0,
                AppSpacing.space16,
                8,
              ),
              child: Text(
                widget.title!,
                style: AppTextStyles.heading2.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
          ],
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Scaffold.of(context).pop();
        },
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// Helper function to show quick bottom sheet
Future<T?> showSimpleBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
}) {
  return ModernBottomSheet.show<T>(
    context,
    child: child,
    title: title,
  );
}
