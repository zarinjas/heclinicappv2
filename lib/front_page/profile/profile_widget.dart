import '/backend/api_requests/api_calls.dart';
import '/component/notification_setting/notification_setting_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/theme/app_theme.dart';
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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

  Widget _buildAvatar(String? avatarUrl) {
    return Container(
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 2.0,
        ),
      ),
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
                imageUrl: avatarUrl,
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final name = FFAppState().name;
    final initials = name.isNotEmpty
        ? name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join().toUpperCase()
        : '?';
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildSectionRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          height: 52.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: const [AppShadows.low],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 22.0),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 22.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 8.0,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return WebViewAware(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 28.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Are you sure?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          minimumSize: const Size(0, 48.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textInverse,
                          minimumSize: const Size(0, 48.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          elevation: 0.0,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _performLogout(context);
      }
    });
  }

  Future<void> _performLogout(BuildContext context) async {
    await actions.logout();
    if (context.mounted) {
      context.goNamed(LoginPageWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final appState = FFAppState();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: FutureBuilder<String?>(
                    future: _fetchAvatarUrl(),
                    builder: (context, snapshot) {
                      return Row(
                        children: [
                          _buildAvatar(snapshot.data),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.name.isNotEmpty
                                      ? appState.name
                                      : 'User',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  appState.userEmail.isNotEmpty
                                      ? appState.userEmail
                                      : 'No email',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  appState.nationalman.isNotEmpty
                                      ? appState.nationalman
                                      : 'No NRIC',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionHeader('My Details'),
                _buildSectionRow(
                  context: context,
                  label: 'Edit Profile',
                  icon: Icons.person_outline_rounded,
                  onTap: () {
                    context.pushNamed(
                      ProfileEditPageWidget.routeName,
                      queryParameters: {
                        'idplato': serializeParam(
                          appState.idplato,
                          ParamType.String,
                        ),
                      }.withoutNulls,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSectionHeader('Settings'),
                _buildSectionRow(
                  context: context,
                  label: 'Biometric Login',
                  icon: Icons.fingerprint,
                  onTap: () {
                    context.pushNamed(
                      BiometricSetupPageWidget.routeName,
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appState.fingerprint || appState.faceid
                            ? 'ON'
                            : 'OFF',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 22.0,
                      ),
                    ],
                  ),
                ),
                _buildSectionRow(
                  context: context,
                  label: 'Notification Preferences',
                  icon: Icons.notifications_outlined,
                  onTap: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return WebViewAware(
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: const NotificationSettingWidget(),
                            ),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  },
                ),
                _buildSectionRow(
                  context: context,
                  label: 'Change Password',
                  icon: Icons.lock_outline_rounded,
                  onTap: () {
                    context.pushNamed(ChangePasswordWidget.routeName);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSectionHeader('About'),
                _buildSectionRow(
                  context: context,
                  label: 'He Clinic Info',
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    context.pushNamed(HemedInfoWidget.routeName);
                  },
                ),
                _buildSectionRow(
                  context: context,
                  label: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () async {
                    await launchURL('https://hemedicalapps.com/term.html');
                  },
                ),
                _buildSectionRow(
                  context: context,
                  label: 'Terms of Service',
                  icon: Icons.description_outlined,
                  onTap: () async {
                    await launchURL('https://hemedicalapps.com/term.html');
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textInverse,
                        minimumSize: const Size(double.infinity, 52.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        elevation: 0.0,
                      ),
                      child: const Text('Log Out'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
