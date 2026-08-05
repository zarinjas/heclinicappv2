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
import '../../core/widgets/country_code_selector.dart';

class ClaimAccountScreen extends StatefulWidget {
  const ClaimAccountScreen({super.key});

  static String routeName = 'ClaimAccountScreen';
  static String routePath = '/claimAccount';

  @override
  State<ClaimAccountScreen> createState() => _ClaimAccountScreenState();
}

class _ClaimAccountScreenState extends State<ClaimAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isLoading = false;
  String? _apiError;
  String _selectedCountryCode = '60';

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final result = await HeclinicAuthApi.claimAccountCall.call(
        identifier: _identifierController.text.trim(),
        countryCode: _selectedCountryCode,
      );

      if (!mounted) return;

      if (result.succeeded && (ClaimAccountCall.status(result.jsonBody) == true)) {
        FFAppState().resetIdentifier = _identifierController.text.trim();
        if (mounted) context.go('/forgotOtp');
      } else {
        final message = ClaimAccountCall.message(result.jsonBody);
        setState(() {
          _apiError = (message != null && message.isNotEmpty)
              ? message
              : 'We could not verify your identity. Please try again or register as a new patient.';
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
      title: 'Verification Failed',
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
            Icon(
              Icons.badge_outlined,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Already a Patient?',
              style: AppTextStyles.heading1.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Enter your IC/Passport number, phone number, or email below. '
              'If we find your record, we\'ll send you a verification code to '
              'finish setting up your account.',
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            CountryCodeSelector(
              selectedCode: _selectedCountryCode,
              onChanged: (code) {
                setState(() => _selectedCountryCode = code);
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: AppSpacing.space12),
            AppInput(
              controller: _identifierController,
              label: 'IC / Passport, Phone, or Email',
              placeholder: 'e.g. 900101-14-5678 or 0123456789',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your IC, phone, or email';
                }
                if (value.trim().length < 8) {
                  return 'Please enter a valid IC, phone number, or email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Send Verification Code',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New patient? ',
                  style: AppTextStyles.body2.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/registerStep1'),
                  child: Text(
                    'Register here',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
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
