import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
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

  Widget _buildIdentifierInput(bool isDark) {
    final labelColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final inputBg = isDark ? AppColors.inputBgDark : AppColors.surface;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.inputBorder;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IC / Passport, Phone, or Email',
          style: AppTextStyles.label.copyWith(color: labelColor),
        ),
        const SizedBox(height: AppSpacing.space12),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  icon: const Icon(Icons.expand_more, size: 20),
                  iconEnabledColor:
                      isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  iconDisabledColor: AppColors.textSecondary,
                  style: AppTextStyles.body1.copyWith(color: textColor),
                  selectedItemBuilder: (_) => CountryCode.common.map((c) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        '${c.flag} +${c.code}',
                        style: AppTextStyles.body1.copyWith(color: textColor),
                      ),
                    );
                  }).toList(),
                  items: CountryCode.common.map((c) {
                    return DropdownMenuItem(
                      value: c.code,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${c.flag}  +${c.code}  ${c.name}',
                          style: AppTextStyles.body1.copyWith(color: textColor),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) {
                          if (v != null) setState(() => _selectedCountryCode = v);
                        },
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: isDark ? AppColors.dividerDark : AppColors.inputBorder,
              ),
              Expanded(
                child: TextField(
                  controller: _identifierController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  style: AppTextStyles.body1.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g. 12 345 6789 or 900101-14-5678',
                    hintStyle: AppTextStyles.body1.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          'Enter your phone number, IC or email',
          style: AppTextStyles.body2.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

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
            _buildIdentifierInput(isDark),
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
