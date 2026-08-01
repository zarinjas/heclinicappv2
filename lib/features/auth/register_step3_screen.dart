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
import '../../core/widgets/app_input.dart';
import '../../core/widgets/step_indicator.dart';

class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({super.key});

  static String routeName = 'RegisterStep3Screen';
  static String routePath = '/registerStep3';

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
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

  Future<void> _onCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Privacy Policy to continue.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final appState = FFAppState();

      final result = await HeclinicAuthApi.registerCall.call(
        name: appState.registerName,
        email: appState.registerEmail,
        telephone: appState.registerPhone,
        nric: appState.registerNric,
        nricType: appState.registerNricType,
        nationality: appState.registerNationality,
        dob: appState.registerDob,
        sex: appState.registerSex,
        idplato: appState.registerIdplato,
        password: _passwordController.text,
        fcmToken: appState.fcmtoken,
      );

      if (!mounted) return;

      final status = RegisterCall.status(result.jsonBody) ?? false;

      if (result.succeeded && status) {
        final token = RegisterCall.token(result.jsonBody);
        final idplato = RegisterCall.idplato(result.jsonBody);

        if (token != null && token.isNotEmpty) {
          appState.tokenauth = token;
        }
        if (idplato != null && idplato.isNotEmpty) {
          appState.givenid = idplato;
          appState.idplato = idplato;
        }

        appState.isLoggedIn = true;
        appState.clearRegisterState();
        appState.update(() {});

        if (mounted) {
          context.go('/mainPage');
        }
      } else {
        final message = RegisterCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Registration failed. Please try again.';
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
        setState(() => _isLoading = false);
      }
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
                title: 'Registration Failed',
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
              onPressed: () => context.go('/registerStep2'),
            ),
            const SizedBox(height: AppSpacing.space8),
            const StepIndicator(
              currentStep: 2,
              totalSteps: 3,
              labels: ['Identity', 'Details', 'Password'],
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              'Create Password',
              style: AppTextStyles.heading1.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Set a secure password for your account.',
              style: AppTextStyles.body1.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.space32),

            AppInput(
              controller: _passwordController,
              label: 'Password',
              placeholder: 'Min. 8 characters',
              isPassword: true,
              textInputAction: TextInputAction.next,
              helperText: _passwordStrength > 0
                  ? 'Password strength: ${_strengthLabel(_passwordStrength)}'
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
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
              label: 'Confirm Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onCreateAccount(),
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
            const SizedBox(height: AppSpacing.space24),

            _buildTermsCheckbox(isDark, textSecondary),
            const SizedBox(height: AppSpacing.space32),

            AppButton.primary(
              label: 'Create Account',
              onPressed: _onCreateAccount,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
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

  Widget _buildTermsCheckbox(bool isDark, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value ?? false),
            activeColor: AppColors.accent,
            checkColor: Colors.white,
            side: BorderSide(color: textSecondary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusSM),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body2.copyWith(color: textSecondary),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
