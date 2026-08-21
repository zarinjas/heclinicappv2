import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/app_info.dart';
import 'cms_api.dart';

/// Loads the admin-managed contact & about information shown on the About
/// screen. Falls back to bundled defaults when the API is unreachable.
class AppInfoService {
  AppInfoService._();
  static final AppInfoService _instance = AppInfoService._();
  static AppInfoService get instance => _instance;

  static const _cacheKey = 'app_info_cache';
  static const _cacheTimestampKey = 'app_info_cache_ts';
  static const _cacheDuration = Duration(hours: 24);

  AppInfo _info = AppInfo.fallback;
  bool _initialised = false;

  AppInfo get info => _info;

  Future<void> init() async {
    if (_initialised) return;

    try {
      _info = await CmsApi.fetchAppInfo();
      await _saveToCache(_info);
    } catch (_) {
      _info = await _loadFromCache() ?? AppInfo.fallback;
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      _info = await CmsApi.fetchAppInfo();
      await _saveToCache(_info);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AppInfo?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;

      if (raw == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > _cacheDuration.inMilliseconds) return null;

      return AppInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(AppInfo info) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(info.toJson()));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      _info = AppInfo.fallback;
    } catch (_) {}
  }
}
