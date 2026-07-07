import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'branding_api.dart';

// ============================================================================
// BRANDING DATA MODEL
// ============================================================================

class AppBranding {
  final String appName;
  final String appShortName;
  final String? logoUrl;
  final String? splashLogoUrl;
  final String? loginLogoUrl;
  final String? appBarLogoUrl;
  final String? tagline;
  final String? primaryColorHex;
  final String? splashBgColorHex;

  const AppBranding({
    required this.appName,
    required this.appShortName,
    this.logoUrl,
    this.splashLogoUrl,
    this.loginLogoUrl,
    this.appBarLogoUrl,
    this.tagline,
    this.primaryColorHex,
    this.splashBgColorHex,
  });

  factory AppBranding.fromJson(Map<String, dynamic> json) {
    return AppBranding(
      appName: json['app_name'] as String? ?? 'He Medical Clinic',
      appShortName: json['app_short_name'] as String? ?? 'HE',
      logoUrl: json['logo_url'] as String?,
      splashLogoUrl: json['splash_logo_url'] as String?,
      loginLogoUrl: json['login_logo_url'] as String?,
      appBarLogoUrl: json['appbar_logo_url'] as String?,
      tagline: json['tagline'] as String?,
      primaryColorHex: json['primary_color'] as String?,
      splashBgColorHex: json['splash_bg_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'app_name': appName,
    'app_short_name': appShortName,
    'logo_url': logoUrl,
    'splash_logo_url': splashLogoUrl,
    'login_logo_url': loginLogoUrl,
    'appbar_logo_url': appBarLogoUrl,
    'tagline': tagline,
    'primary_color': primaryColorHex,
    'splash_bg_color': splashBgColorHex,
  };

  // Default bundled fallback — never null
  static const fallback = AppBranding(
    appName: 'He Medical Clinic',
    appShortName: 'HE',
    tagline: 'Your Health, Simplified',
    primaryColorHex: '#131C3C',
  );
}

// ============================================================================
// BRANDING SERVICE — SINGLETON
// ============================================================================

class BrandingService {
  BrandingService._();
  static final BrandingService _instance = BrandingService._();
  static BrandingService get instance => _instance;

  static const _cacheKey = 'branding_cache';
  static const _cacheTimestampKey = 'branding_cache_timestamp';
  static const _cacheDuration = Duration(hours: 24);

  AppBranding? _cached;
  bool _initialised = false;
  final BrandingApi _api = BrandingApi();

  // ── Initialization ──

  Future<void> init() async {
    if (_initialised) return;

    _cached = await _loadFromCache();

    try {
      final remote = await _api.fetchBranding(timeoutSeconds: 5);
      if (remote != null) {
        _cached = remote;
        await _saveToCache(remote);
      }
    } catch (_) {
      // Silent — fall back to cache or bundled defaults
    }

    _initialised = true;
  }

  void initWith(AppBranding branding) {
    _cached = branding;
    _initialised = true;
  }

  // ── Getters — always returns non-null branding ──

  AppBranding get branding {
    if (_cached != null) return _cached!;
    return AppBranding.fallback;
  }

  String get appName => branding.appName;
  String get appShortName => branding.appShortName;
  String get tagline => branding.tagline ?? 'Your Health, Simplified';
  String? get logoUrl => branding.logoUrl;
  String? get splashLogoUrl => branding.splashLogoUrl;
  String? get loginLogoUrl => branding.loginLogoUrl;
  String? get appBarLogoUrl => branding.appBarLogoUrl;
  Color get splashBgColor {
    if (branding.splashBgColorHex != null) {
      final hex = branding.splashBgColorHex!.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    if (branding.primaryColorHex != null) {
      final hex = branding.primaryColorHex!.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return AppColors.primary;
  }

  // ── Refresh from API ──

  Future<bool> refresh() async {
    try {
      final remote = await _api.fetchBranding(timeoutSeconds: 5);
      if (remote != null) {
        _cached = remote;
        await _saveToCache(remote);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Cache — SharedPreferences ──

  Future<AppBranding?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;

      if (raw == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > _cacheDuration.inMilliseconds) return null;

      return AppBranding.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(AppBranding branding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(branding.toJson()));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  // ── Clear cache (for logout / reset) ──

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
    _cached = null;
  }
}
