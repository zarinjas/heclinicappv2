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

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  static String routeName = 'TermsScreen';
  static String routePath = '/termsOfServiceScreen';

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
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
          _content = _termsText;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = 'Failed to load terms of service.');
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
      appBar: AppAppBar.sub(title: 'Terms of Service'),
      body: _isLoading
          ? _buildSkeleton()
          : _fetchError != null
              ? AppErrorState(
                  title: 'Failed to load terms of service',
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
        child: Column(
          children: [
            AppSkeleton.slider(),
            const SizedBox(height: AppSpacing.space16),
            AppSkeleton.slider(),
            const SizedBox(height: AppSpacing.space16),
            AppSkeleton.slider(),
          ],
        ),
      ),
    );
  }

  String get _termsText => '''
Terms of Service for He Clinic

These Terms of Service ("Terms") govern your use of the He Clinic mobile application, website, and services (collectively, the "Services"), provided by He Clinic ("we," "our," or "us").

By accessing or using our Services, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our Services.

1. Use of Services

Our Services are intended for individuals seeking healthcare services and information. You must be at least 18 years of age or have the consent of a parent or legal guardian to use our Services.

You agree to:
- Provide accurate, complete, and current information when creating your account
- Maintain the security and confidentiality of your account credentials
- Notify us immediately of any unauthorized use of your account
- Use the Services only for lawful purposes and in accordance with these Terms

2. Medical Disclaimer

The Services provide a platform for booking appointments, accessing medical records, and receiving healthcare-related information. The Services do not constitute medical advice, diagnosis, or treatment.

Always seek the advice of a qualified healthcare professional regarding any medical condition. In case of a medical emergency, contact emergency services immediately.

3. Appointments and Bookings

When you book an appointment through our Services:
- You agree to provide accurate information for the appointment booking
- You are responsible for attending scheduled appointments or providing adequate notice for cancellations
- We reserve the right to modify or cancel appointments as necessary
- Appointment availability is subject to change without prior notice

4. User Content

By submitting content through our Services, you grant He Clinic a non-exclusive, royalty-free license to use, reproduce, and display such content for the purpose of providing and improving our Services.

You represent that you have all necessary rights to any content you submit and that such content does not violate any third-party rights or applicable laws.

5. Intellectual Property

All content, features, and functionality of the Services, including but not limited to text, graphics, logos, icons, images, and software, are the exclusive property of He Clinic and are protected by intellectual property laws.

You may not reproduce, distribute, modify, create derivative works of, publicly display, or exploit any part of the Services without our prior written consent.

6. Third-Party Services

Our Services may contain links to third-party websites or services that are not owned or controlled by He Clinic. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party services.

7. Limitation of Liability

To the fullest extent permitted by law, He Clinic shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of or inability to use the Services.

8. Termination

We reserve the right to suspend or terminate your access to the Services at any time, with or without cause, and with or without notice. Upon termination, your right to use the Services will immediately cease.

9. Changes to Terms

We reserve the right to modify these Terms at any time. We will notify you of material changes by posting the updated Terms on this page. Your continued use of the Services after any changes constitutes acceptance of the updated Terms.

10. Governing Law

These Terms shall be governed by and construed in accordance with the laws of Malaysia. Any disputes arising from these Terms shall be subject to the exclusive jurisdiction of the courts of Malaysia.

11. Contact Information

For questions about these Terms, please contact us at:

He Clinic
Email: legal@heclinic.com
Phone: +60 3-1234 5678
Address: 123 Jalan Sultan, 50000 Kuala Lumpur, Malaysia

By using He Clinic Services, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.
''';
}
