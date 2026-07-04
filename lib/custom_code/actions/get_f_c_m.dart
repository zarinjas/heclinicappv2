// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFCM() async {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  try {
    // Ambil token FCM
    String? token = await fcm.getToken();
    if (token == null || token.isEmpty) {
      print("FCM token is null or empty");
      return null;
    }

    print("INI FCM : $token");

    // Simpan ke FFAppState
    FFAppState().fcmtoken = token;

    // Subscribe ke topic
    await fcm
        .subscribeToTopic("allUsers")
        .timeout(Duration(seconds: 2))
        .then((_) {
      print("Subscribed to topic allUsers");
    }).catchError((error) {
      print("Failed to subscribe to topic allUsers: $error");
    });

    return token;
  } catch (e) {
    return "Failed to get FCM token or subscribe: $e";
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
