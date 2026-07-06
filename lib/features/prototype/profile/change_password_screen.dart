import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_input.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          children: [
            AppInput(
              controller: _currentPasswordController,
              label: 'Current Password',
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _newPasswordController,
              label: 'New Password',
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              label: 'Update Password',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed!')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
