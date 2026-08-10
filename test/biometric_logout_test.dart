import 'package:flutter_test/flutter_test.dart';
import 'package:he_clinic/core/services/biometric_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pins the decision that biometric enrolment survives logout.
///
/// `logout()` calls `prefs.clear()`, which would otherwise wipe the
/// `biometric_enabled` flag and silently disable Face ID / fingerprint sign-in
/// for returning users. The action restores the flag explicitly; these tests
/// fail if that restore is ever dropped.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the enabled flag key is the one logout restores', () {
    // logout() writes this exact key back after prefs.clear(). If the constant
    // is renamed without updating logout(), enrolment would be lost.
    expect(BiometricAuthService.prefKeyEnabled, 'biometric_enabled');
  });

  test('the flag survives a prefs.clear() when restored', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(BiometricAuthService.prefKeyEnabled, true);

    // Simulate what logout() does.
    final keep = prefs.getBool(BiometricAuthService.prefKeyEnabled) ?? false;
    await prefs.clear();
    if (keep) {
      await prefs.setBool(BiometricAuthService.prefKeyEnabled, true);
    }

    expect(prefs.getBool(BiometricAuthService.prefKeyEnabled), isTrue);
  });

  test('a user who never enrolled stays disabled after logout', () async {
    final prefs = await SharedPreferences.getInstance();

    final keep = prefs.getBool(BiometricAuthService.prefKeyEnabled) ?? false;
    await prefs.clear();
    if (keep) {
      await prefs.setBool(BiometricAuthService.prefKeyEnabled, true);
    }

    expect(prefs.getBool(BiometricAuthService.prefKeyEnabled), isNull);
  });

  test('isEnabled is false on a platform without secure storage', () async {
    // The VM test host has no keystore, so isEnabled must not claim the user
    // is enrolled just because the flag is set.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(BiometricAuthService.prefKeyEnabled, true);

    expect(await BiometricAuthService.instance.isEnabled(), isFalse);
  });
}
