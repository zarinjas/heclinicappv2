import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/services/branding_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/country_code_selector.dart';

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
  int _activeTab = 0; // 0 = Email, 1 = WhatsApp
  String _selectedCountryCode = '60';

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
        countryCode: _selectedCountryCode,
      );

      if (!mounted) return;

      if (result.succeeded && (ForgotPasswordCall.status(result.jsonBody) == true)) {
        FFAppState().resetIdentifier = _identifierController.text.trim();
        FFAppState().resetCountryCode = _selectedCountryCode;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space16),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
              onPressed: () => context.go('/login'),
            ),
          ),
          const SizedBox(height: AppSpacing.space48),
          const Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            'Failed to Send Code',
            style: AppTextStyles.heading3.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            _apiError ?? 'Unable to send verification code. Please try again.',
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton.ghost(
            label: 'Try Again',
            onPressed: _retry,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.space12),
          AppButton.ghost(
            label: 'Contact Clinic on WhatsApp',
            onPressed: () => _launchWhatsApp(BrandingService.instance.clinicWhatsapp),
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.space32),
          GestureDetector(
            onTap: () => context.go('/troubleSigningIn'),
            child: Text(
              'Having trouble? Can\'t receive the code?',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.accent,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String number) async {
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
              'Choose how you\'d like to receive your verification code.',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputBgDark : AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            'Email',
                            style: AppTextStyles.label.copyWith(
                              color: _activeTab == 0 ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.primary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            'WhatsApp',
                            style: AppTextStyles.label.copyWith(
                              color: _activeTab == 1 ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.primary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            if (_activeTab == 1) ...[
              CountryCodeSelector(
                selectedCode: _selectedCountryCode,
                onChanged: (code) {
                  setState(() => _selectedCountryCode = code);
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.space12),
            ],
            AppInput(
              controller: _identifierController,
              label: _activeTab == 0 ? 'Email Address' : 'WhatsApp Number',
              placeholder: _activeTab == 0
                  ? 'Enter your email address'
                  : 'Enter your WhatsApp number',
              keyboardType: _activeTab == 0
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendOtp(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _activeTab == 0
                      ? 'Please enter your email address'
                      : 'Please enter your WhatsApp number';
                }
                if (_activeTab == 0) {
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                } else {
                  if (value.trim().length < 8) {
                    return 'Please enter a valid phone number';
                  }
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
