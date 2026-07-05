import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/app_toast.dart';
import '../../custom_code/actions/save_biometric_status.dart';
import '../../custom_code/actions/load_biometric_status.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  static String routeName = 'BiometricScreen';

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = true;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;

      if (isSupported && canCheck) {
        final biometrics = await _localAuth.getAvailableBiometrics();
        _biometricAvailable = true;
        _availableBiometrics = biometrics;
      } else {
        _biometricAvailable = false;
      }

      final appState = FFAppState();
      _biometricEnabled = appState.fingerprint || appState.faceid;
    } catch (e) {
      _error = 'Failed to check biometric availability.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (enable) {
      if (!_biometricAvailable) {
        AppToast.showError(context, 'Biometric authentication is not available on this device.');
        return;
      }

      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (!mounted) return;

        if (authenticated) {
          await saveBiometricStatus(true);
          setState(() => _biometricEnabled = true);
          AppToast.showSuccess(context, 'Biometric login enabled');
        }
      } on PlatformException {
        if (mounted) {
          AppToast.showError(context, 'Biometric authentication failed.');
        }
      }
    } else {
      await saveBiometricStatus(false);
      setState(() => _biometricEnabled = false);
      if (mounted) {
        AppToast.showInfo(context, 'Biometric login disabled');
      }
    }
  }

  String _getBiometricLabel() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    }
    return Icons.fingerprint;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.primary;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Biometric Login',
        onBack: () => context.pop(),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _error != null
              ? AppErrorState(
                  message: _error!,
                  onRetry: _checkBiometricAvailability,
                )
              : !_biometricAvailable
                  ? AppErrorState(
                      message: 'Biometric authentication is not available on this device.',
                      onRetry: _checkBiometricAvailability,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.space16),
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withAlpha(26),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getBiometricIcon(),
                                color: AppColors.accent,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space20),
                          Center(
                            child: Text(
                              'Secure Your Account',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading2.copyWith(color: textColor),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                            child: Text(
                              'Use ${_getBiometricLabel().toLowerCase()} to quickly '
                              'and securely log in without entering your password.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body1.copyWith(color: subtitleColor),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                              border: Border.all(
                                color: isDark ? AppColors.dividerDark : AppColors.divider,
                              ),
                              boxShadow: [AppShadows.shadowLow],
                            ),
                            padding: const EdgeInsets.all(AppSpacing.space20),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(26),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getBiometricIcon(),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_getBiometricLabel()} Login',
                                        style: AppTextStyles.heading3.copyWith(color: textColor),
                                      ),
                                      const SizedBox(height: AppSpacing.space4),
                                      Text(
                                        'Use your ${_getBiometricLabel().toLowerCase()} '
                                        'to unlock the app',
                                        style: AppTextStyles.body2.copyWith(color: subtitleColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _biometricEnabled,
                                  onChanged: _toggleBiometric,
                                  activeColor: AppColors.accent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                            child: Text(
                              _biometricEnabled
                                  ? 'Biometric login is currently enabled. You can disable it at any time.'
                                  : 'Enable biometric login for faster, more secure access to your account.',
                              style: AppTextStyles.body2.copyWith(color: subtitleColor),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space16),
          Center(child: AppSkeleton.circle(size: 80)),
          const SizedBox(height: AppSpacing.space20),
          Center(child: AppSkeleton.text(width: 200)),
          const SizedBox(height: AppSpacing.space8),
          Center(child: AppSkeleton.text(width: 280)),
          const SizedBox(height: AppSpacing.space24),
          AppSkeleton.card(height: 100),
          const SizedBox(height: AppSpacing.space24),
          AppSkeleton.text(width: 280),
        ],
      ),
    );
  }
}
