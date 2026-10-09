import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flutter_flow/nav/nav.dart' show appNavigatorKey;
import '../widgets/app_dialog.dart';

/// Version comparison result between the installed app and the store listing.
class AppUpdateStatus {
  final String localVersion;
  final String storeVersion;
  final String storeUrl;
  final String? releaseNotes;

  const AppUpdateStatus({
    required this.localVersion,
    required this.storeVersion,
    required this.storeUrl,
    this.releaseNotes,
  });

  bool get canUpdate => AppUpdateService._isNewer(storeVersion, localVersion);
}

/// Checks the App Store / Play Store for a newer version and, when one exists,
/// shows a dismissible "Update available" prompt. This is a soft prompt: the
/// user can continue on the old version.
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService _instance = AppUpdateService._();
  static AppUpdateService get instance => _instance;

  // The bundle id differs from the Android applicationId, and neither matches
  // package_info_plus's packageName on iOS, so both are pinned explicitly.
  static const _iosBundleId = 'com.hemedgroup.heclinicapps';
  static const _androidPackageId = 'com.heclinicapp';
  static const _iosCountry = 'my';
  static const _androidLocale = 'en_US';

  bool _prompted = false;

  /// Fetches the store version. Returns null when the platform is unsupported,
  /// the network fails, or the listing cannot be found (e.g. Android not yet
  /// published) — callers treat null as "no update".
  Future<AppUpdateStatus?> check() async {
    if (kIsWeb) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      if (Platform.isIOS) return _checkIos(info.version);
      if (Platform.isAndroid) return _checkAndroid(info.version);
    } catch (e) {
      debugPrint('AppUpdateService.check failed: $e');
    }
    return null;
  }

  /// Runs once per app launch: checks the store and shows the prompt only when
  /// a newer version exists. Never throws.
  Future<void> checkAndPrompt() async {
    if (_prompted) return;
    _prompted = true;

    try {
      final status = await check();
      if (status == null || !status.canUpdate) return;

      // Let the first screen settle before interrupting with the prompt.
      await Future.delayed(const Duration(seconds: 2));

      final context = appNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      final wantsUpdate = await AppDialog.update(
        context,
        localVersion: status.localVersion,
        storeVersion: status.storeVersion,
      );

      if (wantsUpdate == true && status.storeUrl.isNotEmpty) {
        final uri = Uri.parse(status.storeUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('AppUpdateService.checkAndPrompt failed: $e');
    }
  }

  Future<AppUpdateStatus?> _checkIos(String localVersion) async {
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'bundleId': _iosBundleId,
      'country': _iosCountry,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List?;
    if (results == null || results.isEmpty) return null;

    final result = results.first as Map<String, dynamic>;
    return AppUpdateStatus(
      localVersion: _cleanVersion(localVersion),
      storeVersion: _cleanVersion(result['version'] as String? ?? ''),
      storeUrl: result['trackViewUrl'] as String? ?? '',
      releaseNotes: result['releaseNotes'] as String?,
    );
  }

  Future<AppUpdateStatus?> _checkAndroid(String localVersion) async {
    final uri = Uri.https('play.google.com', '/store/apps/details', {
      'id': _androidPackageId,
      'hl': _androidLocale,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final match = RegExp(r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]')
        .firstMatch(response.body)
        ?.group(1);
    if (match == null) return null;

    return AppUpdateStatus(
      localVersion: _cleanVersion(localVersion),
      storeVersion: _cleanVersion(match),
      storeUrl:
          'https://play.google.com/store/apps/details?id=$_androidPackageId',
    );
  }

  static String _cleanVersion(String version) =>
      RegExp(r'\d+(\.\d+)?(\.\d+)?').stringMatch(version) ?? '0.0.0';

  static bool _isNewer(String store, String local) {
    final s = _parts(store);
    final l = _parts(local);
    for (var i = 0; i < 3; i++) {
      if (s[i] > l[i]) return true;
      if (s[i] < l[i]) return false;
    }
    return false;
  }

  static List<int> _parts(String version) {
    final split = version.split('.');
    return [
      for (var i = 0; i < 3; i++)
        int.tryParse(i < split.length ? split[i] : '0') ?? 0,
    ];
  }
}
