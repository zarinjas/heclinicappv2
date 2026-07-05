import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/step_indicator.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});

  static String routeName = 'RegisterStep2Screen';
  static String routePath = '/registerStep2';

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _isLoading = false;
  String? _apiError;
  int _passwordStrength = 0;

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
      case 0:
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
      case 0:
        return '';
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

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final appState = FFAppState();
      final result = await MedicalAppsApiGroup.registerCall.call(
        email: appState.registerEmail,
        name: appState.username,
        telephone: appState.phonefield,
      );

      if (!mounted) return;

      if (result.succeeded) {
        final token = MedicalAppsApiGroup.registerCall.token(result.jsonBody);
        final idplato =
            MedicalAppsApiGroup.registerCall.idplato(result.jsonBody);

        if (token != null && token.isNotEmpty) {
          appState.tokenauth = token;
        }
        if (idplato != null && idplato.isNotEmpty) {
          appState.givenid = idplato;
        }

        if (mounted) {
          context.go('/mainPage');
        }
      } else {
        setState(() {
          _apiError = result.bodyText.isNotEmpty
              ? result.bodyText
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
      body: SafeArea(
        child: _apiError != null
            ? _buildErrorState(isDark)
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return AppErrorState(
      title: 'Registration Failed',
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
            const SizedBox(height: AppSpacing.space16),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
              onPressed: () => context.go('/registerStep1'),
            ),
            const SizedBox(height: AppSpacing.space8),
            const StepIndicator(
              currentStep: 1,
              totalSteps: 2,
              labels: ['Personal Info', 'Password'],
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              'Create Password',
              style: AppTextStyles.heading1.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Set a secure password for your account',
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
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
                return null;
              },
              onSubmitted: (_) {
                setState(() {
                  _passwordStrength =
                      _calculateStrength(_passwordController.text);
                });
              },
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space4),
              _buildStrengthBar(_passwordStrength, isDark),
            ],
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                    activeColor: AppColors.accent,
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body2.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(
                          text: 'I agree to the ',
                        ),
                        TextSpan(
                          text: 'Terms',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
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
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Create Account',
              onPressed: _onRegister,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.body2.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Login',
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

  Widget _buildStrengthBar(int strength, bool isDark) {
    final strengthColor = _strengthColor(strength);
    final segments = 4;

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
