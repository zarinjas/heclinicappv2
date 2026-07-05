import 'package:shared_preferences/shared_preferences.dart';

class ModifiedSinceHelper {
  ModifiedSinceHelper._();

  static const String _prefix = 'ms_';

  static Future<int?> getLastFetchTimestamp(String endpointName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$endpointName');
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
