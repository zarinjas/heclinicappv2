import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/legal_page.dart';
import 'cms_api.dart';

class LegalService {
  LegalService._();
  static final LegalService _instance = LegalService._();
  static LegalService get instance => _instance;

  LegalPage _privacy = LegalPage.privacyFallback;
  LegalPage _terms = LegalPage.termsFallback;
  bool _initialised = false;

  LegalPage get privacy => _privacy;
  LegalPage get terms => _terms;

  Future<void> init() async {
    if (_initialised) return;
    await Future.wait([_loadPrivacy(), _loadTerms()]);
    _initialised = true;
  }

  Future<void> _loadPrivacy() async {
    try {
      _privacy = await CmsApi.fetchLegalPage('privacy');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('legal_privacy_cache', jsonEncode(_privacy.toJson()));
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('legal_privacy_cache');
      if (cached != null) _privacy = LegalPage.fromJson(jsonDecode(cached));
    }
  }

  Future<void> _loadTerms() async {
    try {
      _terms = await CmsApi.fetchLegalPage('terms');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('legal_terms_cache', jsonEncode(_terms.toJson()));
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('legal_terms_cache');
      if (cached != null) _terms = LegalPage.fromJson(jsonDecode(cached));
    }
  }

  Future<bool> refresh() async {
    try {
      await _loadPrivacy();
      await _loadTerms();
      return true;
    } catch (_) {
      return false;
    }
  }
}
