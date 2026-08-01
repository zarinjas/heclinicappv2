import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../env_config.dart';
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

class CmsApiException implements Exception {
  final String path;
  CmsApiException(this.path);
  @override
  String toString() => 'CmsApiException: failed to fetch $path';
}

class CmsApi {
  static const _timeoutSeconds = 3;
  static const _basePath = '/v2';

  static List<String> _baseUrls() => [
    'http://localhost:8080/api',
    'http://127.0.0.1:8080/api',
    'http://10.0.2.2:8080/api',
    'http://localhost:8000/api',
    '${EnvConfig.laravelBaseUrl}',
  ];

  static Future<String> _fetch(String path) async {
    for (final base in _baseUrls()) {
      final url = '$base$_basePath/$path';
      debugPrint('[CMS API] GET $url');
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: _timeoutSeconds));
        if (response.statusCode == 200) {
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
