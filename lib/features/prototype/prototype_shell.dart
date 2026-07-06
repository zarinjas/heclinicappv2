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

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: const [
              _HomeTab(),
              AppointmentsScreen(),
              HealthScreen(),
              NotificationsScreen(),
              ProfileScreen(),
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
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

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
            onMenuTap: () {},
            onNotificationTap: () {},
          ),
          const SizedBox(height: AppSpacing.space24),
          HomeScreenContent(onNavigate: (route) => Navigator.pushNamed(context, route)),
        ],
      ),
    );
  }
}
