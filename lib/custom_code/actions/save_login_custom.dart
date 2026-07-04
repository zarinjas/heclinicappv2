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

Future<void> saveLoginCustom(
    String email, String token, String tokenfcm) async {
  final prefs = await SharedPreferences.getInstance();
  print(email);
  print(token);
  print(tokenfcm);
  FFAppState().tokenauth = token;
  FFAppState().fcmtoken = tokenfcm;
  await prefs.setString('user_email', email);
  await prefs.setString('fcm_token', tokenfcm);
  await prefs.setString('tokenuser', token);
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
