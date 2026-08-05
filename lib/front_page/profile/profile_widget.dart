import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/component/notification_setting/notification_setting_widget.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';
import '/custom_code/actions/index.dart' as actions;
import '/features/auth/bind_email_screen.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<String?> _fetchAvatarUrl() async {
    try {
      final response = await MedicalAppsApiGroup.profileCall.call(
        authorization: 'Bearer ${FFAppState().tokenauth}',
        accept: 'application/json',
      );
      if (response.statusCode == 200) {
        final avatar =
            MedicalAppsApiGroup.profileCall.avatar(response.jsonBody);
        if (avatar != null && avatar.isNotEmpty) {
          return 'https://hemedicalapps.com/$avatar';
        }
      }
    } catch (_) {}
    return null;
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        ),
        title: Text(
          'Are you sure?',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
        ),
        content: Text(
          'This action cannot be undone.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: AppTextStyles.button),
          ),
          AppButton.destructive(
            label: 'Log Out',
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _performLogout(context);
    });
  }

  Future<void> _performLogout(BuildContext context) async {
    await actions.logout();
    if (context.mounted) {
      // Go through the splash so logged-out users see onboarding again
      // before the login screen.
      context.goNamed(SplashScreenWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final appState = FFAppState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, appState),
              const SizedBox(height: AppSpacing.space24),
              _buildSectionHeader('My Details', isDark),
              _profileTile(
                icon: Icons.person_outline_rounded,
                label: 'Personal Information',
                onTap: () => context.pushNamed(
                  ProfileEditPageWidget.routeName,
                  queryParameters: {
                    'idplato': appState.idplato,
                  }.withoutNulls,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              _buildSectionHeader('Settings', isDark),
              _profileTile(
                icon: Icons.email_outlined,
                label: appState.userEmail.isNotEmpty
                    ? 'Email Address'
                    : 'Add Email Address',
                trailing: appState.userEmail.isNotEmpty
                    ? Text(
                        appState.userEmail,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                onTap: () => context.pushNamed(
                  BindEmailScreen.routeName,
                ),
              ),
              _profileTile(
                icon: Icons.fingerprint,
                label: 'Biometric Login',
                trailing: Text(
                  appState.fingerprint || appState.faceid ? 'ON' : 'OFF',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => context.pushNamed(
                  BiometricSetupPageWidget.routeName,
                ),
              ),
              _profileTile(
                icon: Icons.notifications_outlined,
                label: 'Notification Preferences',
                onTap: () async {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) => Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: const NotificationSettingWidget(),
                    ),
                  );
                },
              ),
              _profileTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () => context.pushNamed(
                  ChangePasswordWidget.routeName,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              _buildSectionHeader('About', isDark),
              _profileTile(
                icon: Icons.info_outline_rounded,
                label: 'He Clinic Info',
                onTap: () => context.pushNamed(HemedInfoWidget.routeName),
              ),
              _profileTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () async {
                  await launchURL('https://hemedicalapps.com/term.html');
                },
              ),
              _profileTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () async {
                  await launchURL('https://hemedicalapps.com/term.html');
                },
              ),
              const SizedBox(height: AppSpacing.space48),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                ),
                child: AppButton.destructive(
                  label: 'Log Out',
                  onPressed: () => _showLogoutConfirmation(context),
                  isFullWidth: true,
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FFAppState appState) {
    final name = appState.name.isNotEmpty ? appState.name : 'User';
    final initials = _getInitials(name);
    final email = appState.userEmail;
    final nric = appState.nationalman;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radius2XL),
          bottomRight: Radius.circular(AppRadius.radius2XL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          child: FutureBuilder<String?>(
            future: _fetchAvatarUrl(),
            builder: (context, snapshot) {
              final avatarUrl = snapshot.data;
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentBlue],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  initials,
                                  style: AppTextStyles.heading1.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (nric.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'NRIC: $nric',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space16),
                  AppButton(
                    label: 'Edit Profile',
                    variant: AppButtonVariant.whiteSolid,
                    onPressed: () => context.pushNamed(
                      ProfileEditPageWidget.routeName,
                      queryParameters: {
                        'idplato': appState.idplato,
                      }.withoutNulls,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        0,
        AppSpacing.space20,
        AppSpacing.space8,
      ),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppColors.accent, size: 22),
      title: Text(
        label,
        style: AppTextStyles.body1.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            size: 22,
          ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}
