import 'dart:async';

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
import '../../core/widgets/otp_input_row.dart';

/// Add or change the email bound to the account.
///
/// Used in two places:
/// - After registration when no email was provided (force bind) — `?from=register`
/// - From Profile settings (add / change email) — pushed on the stack
class BindEmailScreen extends StatefulWidget {
  const BindEmailScreen({super.key});

  static String routeName = 'BindEmailScreen';
  static String routePath = '/bindEmail';

  @override
  State<BindEmailScreen> createState() => _BindEmailScreenState();
}

class _BindEmailScreenState extends State<BindEmailScreen> {
  static const _otpLength = 6;
  static const _countdownSeconds = 60;
  static const _maxAttempts = 5;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _apiError;

  // OTP phase
  bool _otpSent = false;
  bool _isVerifying = false;
  bool _hasOtpError = false;
  int _remainingSeconds = _countdownSeconds;
  int _attemptsLeft = _maxAttempts;
  Timer? _countdownTimer;
  String _otpValue = '';

  bool get _fromRegister {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    return from == 'register';
  }

  @override
  void initState() {
    super.initState();
    final existing = FFAppState().userEmail;
    if (existing.isNotEmpty) {
      _emailController.text = existing;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = _countdownSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final token = FFAppState().tokenauth;
      final result = await HeclinicAuthApi.linkEmailRequestCall.call(
        token: token,
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.succeeded && (LinkEmailRequestCall.status(result.jsonBody) == true)) {
        setState(() {
          _otpSent = true;
          _apiError = null;
          _attemptsLeft = _maxAttempts;
        });
        _startCountdown();
      } else {
        final message = LinkEmailRequestCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Unable to send the verification code. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _apiError = 'Network error. Please check your connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_remainingSeconds > 0) return;
    setState(() => _isResending = true);

    try {
      final token = FFAppState().tokenauth;
      final result = await HeclinicAuthApi.linkEmailRequestCall.call(
        token: token,
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.succeeded && (LinkEmailRequestCall.status(result.jsonBody) == true)) {
        setState(() {
          _hasOtpError = false;
          _apiError = null;
          _attemptsLeft = _maxAttempts;
        });
        _startCountdown();
      } else {
        final message = LinkEmailRequestCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Unable to resend the code. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _apiError = 'Network error. Please check your connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _onOtpCompleted(String otp) {
    _otpValue = otp;
    _verifyOtp();
  }

  void _onOtpChanged(String otp) {
    _otpValue = otp;
    if (_hasOtpError) {
      setState(() {
        _hasOtpError = false;
        _apiError = null;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length != _otpLength) return;

    setState(() {
      _isVerifying = true;
      _apiError = null;
      _hasOtpError = false;
    });

    try {
      final token = FFAppState().tokenauth;
      final result = await HeclinicAuthApi.linkEmailVerifyCall.call(
        token: token,
        email: _emailController.text.trim(),
        otp: _otpValue,
      );

      if (!mounted) return;

      if (result.succeeded && (LinkEmailVerifyCall.status(result.jsonBody) == true)) {
        FFAppState().userEmail = _emailController.text.trim();
        if (_fromRegister) {
          context.go('/mainPage');
        } else {
          context.pop();
        }
      } else {
        final message = LinkEmailVerifyCall.message(result.jsonBody);
        setState(() {
          _attemptsLeft--;
          _hasOtpError = true;

          if (_attemptsLeft <= 0) {
            _apiError = 'Too many failed attempts. Please request a new code.';
          } else {
            _apiError = message?.isNotEmpty == true
                ? message
                : 'Invalid code. $_attemptsLeft attempt(s) remaining.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _apiError = 'Network error. Please check your connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _retry() => setState(() => _apiError = null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textColor,
          onPressed: _fromRegister ? () => context.go('/mainPage') : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _apiError != null && !_otpSent
            ? AppErrorState(subtitle: _apiError!, onRetry: _retry)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otpSent ? 'Verify your email' : 'Add your email',
                      style: AppTextStyles.heading1.copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      _otpSent
                          ? 'Enter the 6-digit code sent to\n${_emailController.text.trim()}'
                          : 'Link an email to your account so you can log in with either your phone number or email.',
                      style: AppTextStyles.body1.copyWith(color: secondaryTextColor),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    if (!_otpSent) ...[
                      Form(
                        key: _formKey,
                        child: AppInput(
                          controller: _emailController,
                          label: 'Email',
                          placeholder: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space32),
                      AppButton.primary(
                        label: 'Send Code',
                        onPressed: _isLoading ? null : _sendOtp,
                        isLoading: _isLoading,
                      ),
                    ] else ...[
                      Center(
                        child: OtpInputRow(
                          length: _otpLength,
                          hasError: _hasOtpError,
                          onChanged: _onOtpChanged,
                          onCompleted: _onOtpCompleted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      Center(
                        child: Text(
                          _remainingSeconds > 0
                              ? 'Resend code in ${_remainingSeconds}s'
                              : 'Didn\'t receive the code?',
                          style: AppTextStyles.body2.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Center(
                        child: TextButton(
                          onPressed: (_remainingSeconds > 0 || _isResending)
                              ? null
                              : _resend,
                          child: Text(
                            _isResending ? 'Resending...' : 'Resend Code',
                            style: AppTextStyles.button.copyWith(
                              color: _remainingSeconds > 0
                                  ? secondaryTextColor
                                  : AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      AppButton.primary(
                        label: 'Verify & Link Email',
                        onPressed: _isVerifying ? null : _verifyOtp,
                        isLoading: _isVerifying,
                      ),
                    ],
                    if (_apiError != null && _otpSent) ...[
                      const SizedBox(height: AppSpacing.space16),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                        ),
                        child: Text(
                          _apiError!,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
