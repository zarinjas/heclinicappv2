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

class ForgotEmailScreen extends StatefulWidget {
  const ForgotEmailScreen({super.key});

  static String routeName = 'ForgotEmailScreen';
  static String routePath = '/forgotEmail';

  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isLoading = false;
  String? _apiError;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final result = await HeclinicAuthApi.forgotPasswordCall.call(
        identifier: _identifierController.text.trim(),
      );

      if (!mounted) return;

      if (result.succeeded && (ForgotPasswordCall.status(result.jsonBody) == true)) {
        FFAppState().resetIdentifier = _identifierController.text.trim();
        if (mounted) context.go('/forgotOtp');
      } else {
        final message = ForgotPasswordCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Unable to send verification code. Please try again.';
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
            ? _buildErrorState(isDark)
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return AppErrorState(
      title: 'Failed to Send Code',
      subtitle: _apiError!,
      onRetry: _retry,
    );
  }

  Widget _buildForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space16),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Reset Your Password',
              style: AppTextStyles.heading1.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Enter your email or phone number. We\'ll send you a verification code.',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AppInput(
              controller: _identifierController,
              label: 'Email or Phone Number',
              placeholder: 'Enter your email or phone number',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendOtp(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or phone number';
                }
                if (value.trim().length < 5) {
                  return 'Please enter a valid email or phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Send Code',
              onPressed: _sendOtp,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Remember your password? ',
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
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
}
