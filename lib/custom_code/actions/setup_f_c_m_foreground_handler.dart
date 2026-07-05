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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final _foregroundNotifPlugin = FlutterLocalNotificationsPlugin();
final _handledForegroundMessageIds = <String?>{};

Future<void> setupFCMForegroundHandler() async {
  if (kIsWeb) return;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _navigateToAppointments(payload);
      }
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (_handledForegroundMessageIds.contains(message.messageId)) {
      return;
    }
    _handledForegroundMessageIds.add(message.messageId);

    final notifType = message.data['type'] as String?;
    final msgTitle = message.notification?.title ?? message.data['title'] ?? '';
    final msgBody = message.notification?.body ?? message.data['body'] ?? '';
    final appointmentId =
        message.data['appointment_id'] as String? ?? '';
    final payload = notifType == 'appointment_confirmed'
        ? '{"type":"appointment_confirmed","appointment_id":"$appointmentId"}'
        : '';
    final channelId = notifType == 'appointment_confirmed'
        ? 'appointment_channel_id'
        : 'default_channel_id';

    if (notifType == 'appointment_confirmed') {
      _incrementNotifBadgeForeground();
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            notifType == 'appointment_confirmed'
                ? 'Appointment Notifications'
                : 'Default Channel',
            channelDescription:
                notifType == 'appointment_confirmed'
                    ? 'Notifikasi appointment confirmation'
                    : 'Channel untuk notifikasi FCM di foreground',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload.isNotEmpty ? payload : null,
      );
    } else if (msgTitle.isNotEmpty || msgBody.isNotEmpty) {
      flutterLocalNotificationsPlugin.show(
        message.messageId.hashCode,
        msgTitle,
        msgBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            notifType == 'appointment_confirmed'
                ? 'Appointment Notifications'
                : 'Default Channel',
            channelDescription:
                notifType == 'appointment_confirmed'
                    ? 'Notifikasi appointment confirmation'
                    : 'Channel untuk notifikasi FCM di foreground',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload.isNotEmpty ? payload : null,
      );
    }
  });
}

void _incrementNotifBadgeForeground() {
  try {
    final current = int.parse(FFAppState().coutnnotif);
    FFAppState().update(() {
      FFAppState().coutnnotif = (current + 1).toString();
    });
  } catch (_) {
    FFAppState().update(() {
      FFAppState().coutnnotif = '1';
    });
  }
}

void _navigateToAppointments(String payload) {
  try {
    final navigatorContext = appNavigatorKey.currentContext;
    if (navigatorContext != null) {
      navigatorContext.pushNamed('MyBookingPage');
    }
  } catch (e) {
    print('Error navigating from foreground notification: $e');
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
