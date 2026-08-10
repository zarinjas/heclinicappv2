// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/core/services/biometric_auth_service.dart';

/// Legacy FlutterFlow action, now delegating to [BiometricAuthService].
///
/// Enabling binds the *current* session token to the keystore, so turning the
/// toggle on actually produces something the login screen can unlock. Turning
/// it off wipes the stored token rather than just flipping a flag.
Future<void> saveBiometricStatus(bool biometricEnabled) async {
  final bio = BiometricAuthService.instance;

  if (!biometricEnabled) {
    await bio.disable();
    FFAppState().fingerprint = false;
    return;
  }

  final token = FFAppState().tokenauth;
  if (token.isEmpty) {
    // No live session to protect — do not claim biometrics are enabled.
    await bio.disable();
    FFAppState().fingerprint = false;
    return;
  }

  final ok = await bio.persistToken(token: token);
  FFAppState().fingerprint = ok;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
