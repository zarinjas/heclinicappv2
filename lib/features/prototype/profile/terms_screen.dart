import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space20),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms of Service',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Last updated: July 2026',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        _paragraph(
          'By downloading, installing, or using the He Clinic mobile '
          'application, you agree to be bound by these Terms of Service. '
          'If you do not agree to these terms, please do not use the '
          'application.',
        ),
        _paragraph(
          'He Medical Clinic grants you a limited, non-exclusive, '
          'non-transferable license to use the application for managing '
          'your personal healthcare appointments and records. You may not '
          'copy, modify, distribute, sell, or lease any part of the '
          'application without our prior written consent.',
        ),
        _paragraph(
          'You are responsible for maintaining the confidentiality of '
          'your account credentials and for all activities that occur '
          'under your account. You agree to notify us immediately of any '
          'unauthorised use of your account or any other breach of '
          'security.',
        ),
        _paragraph(
          'The application is intended for use by registered patients '
          'of He Medical Clinic. You agree to provide accurate, current, '
          'and complete information during the registration process and '
          'to update such information to keep it accurate and complete.',
        ),
        _paragraph(
          'While we strive to ensure that appointment scheduling and '
          'medical information displayed in the application is accurate, '
          'He Medical Clinic does not guarantee the availability of any '
          'specific time slot or doctor. In case of discrepancies, the '
          'clinic\'s official records shall prevail.',
        ),
        _paragraph(
          'He Medical Clinic shall not be liable for any indirect, '
          'incidental, or consequential damages arising from your use of '
          'the application. Our total liability for any claim arising out '
          'of or relating to these terms shall not exceed the amount paid '
          'by you for the specific service giving rise to the claim.',
        ),
        _paragraph(
          'We reserve the right to modify or discontinue the application '
          'or any of its features at any time without prior notice. We '
          'may also update these Terms of Service from time to time. '
          'Continued use of the application after any changes constitutes '
          'your acceptance of the new terms.',
        ),
        _paragraph(
          'These Terms of Service are governed by and construed in '
          'accordance with the laws of Malaysia. Any disputes arising '
          'from these terms shall be subject to the exclusive jurisdiction '
          'of the courts of Malaysia.',
        ),
        _paragraph(
          'For any questions about these Terms of Service, please contact '
          'He Medical Clinic at info@heclinic.com or visit our main '
          'branch in Taman Tun Dr Ismail during operating hours.',
        ),
      ],
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: Text(
        text,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
