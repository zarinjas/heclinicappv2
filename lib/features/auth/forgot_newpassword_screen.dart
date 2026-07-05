import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';

class ForgotNewpasswordScreen extends StatefulWidget {
  const ForgotNewpasswordScreen({super.key});

  static String routeName = 'ForgotNewpasswordScreen';
  static String routePath = '/forgotNewPassword';

  @override
  State<ForgotNewpasswordScreen> createState() =>
      _ForgotNewpasswordScreenState();
}

class _ForgotNewpasswordScreenState extends State<ForgotNewpasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _apiError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final result = await MedicalAppsApiGroup.changepasswordCall.call();

      if (!mounted) return;

      if (result.succeeded) {
        if (mounted) {
          await AppDialog.success(
            context,
            title: 'Password Reset',
            message: 'Your password has been reset successfully.',
            buttonLabel: 'Login',
            onDone: () {
              if (mounted) {
                context.go('/login');
              }
            },
          );
        }
      } else {
        setState(() {
          _apiError = result.bodyText.isNotEmpty
              ? result.bodyText
              : 'Failed to reset password. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiError = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _apiError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Set New Password',
        onBack: () => context.go('/forgotOtp'),
      ),
      body: SafeArea(
        child: _apiError != null
            ? _buildErrorState(isDark)
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return AppErrorState(
      title: 'Password Reset Failed',
      subtitle: _apiError!,
      onRetry: _retry,
    );
  }

  Widget _buildForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space32),
            Text(
              'Set New Password',
              style: AppTextStyles.heading1.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Enter your new password below.',
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AppInput(
              controller: _passwordController,
              label: 'New Password',
              placeholder: 'Min. 8 characters',
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Reset Password',
              onPressed: _resetPassword,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}
