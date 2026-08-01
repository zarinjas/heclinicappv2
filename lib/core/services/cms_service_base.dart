import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CmsServiceBase<T> {
  final String cacheKey;
  final String cacheTimestampKey;
  final Duration cacheDuration;

  List<T>? _cached;

  CmsServiceBase({
    required this.cacheKey,
    required this.cacheTimestampKey,
    this.cacheDuration = const Duration(hours: 24),
  });

  List<T> get data => _cached ?? [];

  bool get hasData => _cached != null && _cached!.isNotEmpty;

  void setData(List<T> items) {
    _cached = items;
  }

  Future<List<T>> loadFromCache(
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(cacheTimestampKey) ?? 0;

      if (raw == null) return [];

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > cacheDuration.inMilliseconds) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveToCache(
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((e) => toJson(e)).toList();
      await prefs.setString(cacheKey, jsonEncode(list));
      await prefs.setInt(
        cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      await prefs.remove(cacheTimestampKey);
      _cached = null;
    } catch (_) {}
  }
}
