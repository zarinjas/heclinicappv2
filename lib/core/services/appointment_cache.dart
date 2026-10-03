import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successful appointment responses so the Home card and the
/// Visits screen can paint instantly on reopen and refresh in the background.
///
/// Data is patient-specific, but logout calls `prefs.clear()` so it is wiped
/// when the session ends.
class AppointmentCache {
  AppointmentCache._();

  static const String _apptKey = 'cache_appointments_v1';
  static const String _apptTsKey = 'cache_appointments_ts_v1';
  static const String _upcomingKey = 'cache_appointments_upcoming_v1';
  static const String _upcomingTsKey = 'cache_appointments_upcoming_ts_v1';
  static const String _codesKey = 'cache_appointment_codes_v1';
  static const String _codesTsKey = 'cache_appointment_codes_ts_v1';

  /// Full appointment list shown on the Visits screen.
  static Future<dynamic> loadAppointments() =>
      _load(_apptKey, _apptTsKey, const Duration(hours: 12));

  static Future<void> saveAppointments(dynamic jsonBody) =>
      _save(_apptKey, _apptTsKey, jsonBody);

  /// Upcoming appointment shown on the Home screen.
  static Future<dynamic> loadUpcoming() =>
      _load(_upcomingKey, _upcomingTsKey, const Duration(hours: 12));

  static Future<void> saveUpcoming(dynamic jsonBody) =>
      _save(_upcomingKey, _upcomingTsKey, jsonBody);

  /// Doctor / branch codes. These change rarely, so they are cached for longer.
  static Future<dynamic> loadCodes() =>
      _load(_codesKey, _codesTsKey, const Duration(days: 7));

  static Future<void> saveCodes(dynamic jsonBody) =>
      _save(_codesKey, _codesTsKey, jsonBody);

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apptKey);
      await prefs.remove(_apptTsKey);
      await prefs.remove(_upcomingKey);
      await prefs.remove(_upcomingTsKey);
      await prefs.remove(_codesKey);
      await prefs.remove(_codesTsKey);
    } catch (_) {}
  }

  static Future<dynamic> _load(
    String key,
    String timestampKey,
    Duration maxAge,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;

      final timestamp = prefs.getInt(timestampKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > maxAge.inMilliseconds) return null;

      return json.decode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _save(
    String key,
    String timestampKey,
    dynamic jsonBody,
  ) async {
    if (jsonBody == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(jsonBody));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }
}
