import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'health_record.dart';

/// Local on-disk cache for the Health tab so records and documents stay
/// visible even when the Plato API is unreachable or rate-limited.
///
/// Each patient has its own file, keyed by `idplato`, so relinking an account
/// to a different Plato record never shows another patient's data.
class HealthCache {
  HealthCache._();

  static Future<Directory> _dir() => getApplicationDocumentsDirectory();

  static String _safeId(String patientId) =>
      patientId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  static Future<File> _recordsFile(String patientId) async {
    final dir = await _dir();
    return File('${dir.path}/health_records_${_safeId(patientId)}.json');
  }

  static Future<File> _documentsFile(String patientId) async {
    final dir = await _dir();
    return File('${dir.path}/health_documents_${_safeId(patientId)}.json');
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
        name.startsWith('health_documents_');
  }
}
