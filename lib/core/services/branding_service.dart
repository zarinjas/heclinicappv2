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
  final String? loadingGifUrl;
  final String? tagline;
  final String? primaryColorHex;
  final String? accentColorHex;
  final String? splashBgColorHex;
  final String? welcomeBgColorHex;
  final String? welcomeBgGradientHex;
  final String? welcomeButtonColorHex;
  final double? welcomeLogoSize;

  const AppBranding({
    required this.appName,
    required this.appShortName,
    this.logoUrl,
    this.splashLogoUrl,
    this.loginLogoUrl,
    this.appBarLogoUrl,
    this.loadingGifUrl,
    this.tagline,
    this.primaryColorHex,
    this.accentColorHex,
    this.splashBgColorHex,
    this.welcomeBgColorHex,
    this.welcomeBgGradientHex,
    this.welcomeButtonColorHex,
    this.welcomeLogoSize,
  });

  factory AppBranding.fromJson(Map<String, dynamic> json) {
    return AppBranding(
      appName: json['app_name'] as String? ?? 'He Medical Clinic',
      appShortName: json['app_short_name'] as String? ?? 'HE',
      logoUrl: json['logo_url'] as String?,
      splashLogoUrl: json['splash_logo_url'] as String?,
      loginLogoUrl: json['login_logo_url'] as String?,
      appBarLogoUrl: json['appbar_logo_url'] as String?,
      loadingGifUrl: json['loading_gif_url'] as String?,
      tagline: json['tagline'] as String?,
      primaryColorHex: json['primary_color'] as String?,
      accentColorHex: json['accent_color'] as String?,
      splashBgColorHex: json['splash_bg_color'] as String?,
      welcomeBgColorHex: json['welcome_bg_color'] as String?,
      welcomeBgGradientHex: json['welcome_bg_gradient_color'] as String?,
      welcomeButtonColorHex: json['welcome_button_color'] as String?,
      welcomeLogoSize: (json['welcome_logo_size'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'app_name': appName,
    'app_short_name': appShortName,
    'logo_url': logoUrl,
    'splash_logo_url': splashLogoUrl,
    'login_logo_url': loginLogoUrl,
    'appbar_logo_url': appBarLogoUrl,
    'loading_gif_url': loadingGifUrl,
    'tagline': tagline,
    'primary_color': primaryColorHex,
    'accent_color': accentColorHex,
    'splash_bg_color': splashBgColorHex,
    'welcome_bg_color': welcomeBgColorHex,
    'welcome_bg_gradient_color': welcomeBgGradientHex,
    'welcome_button_color': welcomeButtonColorHex,
    'welcome_logo_size': welcomeLogoSize,
  };

  // Default bundled fallback — never null
  static const fallback = AppBranding(
    appName: 'He Medical Clinic',
    appShortName: 'HE',
    tagline: 'Your Health, Simplified',
    primaryColorHex: '#131C3C',
    accentColorHex: '#3B8DFF',
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
  static const _cacheDuration = Duration(minutes: 5);

  AppBranding? _cached;
  bool _initialised = false;
  Completer<void>? _initCompleter;
  final BrandingApi _api = BrandingApi();

  // ── Initialization ──

  /// Start loading branding. If already started, returns existing future.
  /// Callers can await this to ensure branding data is ready.
  Future<void> init() async {
    if (_initialised) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    // Try API first (fast 2s timeout when server is on same machine)
    try {
      final remote = await _api.fetchBranding(timeoutSeconds: 2);
      if (remote != null) {
        _cached = remote;
        await _saveToCache(remote);
        _initialised = true;
        _initCompleter!.complete();
        return;
      }
    } catch (_) {
      // API failed — will try cache
    }

    // Fall back to cache
    _cached = await _loadFromCache();
    _initialised = true;
    _initCompleter!.complete();
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
  String? get loadingGifUrl => branding.loadingGifUrl;

  /// Branding primary color (navy default) — used to theme the whole app.
  Color get primaryColor {
    final hex = branding.primaryColorHex;
    if (hex != null && hex.length == 7) {
      final c = hex.replaceFirst('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return AppColors.primary;
  }

  /// Branding accent color (blue default) — used for buttons & highlights.
  Color get accentColor {
    final hex = branding.accentColorHex;
    if (hex != null && hex.length == 7) {
      final c = hex.replaceFirst('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return AppColors.accent;
  }

  Color get splashBgColor {
    if (branding.splashBgColorHex != null) {
      final hex = branding.splashBgColorHex!.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return primaryColor;
  }

  /// Welcome screen base background color.
  Color get welcomeBgColor {
    final hex = branding.welcomeBgColorHex;
    if (hex != null && hex.length == 7) {
      final c = hex.replaceFirst('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return primaryColor;
  }

  /// Welcome screen gradient overlay color (second color in the gradient).
  Color get welcomeBgGradientColor {
    final hex = branding.welcomeBgGradientHex;
    if (hex != null && hex.length == 7) {
      final c = hex.replaceFirst('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return AppColors.primaryLight;
  }

  /// Welcome screen button color.
  Color get welcomeButtonColor {
    final hex = branding.welcomeButtonColorHex;
    if (hex != null && hex.length == 7) {
      final c = hex.replaceFirst('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return accentColor;
  }

  /// Welcome screen logo size in pixels.
  double get welcomeLogoSize => branding.welcomeLogoSize ?? 120;

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
