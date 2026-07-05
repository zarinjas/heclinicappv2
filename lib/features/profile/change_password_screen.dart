import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static String routeName = 'ChangePasswordScreen';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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
          await MedicalAppsApiGroup.changepasswordCall.call(
        authorization: 'Bearer ${appState.tokenauth}',
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (result.succeeded) {
        AppToast.showSuccess(context, 'Password changed successfully');
        if (mounted) {
          context.pop();
        }
      } else {
        final message = result.bodyText.isNotEmpty
            ? result.bodyText
            : 'Failed to change password. Please try again.';
        setState(() => _apiError = message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _apiError = 'An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor = isDark ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Change Password',
        onBack: () => context.pop(),
      ),
      body: _apiError != null
          ? AppErrorState(
              message: _apiError!,
              onRetry: () {
                setState(() => _apiError = null);
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.space16),
                    Text(
                      'Update your password',
                      style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    AppInput(
                      controller: _currentPasswordController,
                      label: 'Current Password *',
                      hint: 'Enter current password',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Current password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppInput(
                      controller: _newPasswordController,
                      label: 'New Password *',
                      hint: 'Min. 8 characters',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'New password is required';
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
                      label: 'Confirm New Password *',
                      hint: 'Re-enter new password',
                      isPassword: true,
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
                      onPressed: _isLoading ? null : _changePassword,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.space24),
                  ],
                ),
              ),
            ),
    );
  }
}
