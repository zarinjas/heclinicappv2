import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/telehealth_config.dart';
import 'cms_api.dart';

class TelehealthService {
  TelehealthService._();
  static final TelehealthService _instance = TelehealthService._();
  static TelehealthService get instance => _instance;

  TelehealthConfig _config = TelehealthConfig.fallback;
  bool _initialised = false;

  TelehealthConfig get config => _config;

  Future<void> init() async {
    if (_initialised) return;
    try {
      _config = await CmsApi.fetchTelehealthConfig();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('telehealth_cache', jsonEncode(_config.toJson()));
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('telehealth_cache');
      if (cached != null) {
        _config = TelehealthConfig.fromJson(jsonDecode(cached));
      }
    }
    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      _config = await CmsApi.fetchTelehealthConfig();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('telehealth_cache', jsonEncode(_config.toJson()));
      return true;
    } catch (_) {
      return false;
    }
  }
}
