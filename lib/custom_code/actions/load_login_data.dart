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

Future<String?> loadLoginData() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('tokenuser');
  String? tokenfcm = prefs.getString('fcm_token');
  // Jika token null, isi dengan string kosong
  token ??= '';
  tokenfcm ??= '';

  FFAppState().tokenauth = token;
  FFAppState().fcmtoken = tokenfcm;
  return token;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
