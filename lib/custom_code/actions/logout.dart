// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:shared_preferences/shared_preferences.dart';

import '/core/services/biometric_auth_service.dart';
import '/core/services/device_token_service.dart';

Future<void> logout() async {
  // Biometric enrolment deliberately SURVIVES logout so the user can sign back
  // in with one Face ID / fingerprint tap instead of retyping credentials.
  //
  // The stored token stays in the Keychain / EncryptedSharedPreferences and is
  // only readable after a successful biometric check, so it remains protected
  // by the device's own biometrics. Anyone enrolled on the phone can therefore
  // re-enter this account after a logout — that is the accepted trade-off for
  // a personal device. Turning the toggle off in Settings, or signing in as a
  // different account, erases it.
  final bio = BiometricAuthService.instance;
  final keepBiometric = await bio.isEnabled();

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Menghapus semua data

  // prefs.clear() wiped the enabled flag, so restore it. The token itself
  // lives in the keystore and was never touched by clear().
  if (keepBiometric) {
    await prefs.setBool(BiometricAuthService.prefKeyEnabled, true);
  } else {
    // Nothing usable stored — make sure no stale secret is left behind.
    await bio.disable();
  }

  // Reset in-memory auth state so the app treats the user as logged out
  // (router + splash check these values to decide where to navigate).
  FFAppState().isLoggedIn = false;
  FFAppState().tokenauth = '';
  FFAppState().fingerprint = keepBiometric;
  // Forget the cached push registration so the next login re-registers this
  // device against the new account.
  DeviceTokenService.instance.reset();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
