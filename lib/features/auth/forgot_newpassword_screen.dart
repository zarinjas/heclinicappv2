import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';

class ForgotNewpasswordScreen extends StatefulWidget {
  const ForgotNewpasswordScreen({super.key});

  static String routeName = 'ForgotNewpasswordScreen';
  static String routePath = '/forgotNewPassword';

  @override
  State<ForgotNewpasswordScreen> createState() => _ForgotNewpasswordScreenState();
}

class _ForgotNewpasswordScreenState extends State<ForgotNewpasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _apiError;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      final strength = _calculateStrength(_passwordController.text);
      if (strength != _passwordStrength) {
        setState(() => _passwordStrength = strength);
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  String _strengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      case 4:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final appState = FFAppState();
      final result = await HeclinicAuthApi.resetPasswordCall.call(
        resetToken: appState.resetToken,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.succeeded && (ResetPasswordCall.status(result.jsonBody) == true)) {
        final token = ResetPasswordCall.token(result.jsonBody);

        appState.clearResetState();

        if (token != null && token.isNotEmpty) {
          appState.tokenauth = token;
          appState.idplato = ResetPasswordCall.idplato(result.jsonBody) ?? '';
          appState.name = ResetPasswordCall.name(result.jsonBody) ?? '';
          final userEmail = ResetPasswordCall.email(result.jsonBody) ?? '';
          if (userEmail.isNotEmpty) {
            appState.userEmail = userEmail;
          }
          appState.isLoggedIn = true;
          appState.update(() {});

          if (mounted) {
            if (userEmail.isEmpty) {
              context.go('/bindEmail?from=reset');
            } else {
              context.go('/');
            }
          }
        } else {
          if (mounted) context.go('/login');
        }
      } else {
        final message = ResetPasswordCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _retry() => setState(() => _apiError = null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _apiError != null
            ? AppErrorState(
                title: 'Reset Failed',
                subtitle: _apiError!,
                onRetry: _retry,
              )
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space16),
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20, color: textPrimary),
              onPressed: () => context.go('/forgotOtp'),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'New Password',
              style: AppTextStyles.heading1.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Choose a new secure password for your account.',
              style: AppTextStyles.body1.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.space32),

            AppInput(
              controller: _passwordController,
              label: 'New Password',
              placeholder: 'Min. 8 characters',
              isPassword: true,
              textInputAction: TextInputAction.next,
              helperText: _passwordStrength > 0
                  ? 'Password strength: ${_strengthLabel(_passwordStrength)}'
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Must include at least one uppercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Must include at least one number';
                }
                return null;
              },
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space8),
              _buildStrengthBar(_passwordStrength, isDark),
            ],
            const SizedBox(height: AppSpacing.space16),

            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _resetPassword(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
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
            const SizedBox(height: AppSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Remember your password? ',
                  style: AppTextStyles.body2.copyWith(color: textSecondary),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Login',
                    style: AppTextStyles.label.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthBar(int strength, bool isDark) {
    const segments = 4;
    final strengthColor = _strengthColor(strength);

    return Row(
      children: List.generate(segments, (index) {
        final isFilled = index < strength;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < segments - 1 ? AppSpacing.space4 : 0,
            ),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isFilled
                    ? strengthColor
                    : (isDark ? AppColors.dividerDark : AppColors.divider),
              ),
            ),
          ),
        );
      }),
    );
  }
}
