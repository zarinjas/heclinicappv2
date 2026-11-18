import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../app_state.dart';

/// Offline cache for patient documents. Files are kept inside the app-private
/// directory and are never exposed through a public URL.
class DocumentCacheService {
  DocumentCacheService._();

  static final instance = DocumentCacheService._();

  Future<Directory> _directory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/patient_documents');
    if (!directory.existsSync()) await directory.create(recursive: true);
    return directory;
  }

  Future<File?> cachedFile(int id) async {
    final directory = await _directory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.startsWith('${directory.path}/$id.'));
    return files.isEmpty ? null : files.first;
  }

  Future<File?> download(int id, String url) async {
    if (id <= 0 || url.isEmpty) return null;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${FFAppState().tokenauth}',
    });
    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final type = response.headers['content-type'] ?? 'application/pdf';
    final extension = type.contains('image/')
        ? (type.split('/').last == 'jpeg' ? 'jpg' : type.split('/').last)
        : 'pdf';
    final directory = await _directory();
    final old = await cachedFile(id);
    if (old != null) await old.delete();
    final file = File('${directory.path}/$id.$extension');
    await file.writeAsBytes(Uint8List.fromList(response.bodyBytes),
        flush: true);
    return file;
  }

  Future<void> clear() async {
    final directory = await _directory();
    if (directory.existsSync()) await directory.delete(recursive: true);
  }
}
