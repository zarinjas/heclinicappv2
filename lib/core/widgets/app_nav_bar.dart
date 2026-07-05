import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int notificationCount;

  static const _tabs = <_NavTab>[
    _NavTab(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavTab(label: 'Appointments', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today),
    _NavTab(label: 'Health', icon: Icons.favorite_outlined, activeIcon: Icons.favorite),
    _NavTab(label: 'Notifications', icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
    _NavTab(label: 'Profile', icon: Icons.person_outlined, activeIcon: Icons.person),
  ];

  static const _inactiveColor = Color(0x80FFFFFF);
  static const _notificationsTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 64 + bottomPadding,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: AppShadows.shadowNav,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: _inactiveColor,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final iconSize = 24.0;

          if (i == _notificationsTabIndex && notificationCount > 0) {
            return BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: AppColors.error,
                child: Icon(tab.icon, size: iconSize),
              ),
              activeIcon: Badge(
                backgroundColor: AppColors.error,
                child: Icon(tab.activeIcon, size: iconSize),
              ),
              label: tab.label,
            );
          }

          return BottomNavigationBarItem(
            icon: Icon(tab.icon, size: iconSize),
            activeIcon: Icon(tab.activeIcon, size: iconSize),
            label: tab.label,
          );
        }),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
