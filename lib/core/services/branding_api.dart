import 'dart:async';
import 'branding_service.dart';

// ============================================================================
// BRANDING API — MOCK LAYER
//
// Replace fetchBranding() with real HTTP call to Admin Panel API:
//   GET /api/v2/config/branding
//
// Response shape:
//   {
//     "app_name": "He Medical Clinic",
//     "app_short_name": "HE",
//     "logo_url": "https://cdn.example.com/logo.png",
//     "splash_logo_url": "https://cdn.example.com/splash.png",
//     "login_logo_url": "https://cdn.example.com/login_logo.png",
//     "appbar_logo_url": "https://cdn.example.com/appbar.png",
//     "tagline": "Your Health, Simplified",
//     "primary_color": "#131C3C"
//   }
// ============================================================================

class BrandingApi {
  // When connected to real API, replace this with HTTP client call.
  // The service gracefully falls back to cache/bundled assets on failure.

  Future<AppBranding?> fetchBranding({int timeoutSeconds = 5}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // ═══════════════════════════════════════════
    // TODO: Replace with real API call:
    //
    // final response = await http.get(
    //   Uri.parse('${EnvConfig.apiBaseUrl}/api/v2/config/branding'),
    //   headers: {'Authorization': 'Bearer $token'},
    // ).timeout(Duration(seconds: timeoutSeconds));
    //
    // if (response.statusCode == 200) {
    //   return AppBranding.fromJson(jsonDecode(response.body));
    // }
    // return null;
    // ═══════════════════════════════════════════

    // Return mock branding — in production this comes from Admin Panel
    return const AppBranding(
      appName: 'He Medical Clinic',
      appShortName: 'HE',
      tagline: 'Your Health, Simplified',
      primaryColorHex: '#131C3C',
      // logoUrl etc. would be set by admin panel
    );
  }
}
