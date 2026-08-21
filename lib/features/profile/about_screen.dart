import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/app_info_service.dart';
import '../../core/services/branding_service.dart';
import '../../core/services/models/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_loader.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static String routeName = 'aboutApp';
  static String routePath = '/aboutApp';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  AppInfo _info = AppInfo.fallback;
  bool _loading = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await Future.wait([
      AppInfoService.instance.init(),
      _loadPackageVersion(),
    ]);
    if (mounted) setState(() {
      _info = AppInfoService.instance.info;
      _loading = false;
    });
  }

  Future<void> _loadPackageVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (_) {
      _appVersion = '';
    }
  }

  String get _version {
    if (_appVersion.isNotEmpty) return _appVersion;
    if (_info.appVersion.isNotEmpty) return _info.appVersion;
    return '1.0.1';
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email.isNotEmpty ? email : 'info@heclinic.com',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openPhone(String phone) async {
    if (phone.isEmpty) return;
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    await launchUrl(Uri.parse('tel:$digits'), mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebsite(String url) async {
    final website = url.isNotEmpty ? url : 'https://hemedicalclinic.com';
    await launchUrl(Uri.parse(website), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'About App'),
      body: _loading
          ? const Center(child: AppLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(isDark),
                  const SizedBox(height: AppSpacing.space24),
                  _buildSectionHeader('About', sc),
                  Text(
                    _info.appDescription.isNotEmpty
                        ? _info.appDescription
                        : '${_info.appName} is your trusted digital healthcare companion. '
                            'Book appointments, view health records, and stay connected '
                            'with ${_info.companyName} from the comfort of your home.',
                    style: AppTextStyles.body1.copyWith(color: tc, height: 1.6),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  _buildSectionHeader('Company Information', sc),
                  _buildInfoCard(isDark, children: [
                    _InfoRow(
                      icon: Icons.business_outlined,
                      label: 'Company Name',
                      value: _info.companyName,
                    ),
                    _InfoRow(
                      icon: Icons.language_outlined,
                      label: 'Website',
                      value: _info.website.isNotEmpty ? _info.website : 'hemedicalclinic.com',
                      isLink: true,
                      onTap: () => _openWebsite(_info.website),
                    ),
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Support Email',
                      value: _info.supportEmail,
                      isLink: true,
                      onTap: () => _openEmail(_info.supportEmail),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.space24),
                  _buildSectionHeader('Contact Information', sc),
                  _buildInfoCard(isDark, children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Support Email',
                      value: _info.supportEmail,
                      isLink: true,
                      onTap: () => _openEmail(_info.supportEmail),
                    ),
                    if (_info.phone.isNotEmpty)
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _info.phone,
                        isLink: true,
                        onTap: () => _openPhone(_info.phone),
                      ),
                    _InfoRow(
                      icon: Icons.language_outlined,
                      label: 'Website',
                      value: _info.website.isNotEmpty ? _info.website : 'hemedicalclinic.com',
                      isLink: true,
                      onTap: () => _openWebsite(_info.website),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.space24),
                  _buildSectionHeader('Resources', sc),
                  AppButton.secondary(
                    label: 'Privacy Policy',
                    icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                    onPressed: () => context.pushNamed(PrivacyScreenRoute.path),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  AppButton.secondary(
                    label: 'Terms & Conditions',
                    icon: const Icon(Icons.description_outlined, size: 18),
                    onPressed: () => context.pushNamed(TermsScreenRoute.path),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  AppButton(
                    label: 'Contact Us',
                    icon: const Icon(Icons.forward_to_inbox_outlined, size: 18),
                    onPressed: () => _openEmail(_info.supportEmail),
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  Center(
                    child: Text(
                      'Version $_version',
                      style: AppTextStyles.body2.copyWith(color: sc),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    final branding = BrandingService.instance;
    final tc = isDark ? AppColors.textPrimaryDark : Colors.white;
    final logo = branding.logoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
        vertical: AppSpacing.space32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusXL),
            child: logo != null && logo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logo,
                    width: 88,
                    height: 88,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => _LogoFallback(size: 88),
                  )
                : _LogoFallback(size: 88),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            branding.appName,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(color: tc),
          ),
          if (_info.tagline.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space4),
            Text(
              _info.tagline,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(color: Colors.white70),
            ),
          ],
          const SizedBox(height: AppSpacing.space16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space12,
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
            child: Text(
              'Version $_version',
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color sc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: sc,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isLink
        ? AppColors.accent
        : (isDark ? AppColors.textPrimaryDark : AppColors.primary);

    return InkWell(
      onTap: isLink ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.radiusMD),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    value,
                    style: AppTextStyles.body1.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isLink)
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentBlue],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.medical_services,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

/// Route names for the in-app Privacy and Terms screens.
abstract final class PrivacyScreenRoute {
  static const String path = '/privacy';
}

abstract final class TermsScreenRoute {
  static const String path = '/terms';
}
