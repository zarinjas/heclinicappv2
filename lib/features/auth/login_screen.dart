import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showError = false;
  String _errorMessage = 'Invalid credentials. Please try again.';

  /// Strips phone separators (spaces, dashes, brackets) while keeping the
  /// email address and "+" prefix intact. The backend normalises the rest
  /// (e.g. 0123456789 → 60123456789).
  static String _normalizeIdentifier(String raw) {
    final value = raw.trim();
    if (value.contains('@')) return value;
    return value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometric());
  }

  @override
  void dispose() {
    _identifierController.dispose();
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
        _identifierController.text = '';
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
      final identifier = _normalizeIdentifier(_identifierController.text);

      final response = await HeclinicAuthApi.loginCall.call(
        identifier: identifier,
        password: _passwordController.text,
        fcmToken: FFAppState().fcmtoken,
      );

      if (!mounted) return;

      if ((response.succeeded) &&
          (LoginCall.status(response.jsonBody) == true)) {
        final appState = FFAppState();
        final token = LoginCall.token(response.jsonBody) ?? '';
        final idplato =
            LoginCall.idplato(response.jsonBody) ?? '';
        final name =
            LoginCall.name(response.jsonBody) ?? '';
        final passwordChangedAt =
            LoginCall.passwordChangedAt(response.jsonBody);

        appState.tokenauth = token;
        appState.idplato = idplato;
        appState.name = name;
        appState.isLoggedIn = true;
        appState.update(() {});

        if (mounted) {
          // First login with a temporary password → force a password change.
          final mustChange =
              passwordChangedAt == null || passwordChangedAt.isEmpty;
          if (mustChange) {
            context.go('/firstChangePassword');
          } else {
            context.go('/');
          }
        }
      } else {
        final apiMessage =
            LoginCall.message(response.jsonBody) ?? response.bodyText;
        final message = apiMessage.trim().isEmpty
            ? 'Invalid credentials. Please try again.'
            : apiMessage.trim();
        setState(() {
          _errorMessage = message;
          _showError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error. Please check your connection.';
          _showError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _retry() => setState(() => _showError = false);

  Widget _buildLogo() {
    final branding = BrandingService.instance;
    // Use the dedicated login logo, falling back to the main logo.
    final logoUrl = (branding.loginLogoUrl ?? '').isNotEmpty
        ? branding.loginLogoUrl
        : branding.logoUrl;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          logoUrl,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackLogo(),
        ),
      );
    }

    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    return Container(
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
    );
  }

  bool get _isAppleSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _socialLogin(String provider) async {
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      String? idToken;
      String? email;
      String? name;

      if (provider == 'google') {
        final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        final account = await googleSignIn.signIn();
        if (account == null) return; // user cancelled
        final auth = await account.authentication;
        idToken = auth.idToken;
        email = account.email;
        name = account.displayName;
      } else if (provider == 'apple') {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        idToken = credential.identityToken;
        email = credential.email;
        final given = credential.givenName ?? '';
        final family = credential.familyName ?? '';
        name = [given, family].where((s) => s.isNotEmpty).join(' ');
      }

      if (idToken == null || idToken.isEmpty) return;

      final response = await HeclinicAuthApi.socialLoginCall.call(
        provider: provider,
        idToken: idToken,
        email: email ?? '',
        name: name ?? '',
      );

      if (!mounted) return;

      if ((response.succeeded) &&
          (SocialLoginCall.status(response.jsonBody) == true)) {
        final appState = FFAppState();
        final token = SocialLoginCall.token(response.jsonBody) ?? '';
        final idplato = SocialLoginCall.idplato(response.jsonBody) ?? '';
        final name = SocialLoginCall.name(response.jsonBody) ?? '';

        appState.tokenauth = token;
        appState.idplato = idplato;
        appState.name = name;
        appState.isLoggedIn = true;
        appState.update(() {});

        if (mounted) context.go('/');
      } else {
        final apiMessage = SocialLoginCall.message(response.jsonBody) ??
            response.bodyText;
        setState(() {
          _errorMessage = apiMessage.trim().isEmpty
              ? 'Social login failed. Please try again.'
              : apiMessage.trim();
          _showError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error. Please check your connection.';
          _showError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                      _buildLogo(),
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
                      AppInput(
                        controller: _identifierController,
                        label: 'Email, Phone or IC Number',
                        placeholder: 'e.g. 0123456789 or you@email.com',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email, phone or IC number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        'Malaysia: 0123456789 or +60123456789 • '
                        'Other countries: +[country code] e.g. +628123456789',
                        style: AppTextStyles.body2.copyWith(
                          color: secondaryTextColor,
                        ),
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
                        onPressed: _isLoading ? null : () => _socialLogin('google'),
                      ),
                      if (_isAppleSupported) ...[
                        const SizedBox(height: AppSpacing.space12),
                        _SocialButton(
                          icon: Icons.apple,
                          label: 'Continue with Apple',
                          onPressed: _isLoading
                              ? null
                              : () => _socialLogin('apple'),
                        ),
                      ],
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
                      AppButton.secondary(
                        label: 'Create Account',
                        onPressed: _isLoading
                            ? null
                            : () => context.go('/registerStep1'),
                      ),
                      const SizedBox(height: AppSpacing.space16),
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
                            onTap: _isLoading
                                ? null
                                : () => context.go('/registerStep1'),
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
                      const SizedBox(height: AppSpacing.space16),
                      GestureDetector(
                        onTap: _isLoading ? null : () => context.go('/claimAccount'),
                        child: Text(
                          'Already a patient? Verify my account',
                          style: AppTextStyles.body2.copyWith(
                            color: secondaryTextColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
              _errorMessage,
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
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onPressed == null;
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        border: Border.all(
          color: isDisabled
              ? AppColors.divider
              : (isDark ? AppColors.dividerDark : AppColors.inputBorder),
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
