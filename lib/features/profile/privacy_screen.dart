import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  static String routeName = 'PrivacyScreen';
  static String routePath = '/privacyPolicyScreen';

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isLoading = true;
  String? _fetchError;
  String _content = '';

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
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _content = _privacyPolicyText;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = 'Failed to load privacy policy.');
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: 'Privacy Policy'),
      body: _isLoading
          ? _buildSkeleton()
          : _fetchError != null
              ? AppErrorState(
                  title: 'Failed to load privacy policy',
                  subtitle: _fetchError!,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.space48),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.space20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Updated: July 2026',
                              style: AppTextStyles.body2.copyWith(
                                  color: subtitleColor),
                            ),
                            const SizedBox(height: AppSpacing.space16),
                            Text(
                              _content,
                              style: AppTextStyles.body1.copyWith(
                                color: textColor,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.space48),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: AppSkeleton.card(height: 600),
      ),
    );
  }

  String get _privacyPolicyText => '''
Privacy Policy for He Clinic

This Privacy Policy describes how He Clinic ("we," "our," or "us") collects, uses, and shares your personal information when you use our mobile application, website, and services (collectively, the "Services").

1. Information We Collect

Personal Information: We collect information you provide directly to us, such as your name, email address, phone number, national registration identity card (NRIC) number, date of birth, address, and medical history.

Usage Information: We automatically collect certain information about your device and how you interact with our Services, including your IP address, device type, operating system, and usage patterns.

Health Information: With your consent, we collect and store your medical records, appointment history, vital signs, laboratory results, prescriptions, and other health-related information necessary to provide our healthcare services.

2. How We Use Your Information

We use the information we collect to:
- Provide, maintain, and improve our healthcare services
- Process and manage your appointments and bookings
- Communicate with you about your appointments, medical results, and account
- Send administrative notifications, including appointment reminders
- Personalize your experience within our Services
- Comply with legal obligations and enforce our terms

3. Information Sharing

We may share your information:
- With healthcare providers and medical professionals involved in your care
- With third-party service providers who assist us in operating our Services
- As required by law or to protect rights and safety
- With your explicit consent

4. Data Security

We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data transmission is encrypted using industry-standard SSL/TLS protocols.

5. Data Retention

We retain your personal information for as long as necessary to provide our Services and comply with legal obligations. Medical records are retained in accordance with applicable healthcare regulations.

6. Your Rights

You have the right to:
- Access and obtain a copy of your personal information
- Request correction of inaccurate personal information
- Request deletion of your personal information
- Withdraw consent for processing
- Lodge a complaint with the relevant data protection authority

7. Contact Us

If you have questions about this Privacy Policy or our data practices, please contact us at:

He Clinic
Email: privacy@heclinic.com
Phone: +60 3-1234 5678
Address: 123 Jalan Sultan, 50000 Kuala Lumpur, Malaysia

8. Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date. Your continued use of our Services after any changes constitutes acceptance of the updated policy.

By using He Clinic Services, you agree to the collection and use of information in accordance with this Privacy Policy.
''';
}
