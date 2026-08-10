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

import '/core/services/device_token_service.dart';

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Menghapus semua data
  // Reset in-memory auth state so the app treats the user as logged out
  // (router + splash check these values to decide where to navigate).
  FFAppState().isLoggedIn = false;
  FFAppState().tokenauth = '';
  // Forget the cached push registration so the next login re-registers this
  // device against the new account.
  DeviceTokenService.instance.reset();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
