import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../env_config.dart';
import 'branding_service.dart';

// ============================================================================
// BRANDING API — REQUEST LAYER
//
// Fetches branding from Laravel Admin Panel API.
// Falls back to bundled mock data when offline.
//
// API: GET /api/v2/config/branding (public, no auth required)
// ============================================================================

class BrandingApi {
  Future<AppBranding?> fetchBranding({int timeoutSeconds = 5}) async {
    // Production mode → fetch straight from the configured Laravel URL.
    // No localhost fallback that would waste 2s timeouts on every startup.
    if (!EnvConfig.isMock) {
      return _fetchSingle(
          '${EnvConfig.laravelBaseUrl}/v2/config/branding', timeoutSeconds);
    }

    // Mock/local dev → try localhost first, fall back to production URL.
    final urls = [
      'http://localhost:4000/api/v2/config/branding',
      'http://127.0.0.1:4000/api/v2/config/branding',
      'http://localhost:8080/api/v2/config/branding',
      'http://127.0.0.1:8080/api/v2/config/branding',
      'http://localhost:8000/api/v2/config/branding',
      '${EnvConfig.laravelBaseUrl}/v2/config/branding',
    ];

    for (final url in urls) {
      final result = await _fetchSingle(url, timeoutSeconds);
      if (result != null) return result;
    }

    // All URLs failed — return null to use cache/fallback
    return null;
  }

  Future<AppBranding?> _fetchSingle(String url, int timeoutSeconds) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppBranding.fromJson(data);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
