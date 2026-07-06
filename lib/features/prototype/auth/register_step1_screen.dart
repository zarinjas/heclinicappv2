import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/step_indicator.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIndicator(currentStep: 1, totalSteps: 2),
            const SizedBox(height: AppSpacing.space24),
            AppInput(
              controller: _nameController,
              label: 'Full Name',
              placeholder: 'Alia Rahman',
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _emailController,
              label: 'Email',
              placeholder: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _phoneController,
              label: 'Phone Number',
              placeholder: '+60 12 345 6789',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _passwordController,
              label: 'Password',
              placeholder: 'Min 8 characters',
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              placeholder: 'Re-enter password',
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              label: 'Next',
              onPressed: () =>
                  Navigator.pushNamed(context, '/register2'),
            ),
          ],
        ),
      ),
    );
  }
}
