import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space20),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Policy',
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
        _section(
          'Information We Collect',
          body:
              'We collect personal information that you provide to us when '
              'registering for an account, booking an appointment, or '
              'updating your profile. This includes your full name, NRIC '
              'number, contact details, date of birth, and medical history '
              'relevant to the care you receive at He Medical Clinic.',
        ),
        _section(
          'How We Use Your Data',
          body:
              'Your health information is used solely to provide medical '
              'services, schedule appointments, maintain clinical records, '
              'and communicate important updates regarding your care. We '
              'may also use anonymised data for internal quality improvement '
              'purposes and statistical analysis.',
        ),
        _section(
          'Data Storage and Security',
          body:
              'All patient records are stored on secure servers with '
              'encryption at rest and in transit. We implement strict access '
              'controls so that only authorised healthcare professionals '
              'involved in your treatment may view your information. '
              'Regular security audits are conducted to ensure compliance '
              'with the Personal Data Protection Act.',
        ),
        _section(
          'Data Sharing',
          body:
              'We do not sell or rent your personal information to third '
              'parties. Your data may be shared with partner laboratories '
              'or specialists only when necessary for your diagnosis or '
              'treatment, and always with your explicit consent. We may '
              'disclose information if required by law or to protect the '
              'vital interests of a patient.',
        ),
        _section(
          'Your Rights',
          body:
              'You have the right to access, correct, or request deletion '
              'of your personal data at any time. You may withdraw consent '
              'for data processing by contacting our Data Protection Officer. '
              'We will respond to all data requests within 14 working days '
              'in accordance with applicable regulations. If you have any '
              'concerns about how your information is handled, please reach '
              'out to our clinic administration.',
        ),
        _section(
          'Policy Updates',
          body:
              'This privacy policy may be updated from time to time to '
              'reflect changes in our practices or legal obligations. We '
              'will notify you of any material changes via email or through '
              'a notice in the app. Continued use of our services after '
              'such updates constitutes acceptance of the revised policy.',
        ),
      ],
    );
  }

  Widget _section(String title, {required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            body,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
