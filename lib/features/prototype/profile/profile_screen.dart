import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = false;

  void _showBiometricDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable biometric login?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _biometricEnabled = true);
              Navigator.pushNamed(context, '/biometric');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (_) => false,
              );
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AppSpacing.space24),
            _buildSection('My Details'),
            _buildDetailsTile(context),
            _buildSection('Settings'),
            _buildBiometricTile(),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              route: '/notification-prefs',
            ),
            _buildSettingsTile(
              icon: Icons.lock_outlined,
              title: 'Change Password',
              route: '/change-password',
            ),
            _buildSection('About'),
            _buildSettingsTile(
              icon: Icons.info_outlined,
              title: 'He Clinic Info',
              route: '/clinic-info',
            ),
            _buildSettingsTile(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              route: '/privacy',
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              route: '/terms',
            ),
            const SizedBox(height: AppSpacing.space24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space20,
              ),
              child: AppButton.destructive(
                label: 'Log Out',
                onPressed: _showLogoutDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accentBlue],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'AR',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Alia Rahman',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              'alia@example.com',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'NRIC: 900101-14-1234',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppButton(
              label: 'Edit Profile',
              variant: AppButtonVariant.whiteSolid,
              onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: SectionHeader(title: title),
    );
  }

  Widget _buildDetailsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person_outline, color: AppColors.accent),
      title: const Text('Personal Information'),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: () => Navigator.pushNamed(context, '/edit-profile'),
    );
  }

  Widget _buildBiometricTile() {
    return ListTile(
      leading: const Icon(Icons.fingerprint, color: AppColors.accent),
      title: const Text('Biometric Login'),
      trailing: Switch(
        value: _biometricEnabled,
        activeColor: AppColors.accent,
        onChanged: (value) {
          if (value) {
            _showBiometricDialog();
          } else {
            setState(() => _biometricEnabled = false);
          }
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
