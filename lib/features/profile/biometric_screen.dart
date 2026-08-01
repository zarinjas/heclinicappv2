import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Biometric Login', onBack: () {}),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.fingerprint, size: 80, color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Fingerprint & Face Login', style: AppTextStyles.heading2.copyWith(color: tc), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Log in quickly and securely using your device biometrics',
              style: AppTextStyles.body1.copyWith(color: sc), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text('Enable Biometric Login', style: AppTextStyles.body1.copyWith(color: tc)),
              subtitle: Text('Use fingerprint or face to log in', style: AppTextStyles.body2.copyWith(color: sc)),
              value: _enabled, activeColor: AppColors.accent,
              onChanged: (v) {
                if (v) {
                  showDialog(context: context, builder: (ctx) => AlertDialog(
                    title: const Text('Enable Biometric Login'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () { Navigator.pop(ctx); setState(() => _enabled = true); }, child: const Text('Authenticate')),
                    ],
                  ));
                } else {
                  setState(() => _enabled = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
