import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which records/documents a patient has already opened so the UI can
/// show a "New" badge until each item is viewed.
///
/// Keys are stable per item:
/// - letters: `letter:<subject>|<date>`
/// - medical certificates: `mc:<title>`
/// - documents: `doc:<id>`
class SeenStore {
  SeenStore._();

  static const _prefix = 'seen_';
  static const int _maxKeys = 1000;

  static Future<Set<String>> seenFor(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('$_prefix$category') ?? const <String>[]).toSet();
  }

  /// On first use (fresh install / after this feature ships) mark every item
  /// currently on screen as already seen so the entire existing history is not
  /// flagged "NEW". Later additions still show as new.
  static Future<Set<String>> ensureInitialized(
    String category,
    Iterable<String> currentKeys,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final initKey = '$_prefix${category}__init';

    if (!(prefs.getBool(initKey) ?? false)) {
      await markAllSeen(category, currentKeys);
      await prefs.setBool(initKey, true);
    }

    return seenFor(category);
  }

  static Future<void> markSeen(String category, String key) async {
    if (key.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList('$_prefix$category') ?? <String>[]).toSet();
    if (!seen.add(key)) return;

    var list = seen.toList();
    // Keep the stored list bounded so it cannot grow without limit.
    if (list.length > _maxKeys) {
      list = list.sublist(list.length - _maxKeys);
    }
    await prefs.setStringList('$_prefix$category', list);
  }

  static Future<void> markAllSeen(String category, Iterable<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList('$_prefix$category') ?? <String>[]).toSet();
    final before = seen.length;
    seen.addAll(keys.where((k) => k.isNotEmpty));
    if (seen.length == before) return;

    var list = seen.toList();
    if (list.length > _maxKeys) {
      list = list.sublist(list.length - _maxKeys);
    }
    await prefs.setStringList('$_prefix$category', list);
  }
}
