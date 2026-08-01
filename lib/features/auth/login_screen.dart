import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String routeName = 'LoginScreen';
  static String routePath = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showError = false;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometric());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    try {
      final localAuth = LocalAuthentication();
      final canAuth = await localAuth.canCheckBiometrics;
      if (!canAuth || !mounted) return;
      final didAuth = await localAuth.authenticate(
        localizedReason: 'Sign in with biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuth && mounted) {
        _emailController.text = '';
        _phoneController.text = '';
        _passwordController.text = '';
      }
    } catch (_) {}
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final identifier = _activeTab == 0
          ? _emailController.text.trim()
          : _phoneController.text.trim();

      final response = await HeclinicAuthApi.loginCall.call(
        identifier: identifier,
        password: _passwordController.text,
        fcmToken: FFAppState().fcmtoken,
      );

      if (!mounted) return;

      if ((response?.succeeded ?? false) &&
          (LoginCall.status(response?.jsonBody) == true)) {
        final appState = FFAppState();
        final token = LoginCall.token(response?.jsonBody) ?? '';
        final idplato =
            LoginCall.idplato(response?.jsonBody) ?? '';
        final name =
            LoginCall.name(response?.jsonBody) ?? '';

        appState.tokenauth = token;
        appState.idplato = idplato;
        appState.name = name;
        appState.isLoggedIn = true;
        appState.update(() {});

        if (mounted) context.go('/');
      } else {
        setState(() => _showError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _showError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _retry() => setState(() => _showError = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _showError
            ? _buildErrorState(isDark)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.space32),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF27F5A3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            BrandingService.instance.appShortName,
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      Text(
                        BrandingService.instance.appName,
                        style: AppTextStyles.heading3.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome back',
                          style: AppTextStyles.heading2.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sign in to your account',
                          style: AppTextStyles.body1.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.inputBgDark
                              : AppColors.divider,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeTab = 0),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _activeTab == 0
                                        ? AppColors.accent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.radiusFull),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Email',
                                      style: AppTextStyles.label.copyWith(
                                        color: _activeTab == 0
                                            ? Colors.white
                                            : textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeTab = 1),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _activeTab == 1
                                        ? AppColors.accent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.radiusFull),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Phone',
                                      style: AppTextStyles.label.copyWith(
                                        color: _activeTab == 1
                                            ? Colors.white
                                            : textColor,
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
                      if (_activeTab == 0)
                        AppInput(
                          controller: _emailController,
                          label: 'Email',
                          placeholder: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        )
                      else
                        AppInput(
                          controller: _phoneController,
                          label: 'Phone',
                          placeholder: '+60 12 345 6789',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: AppSpacing.space16),
                      AppInput(
                        controller: _passwordController,
                        label: 'Password',
                        placeholder: 'Enter password',
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go('/forgotEmail'),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      AppButton.primary(
                        label: 'Log In',
                        onPressed: _performLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16,
                            ),
                            child: Text(
                              'or continue with',
                              style: AppTextStyles.body2.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      _SocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Continue with Google',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      _SocialButton(
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometric authentication...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fingerprint,
                                size: 48,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space8),
                            Text(
                              'Use Face ID',
                              style: AppTextStyles.caption.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.body2.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/registerStep1'),
                            child: Text(
                              'Register',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Login Failed',
              style: AppTextStyles.heading2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Invalid credentials. Please try again.',
              style: AppTextStyles.body1.copyWith(
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              label: 'Try Again',
              onPressed: _retry,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.inputBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary),
                const SizedBox(width: AppSpacing.space12),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
