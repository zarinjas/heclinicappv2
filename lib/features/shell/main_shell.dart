import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/services/branding_service.dart';
import '/core/widgets/floating_bottom_nav.dart';
import '/features/home/home_screen.dart';
import '/pages/appointments/appointments_screen.dart';
import '/features/health/health_screen.dart';
import '/features/notifications/notifications_screen.dart';
import '/front_page/profile/profile_widget.dart';

class MainShell extends StatefulWidget {
  final String? initialTab;

  const MainShell({super.key, this.initialTab});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentTab;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _tabKeys = [
    'HomepageNew',
    'myBookingPage',
    'health',
    'notificationPage',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTab;
    final idx = tab != null ? _tabKeys.indexOf(tab as String) : -1;
    _currentTab = idx >= 0 ? idx : 0;
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    context.watch<FFAppState>();
    final state = FFAppState();
    final unreadCount = int.tryParse(state.coutnnotif) ?? 0;
    final userName = state.name.isNotEmpty ? state.name : null;
    final userInitials = _getInitials(userName);
    final userEmail = state.userEmail;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      extendBody: true,
      drawer: _buildDrawer(context, userName ?? '', userInitials, userEmail),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: const [
              HomeScreen(),
              AppointmentsScreenWidget(),
              HealthScreen(),
              NotificationsScreen(),
              ProfileWidget(),
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
                  badgeVisible: unreadCount > 0,
                  onTap: (i) => setState(() => _currentTab = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    String userName,
    String userInitials,
    String userEmail,
  ) {
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
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: ['sans-serif'],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    userName.isNotEmpty ? userName : 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail.isNotEmpty ? userEmail : '',
                    style: const TextStyle(
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
              _tryPushNamed(GoRouter.of(context), '/telehealth', context);
            },
          ),
          _drawerItem(
              icon: Icons.confirmation_num_outlined,
              label: 'Vouchers & Deals',
              onTap: () {
                Navigator.pop(context);
                _tryPushNamed(GoRouter.of(context), '/vouchers', context);
              },
            ),
            _drawerItem(
              icon: Icons.star_outline_rounded,
              label: 'My Points',
              onTap: () {
                Navigator.pop(context);
                _tryPushNamed(GoRouter.of(context), '/my-points', context);
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
              label: 'About ${BrandingService.instance.appName}',
              onTap: () {
                Navigator.pop(context);
                _tryPushNamed(GoRouter.of(context), '/clinic-info', context);
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.space16),
              child: Text(
                'v0.3.7',
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

  void _tryPushNamed(GoRouter router, String routeName, BuildContext ctx) {
    try {
      router.pushNamed(routeName);
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Coming soon'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
