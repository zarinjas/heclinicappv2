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

/// Legacy FlutterFlow action, now delegating to [BiometricAuthService] so the
/// old splash/setup screens and the new login screen agree on a single source
/// of truth. Returns true only when the user opted in AND a session token is
/// actually present in the keystore to unlock.
Future<bool> loadBiometricStatus() async {
  return BiometricAuthService.instance.isEnabled();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
