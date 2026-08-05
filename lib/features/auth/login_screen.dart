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
import '../../core/widgets/country_code_selector.dart';

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
  int _activeTab = 0; // 0 = Email / IC, 1 = Phone
  String _selectedCountryCode = CountryCode.defaultCode;

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
        countryCode: _activeTab == 1 ? _selectedCountryCode : null,
      );

      if (!mounted) return;

      if ((response.succeeded) &&
          (LoginCall.status(response.jsonBody) == true)) {
        final appState = FFAppState();
        final token = LoginCall.token(response.jsonBody) ?? '';
        final idplato = LoginCall.idplato(response.jsonBody) ?? '';
        final name = LoginCall.name(response.jsonBody) ?? '';
        final passwordChangedAt =
            LoginCall.passwordChangedAt(response.jsonBody);

        appState.tokenauth = token;
        appState.idplato = idplato;
        appState.name = name;
        appState.isLoggedIn = true;
        appState.update(() {});

        if (mounted) {
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

  void _onTabChanged(int tab) {
    setState(() {
      _activeTab = tab;
      _identifierController.clear();
    });
  }

  // ── Logo ──

  Widget _buildLogo() {
    final branding = BrandingService.instance;
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

  // ── Tab Toggle ──

  Widget _buildTabToggle(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBgDark : AppColors.divider,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
      child: Row(
        children: [
          _TabOption(
            label: 'Email / IC',
            isActive: _activeTab == 0,
            isDark: isDark,
            onTap: () => _onTabChanged(0),
          ),
          _TabOption(
            label: 'Phone',
            isActive: _activeTab == 1,
            isDark: isDark,
            onTap: () => _onTabChanged(1),
          ),
        ],
      ),
    );
  }

  // ── Social Login ──

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
        if (account == null) return;
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

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _showError
            ? _buildErrorState(isDark)
            : _buildForm(isDark, textColor, secondaryTextColor),
      ),
    );
  }

  Widget _buildForm(bool isDark, Color textColor, Color secondaryTextColor) {
    return SingleChildScrollView(
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
              style: AppTextStyles.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.space32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome back',
                style: AppTextStyles.heading2.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign in to your account',
                style: AppTextStyles.body1.copyWith(color: secondaryTextColor),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),

            // ── Tab Toggle ──
            _buildTabToggle(isDark),
            const SizedBox(height: AppSpacing.space16),

            // ── Identifier (conditional) ──
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
              label: _activeTab == 0 ? 'Email or IC Number' : 'Phone Number',
              placeholder: _activeTab == 0
                  ? 'e.g. you@email.com or 991111111111'
                  : 'Enter your phone number only',
              keyboardType:
                  _activeTab == 0 ? TextInputType.text : TextInputType.phone,
              textInputAction: TextInputAction.next,
              helperText: _activeTab == 1 ? 'Number without country code' : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _activeTab == 0
                      ? 'Please enter your email or IC number'
                      : 'Please enter your phone number';
                }
                if (_activeTab == 1 && value.trim().length < 8) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space16),

            // ── Password ──
            AppInput(
              controller: _passwordController,
              label: 'Password',
              placeholder: 'Enter your password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _performLogin(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space8),

            // ── Forgot password ──
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

            // ── Login Button ──
            AppButton.primary(
              label: 'Log In',
              onPressed: _performLogin,
              isLoading: _isLoading,
            ),

            // ── Divider & Social Login ──
            const SizedBox(height: AppSpacing.space24),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.divider)),
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
                const Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Continue with Google',
              onPressed:
                  _isLoading ? null : () => _socialLogin('google'),
            ),
            if (_isAppleSupported) ...[
              const SizedBox(height: AppSpacing.space12),
              _SocialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onPressed:
                    _isLoading ? null : () => _socialLogin('apple'),
              ),
            ],

            // ── Biometric ──
            const SizedBox(height: AppSpacing.space24),
            GestureDetector(
              onTap: _checkBiometric,
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

            // ── Create Account ──
            AppButton.secondary(
              label: 'Create Account',
              onPressed:
                  _isLoading ? null : () => context.go('/registerStep1'),
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
              onTap:
                  _isLoading ? null : () => context.go('/claimAccount'),
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
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const SizedBox(height: AppSpacing.space48),
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton.primary(label: 'Try Again', onPressed: _retry),
          const SizedBox(height: AppSpacing.space16),
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
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TabOption extends StatelessWidget {
  const _TabOption({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
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
