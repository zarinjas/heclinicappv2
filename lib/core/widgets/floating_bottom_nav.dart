import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool showBadge;

  const FloatingNavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    this.showBadge = false,
  });
}

const kDefaultNavItems = <FloatingNavItem>[
  FloatingNavItem(
    icon: Icons.home_outlined,
    iconActive: Icons.home_rounded,
    label: 'Home',
  ),
  FloatingNavItem(
    icon: Icons.calendar_today_outlined,
    iconActive: Icons.calendar_today_rounded,
    label: 'Visits',
  ),
  FloatingNavItem(
    icon: Icons.favorite_border_rounded,
    iconActive: Icons.favorite_rounded,
    label: 'Health',
  ),
  FloatingNavItem(
    icon: Icons.notifications_outlined,
    iconActive: Icons.notifications_rounded,
    label: 'Alerts',
    showBadge: true,
  ),
  FloatingNavItem(
    icon: Icons.person_outline_rounded,
    iconActive: Icons.person_rounded,
    label: 'Profile',
  ),
];

class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = kDefaultNavItems,
    this.badgeVisible = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;
  final bool badgeVisible;

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33131C3C),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.items.length, (i) {
          final item = widget.items[i];
          final active = i == widget.currentIndex;
          return _NavButton(
            item: item,
            active: active,
            showBadge: item.showBadge && widget.badgeVisible,
            onTap: () => widget.onTap(i),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.showBadge,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool active;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? item.iconActive : item.icon,
                  color: active ? AppColors.accent : Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
