import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _biometricEnabled = true;

  void _handleToggle(bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable Biometric Login'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _biometricEnabled = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Biometric enabled')),
                );
              },
              child: const Text('Authenticate'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _biometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biometric Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          children: [
            const Icon(
              Icons.fingerprint,
              size: 80,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Fingerprint & Face Login',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Log in quickly and securely using your device biometrics',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            SwitchListTile(
              title: const Text('Enable Biometric Login'),
              subtitle: Text(
                'Use fingerprint or face to log in',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              value: _biometricEnabled,
              activeColor: AppColors.accent,
              onChanged: _handleToggle,
            ),
          ],
        ),
      ),
    );
  }
}
