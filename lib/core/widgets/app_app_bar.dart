import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../services/branding_service.dart';
import '../../flutter_flow/nav/nav.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar._({
    required this.leading,
    required this.titleWidget,
    required this.trailing,
    required this.backgroundColor,
    this.titleAlign = Alignment.center,
  });

  factory AppAppBar.main({
    Widget? title,
    VoidCallback? onNotificationTap,
    int notificationCount = 0,
  }) {
    final branding = BrandingService.instance;
    final appBarLogo = (branding.appBarLogoUrl ?? '').isNotEmpty
        ? branding.appBarLogoUrl
        : branding.logoUrl;

    // Always prefer the Admin Panel logo. Only fall back to the icon + app
    // name when NO remote logo is configured at all — never to a hardcoded
    // legacy asset (the remote URL is the source of truth).
    final Widget logo = appBarLogo != null && appBarLogo.isNotEmpty
        ? Image.network(
            appBarLogo,
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _LogoPlaceholder(
              appName: branding.appName,
            ),
          )
        : _LogoPlaceholder(appName: branding.appName);

    return AppAppBar._(
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.space16),
        child: logo,
      ),
      titleWidget: title ?? const SizedBox.shrink(),
      titleAlign: title != null ? Alignment.centerLeft : Alignment.center,
      backgroundColor: branding.primaryColor,
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
          onPressed: onBack ??
              () {
                final context = appNavigatorKey.currentContext;
                if (context != null) {
                  Navigator.of(context).maybePop();
                }
              },
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
  final Alignment titleAlign;

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
            child: Align(
              alignment: titleAlign,
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

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
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
          appName,
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
