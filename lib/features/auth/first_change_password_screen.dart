import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';

class FirstChangePasswordScreen extends StatefulWidget {
  const FirstChangePasswordScreen({super.key});

  static String routeName = 'FirstChangePasswordScreen';
  static String routePath = '/firstChangePassword';

  @override
  State<FirstChangePasswordScreen> createState() =>
      _FirstChangePasswordScreenState();
}

class _FirstChangePasswordScreenState extends State<FirstChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _apiError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final appState = FFAppState();
      final result =
          await MedicalAppsApiGroup.firsttimechangepasswordCall.call(
        authorization: 'Bearer ${appState.tokenauth}',
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      if (result.succeeded) {
        if (mounted) {
          appState.passwordChanged = true;
          await AppDialog.success(
            context,
            title: 'Password Changed',
            message: 'Your password has been updated successfully.',
            buttonLabel: 'Continue',
            onDone: () {
              if (mounted) {
                context.go('/mainPage');
              }
            },
          );
        }
      } else {
        setState(() {
          _apiError = result.bodyText.isNotEmpty
              ? result.bodyText
              : 'Failed to change password. Please try again.';
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
        title: 'Change Password',
        onBack: () => context.go('/login'),
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
      title: 'Password Change Failed',
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
            Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Change Your Password',
              style: AppTextStyles.heading1.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'For security, you must change your temporary password before continuing.',
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AppInput(
              controller: _currentPasswordController,
              label: 'Current Password',
              placeholder: 'Enter temporary password',
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _newPasswordController,
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
                if (value == _currentPasswordController.text) {
                  return 'New password must be different from current password';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Change Password',
              onPressed: _changePassword,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}
