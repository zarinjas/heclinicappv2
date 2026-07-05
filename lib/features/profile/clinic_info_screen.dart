import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/branch_card.dart';

class ClinicInfoScreen extends StatefulWidget {
  const ClinicInfoScreen({super.key});

  static String routeName = 'ClinicInfoScreen';
  static String routePath = '/clinicInfoScreen';

  @override
  State<ClinicInfoScreen> createState() => _ClinicInfoScreenState();
}

class _ClinicInfoScreenState extends State<ClinicInfoScreen> {
  bool _isLoading = true;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = 'Failed to load clinic information.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor = isDark ? Colors.white : AppColors.primary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'He Clinic Info',
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _fetchError != null
              ? AppErrorState(
                  title: 'Failed to load clinic info',
                  subtitle: _fetchError!,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.space48),
                    child: Column(
                      children: [
                        _buildHeroImage(isDark),
                        const SizedBox(height: AppSpacing.space20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildAboutSection(
                              isDark, textColor, subtitleColor, surfaceColor),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildMissionVision(
                              isDark, textColor, subtitleColor, surfaceColor),
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildSectionHeader(
                              'Our Branches', textColor),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildBranches(
                              isDark, textColor, subtitleColor, surfaceColor),
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildSectionHeader(
                              'Contact Us', textColor),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16),
                          child: _buildContactSection(
                              isDark, textColor, subtitleColor, surfaceColor),
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
          AppSkeleton.slider(),
          const SizedBox(height: AppSpacing.space20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 140),
          ),
          const SizedBox(height: AppSpacing.space16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 180),
          ),
          const SizedBox(height: AppSpacing.space20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.text(width: 120),
          ),
          const SizedBox(height: AppSpacing.space12),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 200),
          ),
          const SizedBox(height: AppSpacing.space20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.text(width: 100),
          ),
          const SizedBox(height: AppSpacing.space12),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: AppSkeleton.card(height: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_hospital,
              size: 64,
              color: Colors.white.withAlpha(178),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'He Clinic',
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Your Trusted Healthcare Partner',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.heading2.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildAboutSection(
      bool isDark, Color textColor, Color subtitleColor, Color surfaceColor) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: AppSpacing.space8),
              Text(
                'About He Clinic',
                style: AppTextStyles.heading3.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'He Clinic is a modern healthcare facility dedicated to providing comprehensive medical services to our community. Founded with a vision to deliver accessible, high-quality healthcare, we combine experienced medical professionals with state-of-the-art technology to ensure the best possible patient outcomes.',
            style: AppTextStyles.body1.copyWith(
              color: subtitleColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'Our commitment to patient-centered care means we treat every individual with respect, compassion, and personalized attention. We believe in building lasting relationships with our patients based on trust and transparency.',
            style: AppTextStyles.body1.copyWith(
              color: subtitleColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVision(
      bool isDark, Color textColor, Color subtitleColor, Color surfaceColor) {
    return Column(
      children: [
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppRadius.radiusSM),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Mission',
                      style: AppTextStyles.heading3.copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'To deliver exceptional healthcare services through innovation, compassion, and clinical excellence, empowering our patients to lead healthier lives.',
                      style: AppTextStyles.body1.copyWith(
                        color: subtitleColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppRadius.radiusSM),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Vision',
                      style: AppTextStyles.heading3.copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'To be the leading community healthcare provider, recognized for clinical excellence, patient satisfaction, and innovative healthcare solutions.',
                      style: AppTextStyles.body1.copyWith(
                        color: subtitleColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranches(
      bool isDark, Color textColor, Color subtitleColor, Color surfaceColor) {
    final branches = _branchData;
    return Column(
      children: branches.map((branch) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: BranchCard(
            name: branch['name']!,
            address: branch['address']!,
            operatingHours: branch['hours']!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection(
      bool isDark, Color textColor, Color subtitleColor, Color surfaceColor) {
    return AppCard(
      child: Column(
        children: [
          _buildContactRow(
            Icons.phone_outlined,
            'Phone',
            '+60 3-1234 5678',
            textColor,
            subtitleColor,
          ),
          const SizedBox(height: AppSpacing.space16),
          Container(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildContactRow(
            Icons.email_outlined,
            'Email',
            'info@heclinic.com',
            textColor,
            subtitleColor,
          ),
          const SizedBox(height: AppSpacing.space16),
          Container(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildContactRow(
            Icons.chat_outlined,
            'WhatsApp',
            '+60 12-345 6789',
            textColor,
            subtitleColor,
          ),
          const SizedBox(height: AppSpacing.space16),
          AppButton.whatsApp(
            label: 'WhatsApp Us',
            icon: const Icon(Icons.chat, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value,
      Color textColor, Color subtitleColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: AppSpacing.space12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.body2.copyWith(color: subtitleColor),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              value,
              style: AppTextStyles.body1.copyWith(color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, String>> get _branchData => const [
        {
          'name': 'He Clinic Main Branch',
          'address': '123 Jalan Sultan, 50000 Kuala Lumpur',
          'hours': 'Mon - Fri: 8:00 AM - 9:00 PM',
        },
        {
          'name': 'He Clinic Cheras',
          'address': '45 Jalan Cheras, 56000 Kuala Lumpur',
          'hours': 'Mon - Sat: 9:00 AM - 8:00 PM',
        },
        {
          'name': 'He Clinic Petaling Jaya',
          'address': '78 Jalan Utama, 46000 Petaling Jaya, Selangor',
          'hours': 'Mon - Sun: 8:00 AM - 10:00 PM',
        },
      ];
}
