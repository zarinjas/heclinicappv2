import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/floating_bottom_nav.dart';
import '/core/widgets/home_header.dart';

import 'appointments/appointments_screen.dart';
import 'health/health_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import 'home/home_screen_standalone.dart';

class PrototypeShell extends StatefulWidget {
  const PrototypeShell({super.key, this.initialTab = 0});

  final int initialTab;

  static Widget startHealth() => const PrototypeShell(initialTab: 2);

  @override
  State<PrototypeShell> createState() => _PrototypeShellState();
}

class _PrototypeShellState extends State<PrototypeShell> {
  late int _currentTab;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: [
              _HomeTab(
                onSwitchToNotifications: () => setState(() => _currentTab = 3),
                onSwitchToProfile: () => setState(() => _currentTab = 4),
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const AppointmentsScreen(),
              const HealthScreen(),
              const NotificationsScreen(),
              const ProfileScreen(),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingBottomNav(
                  currentIndex: _currentTab,
                  onTap: (i) => setState(() => _currentTab = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space20,
                AppSpacing.space32,
                AppSpacing.space20,
                AppSpacing.space24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentBlue],
                      ),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: ['sans-serif'],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  const Text(
                    'Alia Rahman',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'alia@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            _drawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentTab = 0);
              },
            ),
            _drawerItem(
              icon: Icons.event_available_outlined,
              label: 'My Appointments',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentTab = 1);
              },
            ),
            _drawerItem(
              icon: Icons.favorite_outlined,
              label: 'Health',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentTab = 2);
              },
            ),
            _drawerItem(
              icon: Icons.videocam_outlined,
              label: 'Telehealth',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/telehealth');
              },
            ),
            _drawerItem(
              icon: Icons.star_outline_rounded,
              label: 'My Points',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-points');
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentTab = 4);
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            _drawerItem(
              icon: Icons.info_outline,
              label: 'About He Clinic',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/clinic-info');
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.space16),
              child: Text(
                'v0.3.7 Prototype',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamilyFallback: ['sans-serif'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamilyFallback: ['sans-serif'],
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onSwitchToNotifications;
  final VoidCallback onSwitchToProfile;
  final VoidCallback onOpenDrawer;
  const _HomeTab({
    required this.onSwitchToNotifications,
    required this.onSwitchToProfile,
    required this.onOpenDrawer,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            userInitials: 'AR',
            userName: 'Alia Rahman',
            notificationCount: 3,
            onMenuTap: widget.onOpenDrawer,
            onNotificationTap: widget.onSwitchToNotifications,
            onAvatarTap: widget.onSwitchToProfile,
          ),
          const SizedBox(height: AppSpacing.space24),
          HomeScreenContent(onNavigate: (route) => Navigator.pushNamed(context, route)),
        ],
      ),
    );
  }
}
