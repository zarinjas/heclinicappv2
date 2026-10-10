import 'package:shared_preferences/shared_preferences.dart';

class ModifiedSinceHelper {
  ModifiedSinceHelper._();

  static const String _prefix = 'ms_';

  /// Always returns null.
  ///
  /// These list endpoints previously sent `modified_since` to fetch only rows
  /// changed since the last request. That is a *delta*, but the UI REPLACED its
  /// full list with the delta, so a newly uploaded document/letter appeared
  /// once and then vanished on the next refresh (and older rows never came
  /// back). Returning null forces every caller to fetch the full list.
  static Future<int?> getLastFetchTimestamp(String endpointName) async {
    return null;
  }

  static Future<void> setLastFetchTimestamp(
    String endpointName,
    int timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$endpointName', timestamp);
  }

  static Future<void> clearLastFetchTimestamp(String endpointName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$endpointName');
  }

  static int now() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
