import 'package:flutter/foundation.dart';

import 'api_manager.dart';

typedef OnUnauthorizedCallback = void Function();
typedef OnServerErrorCallback = void Function(int statusCode, String callName);
typedef OnNetworkErrorCallback = void Function(String message);
typedef OnClientErrorCallback = void Function(int statusCode, String callName, String apiUrl);
typedef OnRateLimitedCallback = void Function(String callName);

class ApiInterceptor {
  ApiInterceptor._();

  static final ApiInterceptor _instance = ApiInterceptor._();
  static ApiInterceptor get instance => _instance;

  /// Auth calls return 401 for invalid credentials — NOT session expiry.
  /// These must never trigger the global "session expired" logout flow.
  static const Set<String> _authCallNames = {
    'HeclinicLogin',
    'HeclinicRegister',
    'HeclinicSocialLogin',
    'CheckNric',
    'CheckPhone',
    'HeclinicForgotPassword',
    'HeclinicClaimAccount',
    'HeclinicVerifyOtp',
    'HeclinicResetPassword',
    'HeclinicChangePasswordFirst',
    'HeclinicLogout',
    'HeclinicRegisterDeviceToken',
  };

  OnUnauthorizedCallback? onUnauthorized;
  OnServerErrorCallback? onServerError;
  OnNetworkErrorCallback? onNetworkError;
  OnClientErrorCallback? onClientError;
  OnRateLimitedCallback? onRateLimited;

  bool _isHandling = false;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  void handleResponse(ApiCallResponse response, ApiCallOptions options) {
    if (_isHandling) return;

    if (response.exception != null) {
      _handleNetworkError(response);
      return;
    }

    _isOffline = false;

    final statusCode = response.statusCode;

    if (statusCode == 401) {
      // A 401 from an auth endpoint means bad credentials, not session expiry.
      // Let the calling screen show the real error message instead.
      if (!_authCallNames.contains(options.callName)) {
        _handleUnauthorized();
      }
    } else if (statusCode == 429) {
      debugPrint('ApiInterceptor: Rate limited on ${options.callName}');
      onRateLimited?.call(options.callName);
    } else if (statusCode >= 500 && statusCode < 600) {
      _handleServerError(statusCode, options.callName);
    } else if (statusCode >= 400) {
      onClientError?.call(statusCode, options.callName, options.apiUrl);
    }
  }

  void _handleUnauthorized() {
    _isHandling = true;
    try {
      onUnauthorized?.call();
    } finally {
      _isHandling = false;
    }
  }

  void _handleServerError(int statusCode, String callName) {
    debugPrint('ApiInterceptor: Server error $statusCode on $callName');
    onServerError?.call(statusCode, callName);
  }

  void _handleNetworkError(ApiCallResponse response) {
    _isOffline = true;
    final message = response.exception.toString();
    debugPrint('ApiInterceptor: Network error — $message');
    onNetworkError?.call('No internet connection — showing last synced data');
  }
}
