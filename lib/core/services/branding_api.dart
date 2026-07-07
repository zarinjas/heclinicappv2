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
    // Try localhost first (dev), fall back to production URL
    final urls = [
      'http://localhost:8080/api/v2/config/branding',
      'http://127.0.0.1:8080/api/v2/config/branding',
      'http://localhost:8000/api/v2/config/branding',
      '${EnvConfig.laravelBaseUrl}/v2/config/branding',
    ];

    for (final url in urls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(Duration(seconds: timeoutSeconds));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return AppBranding.fromJson(data);
        }
      } catch (_) {
        continue; // Try next URL
      }
    }

    // All URLs failed — return null to use cache/fallback
    return null;
  }
}
