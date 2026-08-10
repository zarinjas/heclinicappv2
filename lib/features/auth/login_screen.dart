import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/config/social_login_config.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';
import '../../core/services/device_token_service.dart';
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
  int _activeTab = 1; // 1 = Phone (default), 0 = Email / IC
  String _selectedCountryCode = CountryCode.defaultCode;
  bool _biometricReady = false;
  bool _hasSavedBioCreds = false;
  bool _biometricBusy = false;
  String _biometricLabel = 'Biometrics';

  static String _normalizeIdentifier(String raw) {
    final value = raw.trim();
    if (value.contains('@')) return value;
    return value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initBiometric());
  }

  Future<void> _initBiometric() async {
    final bio = BiometricAuthService.instance;

    // Purge any plaintext credentials written by pre-secure-storage builds.
    await bio.migrateLegacyCredentials();

    final available = await bio.isAvailable();
    final enabled = available && await bio.isEnabled();
    final label = available ? await bio.biometricLabel() : 'Biometrics';

    if (!mounted) return;
    setState(() {
      _biometricReady = available;
      _hasSavedBioCreds = enabled;
      _biometricLabel = label;
    });

    // Auto-prompt only when a token is actually stored to unlock.
    if (enabled) {
      await _loginWithBiometric(auto: true);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Biometric login ──
  //
  // The password is never stored. Biometrics unlock the Sanctum session token
  // held in the platform keystore; that token is then validated against the
  // backend before we treat the user as logged in.

  Future<void> _loginWithBiometric({bool auto = false}) async {
    if (_biometricBusy) return;
    setState(() => _biometricBusy = true);

    try {
      final result = await BiometricAuthService.instance.unlock(
        reason: 'Sign in to He Clinic with $_biometricLabel',
      );

      if (!mounted) return;

      switch (result.status) {
        case BiometricUnlockStatus.success:
          await _resumeSessionWithToken(result.token!);
          break;

        case BiometricUnlockStatus.notEnrolled:
        case BiometricUnlockStatus.unavailable:
          // Nothing stored to unlock — fall back to the password form.
          if (mounted) setState(() => _hasSavedBioCreds = false);
          break;

        case BiometricUnlockStatus.failed:
          // A cancelled auto-prompt is normal; stay silent. An explicit tap
          // that fails deserves feedback.
          if (!auto && mounted) {
            setState(() {
              _errorMessage = result.message ??
                  'We could not verify your identity. Please try again.';
              _showError = true;
            });
          }
          break;
      }
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  /// Restores a session from a biometric-unlocked token. The token is verified
  /// against the backend so a revoked/expired one cannot grant offline access.
  Future<void> _resumeSessionWithToken(String token) async {
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final response = await HeclinicAuthApi.meCall.call(token: token);

      if (!mounted) return;

      // Only a 401/403 means the token itself is dead. Any other failure
      // (offline, DNS, 500, timeout) must NOT wipe the user's enrolment —
      // that would force a full password login every time the network hiccups.
      final statusCode = response.statusCode;
      final tokenRejected = statusCode == 401 || statusCode == 403;

      if (tokenRejected) {
        await BiometricAuthService.instance.disable();
        if (!mounted) return;
        setState(() {
          _hasSavedBioCreds = false;
          _errorMessage =
              'Your saved session has expired. Please sign in with your password.';
          _showError = true;
        });
        return;
      }

      if (!response.succeeded) {
        // Server or connectivity problem. Keep the enrolment intact so the
        // user can simply try again.
        setState(() {
          _errorMessage =
              'Could not reach the server. Please check your connection and try again.';
          _showError = true;
        });
        return;
      }

      final appState = FFAppState();
      appState.tokenauth = token;
      appState.name = MeCall.name(response.jsonBody) ?? appState.name;
      appState.idplato = MeCall.idplato(response.jsonBody) ?? appState.idplato;
      appState.isLoggedIn = true;
      appState.update(() {});

      DeviceTokenService.instance.reset();
      await DeviceTokenService.instance.registerCachedToken();

      if (mounted) context.go('/');
    } catch (_) {
      // Network exception — again, do not punish the user by dropping their
      // biometric enrolment.
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

  /// Offers biometric enrolment after a successful password login, or silently
  /// refreshes the stored token when the user already opted in.
  Future<void> _offerBiometricEnrolment(String token, String accountLabel) async {
    final bio = BiometricAuthService.instance;
    if (token.isEmpty) return;
    if (!await bio.isAvailable()) return;

    if (await bio.isEnabled()) {
      final enrolledFor = await bio.accountLabel();

      // Signing in as a different account must not leave the previous user's
      // enrolment in place — biometrics would otherwise unlock whichever
      // account happened to be stored last, under the old account's label.
      if (enrolledFor != null &&
          accountLabel.isNotEmpty &&
          enrolledFor != accountLabel) {
        await bio.disable();
        // Fall through and offer enrolment for the account just signed in.
      } else {
        // Same account — keep the stored token current.
        await bio.refreshTokenIfEnabled(
          token: token,
          accountLabel: accountLabel,
        );
        return;
      }
    }

    if (!mounted) return;
    final label = await bio.biometricLabel();
    if (!mounted) return;

    final wantsIt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enable $label login?'),
        content: Text(
          'Sign in faster next time using $label. '
          'Your password is never stored on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (wantsIt == true) {
      await bio.enable(token: token, accountLabel: accountLabel);
    }
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

        // Register this device for push now that we hold an auth token.
        DeviceTokenService.instance.reset();
        await DeviceTokenService.instance.registerCachedToken();

        final mustChange =
            passwordChangedAt == null || passwordChangedAt.isEmpty;

        // Offer biometric quick-login. Only the session token is stored, and
        // never before the user has a usable (already-changed) password.
        if (!mustChange) {
          await _offerBiometricEnrolment(token, identifier);
        }

        if (mounted) {
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

  /// Cryptographically secure random nonce, bound to the Apple ID request and
  /// echoed back inside the identity token. Prevents token replay.
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
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
      String? rawNonce;

      if (provider == 'google') {
        final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        final account = await googleSignIn.signIn();
        if (account == null) return;
        final auth = await account.authentication;
        idToken = auth.idToken;
        email = account.email;
        name = account.displayName;
      } else if (provider == 'apple') {
        // Bind this request to a one-time nonce. Apple embeds the SHA-256 of
        // it in the identity token; the backend re-derives and compares, so a
        // captured token cannot be replayed.
        rawNonce = _generateNonce();
        final hashedNonce =
            sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
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
        rawNonce: rawNonce,
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

        // Register this device for push now that we hold an auth token.
        DeviceTokenService.instance.reset();
        await DeviceTokenService.instance.registerCachedToken();

        // Keep biometric quick-login usable for social sign-ins too.
        await _offerBiometricEnrolment(token, email ?? name);

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
    } on SignInWithAppleAuthorizationException catch (e) {
      // User dismissing the Apple sheet is not an error worth surfacing.
      if (e.code == AuthorizationErrorCode.canceled) return;
      if (mounted) {
        setState(() {
          _errorMessage = 'Apple sign in failed. Please try again.';
          _showError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Google Sign In throws a PlatformException when the OAuth client ID
          // is missing from GoogleService-Info.plist. Surface a helpful message
          // instead of a misleading "network error".
          _errorMessage = e.toString().contains('GoogleSignIn')
              ? 'Google sign in is not configured yet. Please try another method.'
              : 'Social login failed. Please try again.';
          _showError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhoneInput(bool isDark) {
    final labelColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final inputBg = isDark ? AppColors.inputBgDark : AppColors.surface;
    final borderColor =
        isDark ? AppColors.dividerDark : AppColors.inputBorder;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
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
              // Country code dropdown with flag
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
              // Phone number field
              Expanded(
                child: TextField(
                  controller: _identifierController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.body1.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g. 12 345 6789',
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
      ],
    );
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
            if (_activeTab == 1)
              _buildPhoneInput(isDark)
            else
              AppInput(
                controller: _identifierController,
                label: 'Email or IC Number',
                placeholder: 'e.g. you@email.com or 991111111111',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or IC number';
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

            // ── Forgot password / Verify my account ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
            // The divider is tied to the buttons: with every provider
            // disabled it would otherwise leave a dangling "or continue with"
            // above nothing.
            if (SocialLoginConfig.anyEnabled) ...[
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
            ],
            if (SocialLoginConfig.googleEnabled)
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Continue with Google',
                onPressed:
                    _isLoading ? null : () => _socialLogin('google'),
              ),
            if (SocialLoginConfig.appleEnabled) ...[
              // Only pad above Apple when Google is actually rendered above it.
              if (SocialLoginConfig.googleEnabled)
                const SizedBox(height: AppSpacing.space12),
              _SocialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onPressed:
                    _isLoading ? null : () => _socialLogin('apple'),
              ),
            ],

            // ── Biometric ──
            if (_biometricReady) ...[
              const SizedBox(height: AppSpacing.space24),
              Semantics(
                button: true,
                enabled: _hasSavedBioCreds && !_biometricBusy,
                label: _hasSavedBioCreds
                    ? 'Sign in with $_biometricLabel'
                    : 'Sign in once to enable $_biometricLabel',
                child: GestureDetector(
                  onTap: (_hasSavedBioCreds && !_biometricBusy && !_isLoading)
                      ? () => _loginWithBiometric()
                      : null,
                  child: Opacity(
                    opacity: _hasSavedBioCreds ? 1.0 : 0.5,
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _biometricBusy
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                )
                              : Icon(
                                  _biometricLabel.contains('Face')
                                      ? Icons.face_retouching_natural
                                      : Icons.fingerprint,
                                  size: 48,
                                  color: AppColors.accent,
                                ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          _hasSavedBioCreds
                              ? 'Login with $_biometricLabel'
                              : 'Sign in once to enable $_biometricLabel',
                          style: AppTextStyles.caption.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
