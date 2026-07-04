// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> requestNotificationPermissionsUser() async {
  if (kIsWeb) return;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (Platform.isAndroid) {
    // Minta izin di Android
    final status = await Permission.notification.request();

    if (status.isDenied) {
      print("Izin notifikasi ditolak (Android)");
    } else if (status.isGranted) {
      print("Izin notifikasi diberikan (Android)");
    } else if (status.isPermanentlyDenied) {
      print("Izin notifikasi diblokir permanen (Android)");
      openAppSettings(); // Buka pengaturan
    }
  } else if (Platform.isIOS) {
    // Minta izin di iOS via flutter_local_notifications
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (granted == true) {
      print("Izin notifikasi diberikan (iOS)");
    } else {
      print("Izin notifikasi ditolak (iOS)");
    }
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
