import 'package:shared_preferences/shared_preferences.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';

/// Silently rotates the 90-day mobile access token while it is still valid.
///
/// Without this, a patient who keeps the app installed for months eventually
/// hits the hard `TOKEN_TTL_DAYS` expiry on the backend and is logged out
/// with no warning — every endpoint (including document/record downloads,
/// which bypass the normal "session expired" flow) starts returning 401.
/// Refreshing on every app open while the token is still valid means an
/// active user's session effectively never expires.
class TokenRefreshService {
  TokenRefreshService._();

  static final instance = TokenRefreshService._();

  static const _prefKeyLastRefresh = 'token_last_refreshed_at';
  static const _minInterval = Duration(days: 1);

  Future<void> maybeRefresh() async {
    final appState = FFAppState();
    final token = appState.tokenauth;
    if (!appState.isLoggedIn || token.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_prefKeyLastRefresh);
      if (lastMs != null) {
        final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
        if (DateTime.now().difference(last) < _minInterval) return;
      }

      final response = await RefreshTokenCall().call(token: token);
      // A failed refresh (including 401 for an already-dead token) leaves the
      // current token untouched; other API calls will surface the real
      // session-expired flow on their own if it has in fact expired.
      if (!response.succeeded) return;

      final newToken = RefreshTokenCall.token(response.jsonBody);
      if (newToken == null || newToken.isEmpty) return;

      appState.tokenauth = newToken;
      await prefs.setInt(
        _prefKeyLastRefresh,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Best-effort only — the existing token keeps working regardless.
    }
  }
}
