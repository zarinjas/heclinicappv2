import 'package:app_links/app_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static String routeName = 'ProfileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingProfile = true;
  String? _avatarUrl;
  String? _profileError;

  String _fullName = '';
  String _email = '';
  String _nric = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final appState = FFAppState();

      _fullName = appState.name ?? '';
      _email = appState.useremail ?? '';
      _nric = appState.nric ?? '';
      _phone = appState.phonenumber ?? '';

      try {
        final response = await MedicalAppsApiGroup.profileCall.call(
          authorization: 'Bearer ${appState.tokenauth}',
          accept: 'application/json',
        );
        if (response.statusCode == 200) {
          final avatar =
              MedicalAppsApiGroup.profileCall.avatar(response.jsonBody);
          if (avatar != null && avatar.isNotEmpty) {
            _avatarUrl = 'https://hemedicalapps.com/$avatar';
          }
        }
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = 'Failed to load profile. Please check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await AppDialog.confirmation(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
    );

    if (confirmed != true) return;

    try {
      final appState = FFAppState();
      appState.clearTokenAuth();
      appState.setTokenAuth('');
      appState.setRefreshToken('');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refreshToken');

      if (mounted) {
        context.go('/authPage');
      }
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Failed to log out. Please try again.');
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    final appState = FFAppState();
    final prefs = await SharedPreferences.getInstance();

    if (enable) {
      appState.setFingerprint(true);
      appState.setFaceid(Platform.isIOS);
      await prefs.setBool('biometric_enabled', true);
    } else {
      appState.setFingerprint(false);
      appState.setFaceid(false);
      await prefs.setBool('biometric_enabled', false);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.primary;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.main(
        onNotificationTap: () {
          context.push('/notificationsScreen');
        },
      ),
      body: _isLoadingProfile
          ? _buildSkeleton()
          : _profileError != null
              ? AppErrorState(
                  message: _profileError!,
                  onRetry: _loadProfile,
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.space48),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.space24),
                        _buildAvatar(surfaceColor),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          _fullName.isNotEmpty ? _fullName : 'User',
                          style: AppTextStyles.heading2.copyWith(color: textColor),
                        ),
                        if (_email.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            _email,
                            style: AppTextStyles.body2.copyWith(color: subtitleColor),
                          ),
                        ],
                        if (_nric.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            _nric,
                            style: AppTextStyles.body2.copyWith(color: subtitleColor),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.space24),
                        _buildSection(
                          surfaceColor,
                          textColor,
                          subtitleColor,
                          'My Details',
                          [
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.person_outline,
                              label: 'Edit Profile',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/profileEditPage');
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        _buildSection(
                          surfaceColor,
                          textColor,
                          subtitleColor,
                          'Settings',
                          [
                            _buildBiometricTile(surfaceColor, textColor, subtitleColor),
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.notifications_outlined,
                              label: 'Notification Preferences',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/notificationPrefsScreen');
                              },
                            ),
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.lock_outline_rounded,
                              label: 'Change Password',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/changePasswordScreen');
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        _buildSection(
                          surfaceColor,
                          textColor,
                          subtitleColor,
                          'About',
                          [
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.info_outline_rounded,
                              label: 'He Clinic Info',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/clinicInfoScreen');
                              },
                            ),
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.privacy_tip_outlined,
                              label: 'Privacy Policy',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/privacyPolicyScreen');
                              },
                            ),
                            _buildTile(
                              surfaceColor,
                              textColor,
                              subtitleColor,
                              icon: Icons.description_outlined,
                              label: 'Terms of Service',
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                context.push('/termsOfServiceScreen');
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                          child: AppButton.destructive(
                            label: 'Log Out',
                            onPressed: _logout,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.space48),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space24),
          Center(
            child: AppSkeleton.circle(size: 80),
          ),
          const SizedBox(height: AppSpacing.space12),
          Center(child: AppSkeleton.text(width: 160)),
          const SizedBox(height: AppSpacing.space4),
          Center(child: AppSkeleton.text(width: 200)),
          const SizedBox(height: AppSpacing.space24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 60),
          ),
          const SizedBox(height: AppSpacing.space16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 200),
          ),
          const SizedBox(height: AppSpacing.space16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 220),
          ),
          const SizedBox(height: AppSpacing.space24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 52, borderRadius: AppRadius.radiusXL),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color surfaceColor) {
    final appState = FFAppState();
    final initials = _fullName.isNotEmpty
        ? _fullName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
        : '?';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(38),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accent.withAlpha(76),
          width: 2,
        ),
      ),
      child: _avatarUrl != null && _avatarUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: _avatarUrl!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                errorWidget: (_, __, ___) => _buildInitials(initials),
              ),
            )
          : _buildInitials(initials),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.heading1.copyWith(
          color: AppColors.accent,
          fontSize: 28,
        ),
      ),
    );
  }

  Widget _buildSection(
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
    String title,
    List<Widget> tiles,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: isDark() ? AppColors.dividerDark : AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space8,
              ),
              child: Text(
                title,
                style: AppTextStyles.heading3.copyWith(color: textColor),
              ),
            ),
            ...tiles,
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    Color surfaceColor,
    Color textColor,
    Color subtitleColor, {
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isLast)
          Divider(height: 1, color: isDark() ? AppColors.dividerDark : AppColors.divider, indent: 16, endIndent: 16),
        InkWell(
          onTap: onTap,
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.radiusLG),
                  bottomRight: Radius.circular(AppRadius.radiusLG),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 22),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body1.copyWith(color: textColor),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricTile(Color surfaceColor, Color textColor, Color subtitleColor) {
    final appState = FFAppState();
    final isBiometricOn = appState.fingerprint || appState.faceid;

    return Column(
      children: [
        Divider(height: 1, color: isDark() ? AppColors.dividerDark : AppColors.divider, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            children: [
              const Icon(Icons.fingerprint, color: AppColors.accent, size: 22),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  'Biometric Login',
                  style: AppTextStyles.body1.copyWith(color: textColor),
                ),
              ),
              Switch(
                value: isBiometricOn,
                onChanged: _toggleBiometric,
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isDark() => Theme.of(context).brightness == Brightness.dark;
}
