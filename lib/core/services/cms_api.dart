import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../env_config.dart';
import 'models/clinic_info.dart';
import 'models/hero_banner.dart';
import 'models/article.dart';
import 'models/video.dart';
import 'models/service_package.dart';
import 'models/doctor.dart';
import 'models/branch.dart';
import 'models/promotion.dart';
import 'models/onboarding_slide.dart';
import 'models/telehealth_config.dart';
import 'models/legal_page.dart';
import 'models/app_info.dart';

class CmsApiException implements Exception {
  final String path;
  CmsApiException(this.path);
  @override
  String toString() => 'CmsApiException: failed to fetch $path';
}

class CmsApi {
  static const _timeoutSeconds = 3;
  static const _basePath = '/v2';

  /// The base URL that last answered a CMS request successfully. Used to
  /// rebase media URLs (images/videos) that Laravel built from its own
  /// `APP_URL` (often `http://localhost:8080`) onto a host the device can
  /// actually reach — e.g. `10.0.2.2` on the Android emulator.
  static String? _lastSuccessfulBase;
  static String? get lastSuccessfulBase => _lastSuccessfulBase;

  static bool _isLoopbackHost(String host) {
    final h = host.toLowerCase();
    return h == 'localhost' || h == '127.0.0.1' || h == '::1';
  }

  /// Scheme://host[:port] of the API server (without the `/api` suffix),
  /// preferring whichever base actually served the CMS data.
  static String get mediaOrigin {
    final base = _lastSuccessfulBase ?? EnvConfig.laravelBaseUrl;
    final uri = Uri.tryParse(base);
    if (uri == null || uri.host.isEmpty) return '';
    final scheme = uri.scheme.isEmpty ? 'http' : uri.scheme;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$port';
  }

