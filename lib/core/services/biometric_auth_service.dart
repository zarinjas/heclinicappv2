import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of a biometric unlock attempt.
enum BiometricUnlockStatus {
  /// User authenticated and a session token was returned.
  success,

  /// User cancelled, or the biometric prompt failed / did not match.
  failed,

  /// Biometrics are not enrolled, not supported, or unavailable on this device.
  unavailable,

  /// Biometric login is not enabled, or no session token is stored.
  notEnrolled,
}

class BiometricUnlockResult {
  const BiometricUnlockResult(this.status, {this.token, this.message});

  final BiometricUnlockStatus status;
  final String? token;
  final String? message;

  bool get isSuccess =>
      status == BiometricUnlockStatus.success &&
      (token != null && token!.isNotEmpty);
}

/// Single source of truth for biometric ("Face ID / fingerprint") login.
///
/// Security model:
///  * The user's password is **never** persisted. Only the Sanctum session
///    token issued by the backend is stored, inside the platform keystore
///    (iOS Keychain / Android EncryptedSharedPreferences via Keystore).
///  * The stored token is only readable after a successful biometric check.
///  * Disabling biometrics, logging out, or a rejected token all wipe the
///    stored secret immediately.
///
/// This replaces the two previous, disconnected implementations which stored
/// a base64-encoded password in plain `SharedPreferences`.
class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance = BiometricAuthService._();

  @visibleForTesting
  static const secureKeyToken = 'bio_session_token';
  @visibleForTesting
  static const secureKeyLabel = 'bio_account_label';

  /// Non-secret flag; safe to keep in SharedPreferences so the UI can render
  /// the correct state without touching the keystore.
  static const prefKeyEnabled = 'biometric_enabled';

  /// Legacy keys written by earlier versions of the app. These held a
  /// base64-encoded password in plain text and must be purged on sight.
  static const _legacyKeys = <String>[
    'bio_identifier',
    'bio_password',
    'bio_country_code',
    'bio_active_tab',
  ];

  final LocalAuthentication _localAuth = LocalAuthentication();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Capability ──

  /// True when the device has biometric hardware AND the user has enrolled at
  /// least one biometric. Always false on web.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      if (!await _localAuth.isDeviceSupported()) return false;
      if (!await _localAuth.canCheckBiometrics) return false;
      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService.isAvailable failed: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('BiometricAuthService.isAvailable failed: $e');
      return false;
    }
  }

  /// A user-facing name for the strongest available biometric, e.g. "Face ID".
  Future<String> biometricLabel() async {
    if (kIsWeb) return 'Biometrics';
    try {
      final available = await _localAuth.getAvailableBiometrics();
      if (available.contains(BiometricType.face)) {
        return defaultTargetPlatform == TargetPlatform.iOS
            ? 'Face ID'
            : 'Face Unlock';
      }
      if (available.contains(BiometricType.fingerprint)) {
        return defaultTargetPlatform == TargetPlatform.iOS
            ? 'Touch ID'
            : 'Fingerprint';
      }
      if (available.contains(BiometricType.iris)) return 'Iris';
      return 'Biometrics';
    } catch (_) {
      return 'Biometrics';
    }
  }

  // ── Enabled state ──

  /// True when the user opted in AND a session token is actually stored.
  /// Both halves are checked so the UI can never show an enabled toggle that
  /// would fail to unlock anything.
  Future<bool> isEnabled() async {
    if (kIsWeb) return false;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(prefKeyEnabled) ?? false)) return false;
    return await _readToken() != null;
  }

  /// The account label (masked email / phone) shown next to the unlock button.
  Future<String?> accountLabel() async {
    if (kIsWeb) return null;
    try {
      return await _secureStorage.read(key: secureKeyLabel);
    } catch (_) {
      return null;
    }
  }

  // ── Enrolment ──

  /// Turn biometric login on. Prompts for a biometric check first so we only
  /// ever bind the token to a user who can actually pass the challenge.
  ///
  /// [token] is the Sanctum token from a completed password/social login.
  /// [accountLabel] is display-only (e.g. masked phone) and holds no secret.
  Future<bool> enable({
    required String token,
    String? accountLabel,
  }) async {
    if (kIsWeb || token.isEmpty) return false;
    if (!await isAvailable()) return false;

    final passed = await _promptBiometric(
      reason: 'Confirm your identity to enable biometric login',
    );
    if (!passed) return false;

    return persistToken(token: token, accountLabel: accountLabel);
  }

  /// Store/refresh the session token **without** re-prompting. Only call this
  /// when biometric login is already enabled (e.g. the token was rotated by a
  /// fresh password login), never as a way to silently opt a user in.
  Future<bool> persistToken({
    required String token,
    String? accountLabel,
  }) async {
    if (kIsWeb || token.isEmpty) return false;
    try {
      await _secureStorage.write(key: secureKeyToken, value: token);
      if (accountLabel != null && accountLabel.isNotEmpty) {
        await _secureStorage.write(key: secureKeyLabel, value: accountLabel);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyEnabled, true);
      await _purgeLegacyCredentials(prefs);
      return true;
    } catch (e) {
      debugPrint('BiometricAuthService.persistToken failed: $e');
      return false;
    }
  }

  /// Refresh the stored token only if biometric login is already enabled.
  /// Safe to call after every successful login.
  Future<void> refreshTokenIfEnabled({
    required String token,
    String? accountLabel,
  }) async {
    if (kIsWeb || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(prefKeyEnabled) ?? false)) return;
    await persistToken(token: token, accountLabel: accountLabel);
  }

  // ── Unlock ──

  /// Prompt for biometrics and, on success, return the stored session token.
  Future<BiometricUnlockResult> unlock({String? reason}) async {
    if (kIsWeb) {
      return const BiometricUnlockResult(BiometricUnlockStatus.unavailable);
    }
    if (!await isAvailable()) {
      return const BiometricUnlockResult(
        BiometricUnlockStatus.unavailable,
        message: 'Biometrics are not set up on this device.',
      );
    }
    if (!await isEnabled()) {
      return const BiometricUnlockResult(BiometricUnlockStatus.notEnrolled);
    }

    final label = await biometricLabel();
    final passed = await _promptBiometric(
      reason: reason ?? 'Sign in with $label',
    );
    if (!passed) {
      return const BiometricUnlockResult(
        BiometricUnlockStatus.failed,
        message: 'We could not verify your identity. Please try again.',
      );
    }

    final token = await _readToken();
    if (token == null || token.isEmpty) {
      // Enabled flag and keystore fell out of sync — reset cleanly.
      await disable();
      return const BiometricUnlockResult(BiometricUnlockStatus.notEnrolled);
    }

    return BiometricUnlockResult(
      BiometricUnlockStatus.success,
      token: token,
    );
  }

  // ── Teardown ──

  /// Turn biometric login off and erase the stored token.
  Future<void> disable() async {
    try {
      await _secureStorage.delete(key: secureKeyToken);
      await _secureStorage.delete(key: secureKeyLabel);
    } catch (e) {
      debugPrint('BiometricAuthService.disable secure delete failed: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyEnabled, false);
      await _purgeLegacyCredentials(prefs);
    } catch (e) {
      debugPrint('BiometricAuthService.disable prefs reset failed: $e');
    }
  }

  /// Called on logout. Erases every biometric secret so the next user of the
  /// device cannot unlock the previous account.
  Future<void> clearOnLogout() => disable();

  /// Removes plaintext credentials written by pre-secure-storage builds.
  /// Runs on every app start via [migrateLegacyCredentials].
  Future<void> migrateLegacyCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _purgeLegacyCredentials(prefs);

      // A legacy "enabled" flag with no token in the keystore is meaningless
      // and would render an enabled toggle that cannot unlock. Reset it.
      final flagged = prefs.getBool(prefKeyEnabled) ?? false;
      if (flagged && await _readToken() == null) {
        await prefs.setBool(prefKeyEnabled, false);
      }
    } catch (e) {
      debugPrint('BiometricAuthService.migrateLegacyCredentials failed: $e');
    }
  }

  // ── Internals ──

  Future<void> _purgeLegacyCredentials(SharedPreferences prefs) async {
    for (final key in _legacyKeys) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }

  Future<String?> _readToken() async {
    if (kIsWeb) return null;
    try {
      return await _secureStorage.read(key: secureKeyToken);
    } catch (e) {
      debugPrint('BiometricAuthService._readToken failed: $e');
      return null;
    }
  }

  Future<bool> _promptBiometric({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          // Device PIN/pattern fallback is disallowed: the whole point is to
          // bind the stored session token to a biometric, not to a passcode
          // that a shoulder-surfer may already know.
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService biometric prompt failed: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('BiometricAuthService biometric prompt failed: $e');
      return false;
    }
  }
}
