import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../services/branding_service.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar._({
    required this.leading,
    required this.titleWidget,
    required this.trailing,
    required this.backgroundColor,
  });

  factory AppAppBar.main({
    VoidCallback? onNotificationTap,
    int notificationCount = 0,
  }) {
    return AppAppBar._(
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.space16),
        child: Image.asset(
          'assets/images/logo.png',
          height: 32,
          width: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.space8),
                Text(
                  BrandingService.instance.appName,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titleWidget: const SizedBox.shrink(),
      backgroundColor: AppColors.primary,
      trailing: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.space16),
        child: GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      notificationCount > 99
                          ? '99+'
                          : notificationCount.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  factory AppAppBar.sub({
    required String title,
    VoidCallback? onBack,
    Widget? trailing,
  }) {
    return AppAppBar._(
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.space4),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.primary,
          ),
          onPressed: onBack ?? () {},
        ),
      ),
      titleWidget: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.primary,
        ),
      ),
      backgroundColor: AppColors.scaffoldBg,
      trailing: trailing != null
          ? Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space16),
              child: trailing,
            )
          : null,
    );
  }

  final Widget leading;
  final Widget titleWidget;
  final Widget? trailing;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = isDark
        ? (backgroundColor == AppColors.scaffoldBg
            ? AppColors.scaffoldBgDark
            : backgroundColor)
        : backgroundColor;

    return Container(
      color: effectiveBg,
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Center(
              child: DefaultTextStyle(
                style: AppTextStyles.heading3,
                child: titleWidget,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