  /// Rewrites a CMS media URL so it is reachable from the device.
  ///
  /// - Fully-qualified URLs on a real (non-loopback) host are returned as-is.
  /// - Relative paths (e.g. `/storage/onboarding/x.mp4`) get the API origin
  ///   prepended.
  /// - Loopback URLs (`http://localhost:8080/...`, `http://127.0.0.1/...`)
  ///   are rebased onto the host/port the app actually talks to.
  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.hasScheme && !_isLoopbackHost(uri.host)) return url;

    final origin = mediaOrigin;
    if (origin.isEmpty) return url;

    final path = uri.hasScheme
        ? (uri.path.isEmpty ? '/' : uri.path)
        : (url.startsWith('/') ? url : '/$url');
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return '$origin$path$query';
  }

  static List<String> _baseUrls() {
    // Production mode (dart-define set to real URLs) → go straight to the
    // configured Laravel URL. No localhost fallback, no 3s timeouts wasted.
    if (!EnvConfig.isMock) {
      return [EnvConfig.laravelBaseUrl];
    }

    // Mock/local dev → try local servers first, then production.
    return [
      'http://localhost:4000/api',
      'http://127.0.0.1:4000/api',
      'http://10.0.2.2:4000/api',
      'http://localhost:8080/api',
      'http://127.0.0.1:8080/api',
      'http://10.0.2.2:8080/api',
      'http://localhost:8000/api',
      EnvConfig.laravelBaseUrl,
    ];
  }

  static Future<String> _fetch(String path) async {
    for (final base in _baseUrls()) {
      final url = '$base$_basePath/$path';
      debugPrint('[CMS API] GET $url');
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: _timeoutSeconds));
        if (response.statusCode == 200) {
          _lastSuccessfulBase = base;
          debugPrint('[CMS API] OK 200 — ${response.body.length} bytes');
          return response.body;
        }
        debugPrint('[CMS API] HTTP ${response.statusCode}');
      } catch (e) {
        debugPrint('[CMS API] FAIL $e');
        continue;
      }
    }
    debugPrint('[CMS API] ALL URLs FAILED');
    throw CmsApiException(path);
  }

  // ── Sliders ──

  static Future<List<HeroBanner>> fetchSliders() async {
    final body = await _fetch('cms/sliders');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => HeroBanner.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Articles ──

  static Future<CmsArticleListResponse> fetchArticles({
    int limit = 10,
    int page = 1,
    String? category,
    bool? featured,
  }) async {
    final query = StringBuffer('cms/articles?limit=$limit&page=$page');
    if (category != null && category.isNotEmpty) {
      query.write('&category=${Uri.encodeQueryComponent(category)}');
    }
    if (featured == true) {
      query.write('&featured=true');
    }
    final body = await _fetch(query.toString());
    final json = jsonDecode(body) as Map<String, dynamic>;
    return CmsArticleListResponse.fromJson(json);
  }

  static Future<Article?> fetchArticleBySlug(String slug) async {
    final body = await _fetch('cms/articles/$slug');
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (json['error'] == true) return null;
    return Article.fromJson(json);
  }

  static Future<List<String>> fetchArticleCategories() async {
    final body = await _fetch('cms/article-categories');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => e is Map<String, dynamic> ? e['name'] as String? : null)
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toList();
  }

  // ── Videos ──

  static Future<CmsVideoListResponse> fetchVideos({
    int limit = 10,
    int page = 1,
  }) async {
    final body = await _fetch('cms/videos?limit=$limit&page=$page');
    final json = jsonDecode(body) as Map<String, dynamic>;
    return CmsVideoListResponse.fromJson(json);
  }

  // ── Service Packages ──

  static Future<List<ServicePackage>> fetchServicePackages() async {
    final body = await _fetch('cms/service-packages');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => ServicePackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Doctors ──

  static Future<List<Doctor>> fetchDoctors({String? branchId}) async {
    final query = branchId != null ? '?branch_id=$branchId' : '';
    final body = await _fetch('config/doctors$query');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Branches ──

  static Future<List<Branch>> fetchBranches() async {
    final body = await _fetch('config/branches');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => Branch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Health Tips (Articles filtered by category) ──

  static Future<List<Article>> fetchHealthTips() async {
    final body = await _fetch('cms/articles?limit=20&page=1');
    final json = jsonDecode(body) as Map<String, dynamic>;
    final list = (json['data'] as List<dynamic>)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .where((a) =>
            a.category != null &&
            a.category!.toLowerCase().contains('health'))
        .toList();
    return list;
  }

  // ── Promotions ──

  static Future<List<Promotion>> fetchPromotions() async {
    final body = await _fetch('cms/promotions');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Clinic Info ──

  static Future<List<ClinicInfo>> fetchClinicInfos() async {
    final body = await _fetch('cms/clinic-info');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => ClinicInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Onboarding Slides ──

  static Future<List<OnboardingSlide>> fetchOnboardingSlides() async {
    final body = await _fetch('cms/onboarding-slides');
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => OnboardingSlide.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Telehealth ──

  static Future<TelehealthConfig> fetchTelehealthConfig() async {
    final body = await _fetch('config/telehealth');
    final json = jsonDecode(body) as Map<String, dynamic>;
    return TelehealthConfig.fromJson(json);
  }

  // ── Legal Pages ──

  static Future<LegalPage> fetchLegalPage(String slug) async {
    final body = await _fetch('cms/legal/$slug');
    final json = jsonDecode(body) as Map<String, dynamic>;
    return LegalPage.fromJson(json);
  }

  // ── Contact & About (App Info) ──

  static Future<AppInfo> fetchAppInfo() async {
    final body = await _fetch('config/app-info');
    final json = jsonDecode(body) as Map<String, dynamic>;
    return AppInfo.fromJson(json);
  }
}

class CmsArticleListResponse {
  final List<Article> data;
  final int total;
  final int currentPage;
  final int lastPage;

  const CmsArticleListResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory CmsArticleListResponse.fromJson(Map<String, dynamic> json) {
    return CmsArticleListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ??
          (json['lastPage'] as int? ?? 1),
    );
  }
}

class CmsVideoListResponse {
  final List<Video> data;
  final int total;
  final int currentPage;
  final int lastPage;

  const CmsVideoListResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory CmsVideoListResponse.fromJson(Map<String, dynamic> json) {
    return CmsVideoListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ??
          (json['lastPage'] as int? ?? 1),
    );
  }
}
