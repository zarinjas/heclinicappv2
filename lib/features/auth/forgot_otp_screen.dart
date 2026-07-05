import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
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

  final _identifierController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasOtpError = false;
  String? _apiError;
  int _remainingSeconds = _countdownSeconds;
  Timer? _countdownTimer;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _identifierController.dispose();
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
      final result = await MedicalAppsApiGroup.verifyResetCodeCall.call();

      if (!mounted) return;

      if (result.succeeded) {
        if (mounted) {
          context.go('/forgotNewPassword');
        }
      } else {
        setState(() {
          _hasOtpError = true;
          _apiError = 'Invalid OTP code. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasOtpError = true;
          _apiError = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _apiError = null;
    });

    try {
      final result = await MedicalAppsApiGroup.forgotchangeCall.call(
        telephone: _identifierController.text,
      );

      if (!mounted) return;

      final status = MedicalAppsApiGroup.forgotchangeCall.status(
        result.jsonBody,
      );

      if (status == true) {
        _startCountdown();
      } else {
        final message = MedicalAppsApiGroup.forgotchangeCall.message(
          result.jsonBody,
        );
        setState(() {
          _apiError = message?.isNotEmpty == true
              ? message
              : 'Failed to resend OTP. Please try again.';
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
          _isResending = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _apiError = null;
      _hasOtpError = false;
    });
  }

  bool get _canResend => _remainingSeconds <= 0 && !_isResending;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Enter OTP',
        onBack: () => context.go('/forgotEmail'),
      ),
      body: SafeArea(
        child: _apiError != null
            ? _buildErrorState(isDark)
            : _buildForm(isDark),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return AppErrorState(
      title: 'OTP Verification Failed',
      subtitle: _apiError!,
      onRetry: _retry,
    );
  }

  Widget _buildForm(bool isDark) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timerText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.space32),
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
            'We\'ve sent a 6-digit code to your phone. Please enter it below.',
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
          if (_hasOtpError) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              _apiError ?? 'Invalid OTP code',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.space32),
          AppButton.primary(
            label: 'Verify OTP',
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
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              _canResend
                  ? GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        'Resend OTP',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : Text(
                      timerText,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: AppSpacing.space32),
        ],
      ),
    );
  }
}
