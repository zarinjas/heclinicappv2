import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/otp_input_row.dart';

class ForgotOtpScreen extends StatefulWidget {
  const ForgotOtpScreen({super.key});

  static String routeName = 'ForgotOtpScreen';
  static String routePath = '/forgotOtp';

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
  static const _otpLength = 6;
  static const _countdownSeconds = 60;
  static const _maxAttempts = 5;

  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasOtpError = false;
  String? _apiError;
  int _remainingSeconds = _countdownSeconds;
  int _attemptsLeft = _maxAttempts;
  Timer? _countdownTimer;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
      final appState = FFAppState();
      final result = await HeclinicAuthApi.verifyOtpCall.call(
        identifier: appState.resetIdentifier,
        otp: _otpValue,
      );

      if (!mounted) return;

      if (result.succeeded && (VerifyOtpCall.status(result.jsonBody) == true)) {
        final resetToken = VerifyOtpCall.resetToken(result.jsonBody);

        if (resetToken != null && resetToken.isNotEmpty) {
          appState.resetToken = resetToken;
        }

        if (mounted) context.go('/forgotNewPassword');
      } else {
        setState(() {
          _attemptsLeft--;
          _hasOtpError = true;

          if (_attemptsLeft <= 0) {
            _apiError = 'Too many failed attempts. Please request a new code.';
          } else {
            _apiError =
                'Invalid code. $_attemptsLeft attempt(s) remaining.';
          }
        });

        if (_attemptsLeft <= 0) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            appState.resetIdentifier = '';
            context.go('/forgotEmail');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasOtpError = true;
          _apiError = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _apiError = null;
    });

    try {
      final appState = FFAppState();
      final result = await HeclinicAuthApi.forgotPasswordCall.call(
        identifier: appState.resetIdentifier,
      );

      if (!mounted) return;

      if (result.succeeded && (ForgotPasswordCall.status(result.jsonBody) == true)) {
        _startCountdown();
        setState(() {
          _attemptsLeft = _maxAttempts;
          _hasOtpError = false;
        });
      } else {
        final message = ForgotPasswordCall.message(result.jsonBody);
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Failed to resend code. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiError = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  bool get _canResend => _remainingSeconds <= 0 && !_isResending;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _apiError != null && _apiError!.startsWith('Too many')
            ? _buildLockedState(isDark)
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildLockedState(bool isDark) {
    return AppErrorState(
      title: 'Verification Locked',
      subtitle: _apiError!,
    );
  }

  Widget _buildForm(bool isDark) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timerText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              onPressed: () => context.go('/forgotEmail'),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          Icon(
            Icons.sms_outlined,
            size: 64,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.space24),
          Text(
            'Enter Verification Code',
            style: AppTextStyles.heading1.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'We\'ve sent a 6-digit code to your email or WhatsApp. Please enter it below.',
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space32),
          OtpInputRow(
            length: _otpLength,
            onCompleted: _onOtpCompleted,
            onChanged: _onOtpChanged,
            hasError: _hasOtpError,
          ),
          if (_hasOtpError && _apiError != null) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              _apiError!,
              style: AppTextStyles.body2.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.space32),
          AppButton.primary(
            label: 'Verify Code',
            onPressed: _otpValue.length == _otpLength ? _verifyOtp : null,
            isLoading: _isVerifying,
          ),
          const SizedBox(height: AppSpacing.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              _canResend
                  ? GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        'Resend',
                        style: AppTextStyles.label.copyWith(color: AppColors.accent),
                      ),
                    )
                  : Text(
                      timerText,
                      style: AppTextStyles.label.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
            ],
          ),
          if (_isResending) ...[
            const SizedBox(height: AppSpacing.space16),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space32),
        ],
      ),
    );
  }
}
