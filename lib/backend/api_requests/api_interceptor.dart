import 'package:flutter/foundation.dart';

import 'api_manager.dart';

typedef OnUnauthorizedCallback = void Function();
typedef OnServerErrorCallback = void Function(int statusCode, String callName);
typedef OnNetworkErrorCallback = void Function(String message);
typedef OnClientErrorCallback = void Function(int statusCode, String callName, String apiUrl);

class ApiInterceptor {
  ApiInterceptor._();

  static final ApiInterceptor _instance = ApiInterceptor._();
  static ApiInterceptor get instance => _instance;

  OnUnauthorizedCallback? onUnauthorized;
  OnServerErrorCallback? onServerError;
  OnNetworkErrorCallback? onNetworkError;
  OnClientErrorCallback? onClientError;

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
      _handleUnauthorized();
    } else if (statusCode == 429) {
      // P3-T04 will handle 429 with exponential backoff
      // For now, let it pass through to caller
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
