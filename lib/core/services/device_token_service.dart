import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';

/// Keeps the backend's copy of this device's FCM token up to date.
///
/// Push delivery previously relied on a token captured only at login and
/// written to a Firestore document from a screen that is no longer rendered.
/// That meant the backend had no token it could target, so notifications were
/// generated but never delivered. This service pushes the token to Laravel
/// (`POST /v2/auth/device-token`) after login and again whenever FCM rotates
/// it, which is the only location the backend reads when sending.
class DeviceTokenService {
  DeviceTokenService._();

  static final DeviceTokenService instance = DeviceTokenService._();

  bool _listening = false;
  String? _lastRegistered;

  /// Fetch the current token, send it to the backend, and start listening for
  /// rotations. Safe to call more than once.
  Future<void> register() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        FFAppState().fcmtoken = token;
        await _send(token);
      }
    } catch (e) {
      debugPrint('[DeviceToken] Failed to read FCM token: $e');
    }

    _startListening();
  }

  /// Register whatever token is already cached in app state, without hitting
  /// FCM again. Used right after login when the token was fetched at startup.
  Future<void> registerCachedToken() async {
    final token = FFAppState().fcmtoken;
    if (token.isEmpty) {
      await register();
      return;
    }

    await _send(token);
    _startListening();
  }

  void _startListening() {
    if (_listening) return;
    _listening = true;

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (token.isEmpty) return;
      FFAppState().fcmtoken = token;
      await _send(token);
    }, onError: (Object e) {
      debugPrint('[DeviceToken] Token refresh stream error: $e');
    });
  }

  Future<void> _send(String fcmToken) async {
    final authToken = FFAppState().tokenauth;

    // The endpoint is authenticated, so there is nothing useful to do until
    // the patient has logged in. The next login will re-register.
    if (authToken.isEmpty) return;

    // Avoid redundant writes when the token has not actually changed.
    if (_lastRegistered == fcmToken) return;

    try {
      final response = await HeclinicAuthApi.registerDeviceTokenCall.call(
        token: authToken,
        fcmToken: fcmToken,
      );

      if (response.succeeded) {
        _lastRegistered = fcmToken;
      } else {
        debugPrint('[DeviceToken] Register failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[DeviceToken] Register error: $e');
    }
  }

  /// Forget the locally cached registration so the next login re-sends.
  void reset() {
    _lastRegistered = null;
  }
}
