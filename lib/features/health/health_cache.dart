import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'health_record.dart';

/// Local on-disk cache for the Health tab so records and documents stay
/// visible even when the Plato API is unreachable or rate-limited.
///
/// Each patient has its own file, keyed by `idplato`, so relinking an account
/// to a different Plato record never shows another patient's data.
class HealthCache {
  HealthCache._();

  static const Duration freshness = Duration(minutes: 30);
  static const int _maxCachedFileBytes = 25 * 1024 * 1024;

  static Future<Directory> _dir() => getApplicationSupportDirectory();

  static String _safeId(String patientId) =>
      patientId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  static Future<File> _recordsFile(String patientId) async {
    final dir = await _dir();
    // Version 2 excludes generic letters and private note data from the cache.
    return File('${dir.path}/health_records_v3_${_safeId(patientId)}.json');
  }

  static Future<File> _documentsFile(String patientId) async {
    final dir = await _dir();
    return File('${dir.path}/health_documents_${_safeId(patientId)}.json');
  }

  static Future<File> _invalidatedFile(String kind, String patientId) async {
    final dir = await _dir();
    return File('${dir.path}/health_${kind}_invalidated_${_safeId(patientId)}');
  }

  static Future<bool> recordsAreFresh(String patientId) =>
      _isFresh(_recordsFile(patientId), _invalidatedFile('records', patientId));

  static Future<bool> documentsAreFresh(String patientId) => _isFresh(
      _documentsFile(patientId), _invalidatedFile('documents', patientId));

  static Future<DateTime?> recordsLastSynced(String patientId) =>
      _lastModified(_recordsFile(patientId));

  static Future<DateTime?> documentsLastSynced(String patientId) =>
      _lastModified(_documentsFile(patientId));

  static Future<DateTime?> _lastModified(Future<File> cacheFile) async {
    try {
      final file = await cacheFile;
      if (!await file.exists()) return null;
      return (await file.stat()).modified;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _isFresh(
    Future<File> cacheFile,
    Future<File> invalidatedFile,
  ) async {
    try {
      final file = await cacheFile;
      if (!await file.exists()) return false;
      final cacheStat = await file.stat();
      if (DateTime.now().difference(cacheStat.modified) > freshness)
        return false;

      final invalidated = await invalidatedFile;
      if (!await invalidated.exists()) return true;
      return (await invalidated.stat()).modified.isBefore(cacheStat.modified);
    } catch (_) {
      return false;
    }
  }

  static Future<void> invalidate(String patientId) async {
    if (patientId.isEmpty) return;
    try {
      final file = await _invalidatedFile('records', patientId);
      await file.writeAsString(DateTime.now().toIso8601String(), flush: true);
      final documents = await _invalidatedFile('documents', patientId);
      await documents.writeAsString(DateTime.now().toIso8601String(),
          flush: true);
    } catch (_) {}
  }

  static Future<List<HealthRecord>?> readRecords(String patientId) async {
    if (patientId.isEmpty) return null;
    try {
      final file = await _recordsFile(patientId);
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return null;
      final records = decoded
          .whereType<Map>()
          .map((m) => HealthRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      return records.isEmpty ? null : records;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeRecords(
    String patientId,
    List<HealthRecord> records,
  ) async {
    if (patientId.isEmpty) return;
    try {
      final file = await _recordsFile(patientId);
      await file.writeAsString(
        jsonEncode(records.map((r) => r.toJson()).toList()),
        flush: true,
      );
      await _clearInvalidation('records', patientId);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>?> readDocuments(
    String patientId,
  ) async {
    if (patientId.isEmpty) return null;
    try {
      final file = await _documentsFile(patientId);
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return null;
      final docs = decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      return docs.isEmpty ? null : docs;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeDocuments(
    String patientId,
    List<Map<String, dynamic>> documents,
  ) async {
    if (patientId.isEmpty) return;
    try {
      final file = await _documentsFile(patientId);
      await file.writeAsString(jsonEncode(documents), flush: true);
      await _clearInvalidation('documents', patientId);
    } catch (_) {}
  }

  static Future<void> _clearInvalidation(String kind, String patientId) async {
    try {
      final file = await _invalidatedFile(kind, patientId);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static String _fileKey(String url) {
    final uri = Uri.tryParse(url);
    final stable =
        uri == null ? url : uri.replace(query: '', fragment: '').toString();
    return sha256.convert(utf8.encode(stable)).toString();
  }

  static Future<File> _cachedFile(String url) async {
    final dir = await _dir();
    return File('${dir.path}/health_file_${_fileKey(url)}.bin');
  }

  static Future<Uint8List?> readFile(String url) async {
    if (url.isEmpty) return null;
    try {
      final file = await _cachedFile(url);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeFile(String url, Uint8List bytes) async {
    if (url.isEmpty || bytes.length > _maxCachedFileBytes) return;
    try {
      final file = await _cachedFile(url);
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {}
  }

  /// Removes every cached Health-tab file for every patient.
  static Future<void> clear() async {
    try {
      final dir = await _dir();
      final entries = dir
          .listSync()
          .whereType<File>()
          .where((f) => _isHealthCacheFile(f.path));
      for (final file in entries) {
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  static bool _isHealthCacheFile(String path) {
    final name = path.split('/').last;
    return name.startsWith('health_records_') ||
        name.startsWith('health_documents_') ||
        name.startsWith('health_records_invalidated_') ||
        name.startsWith('health_documents_invalidated_') ||
        name.startsWith('health_file_');
  }
}
