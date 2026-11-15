import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Remembers the last store version the user chose to skip, so the soft
  /// prompt never nags for the same release.
  static const _dismissedKey = 'app_update_dismissed_version';

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

      // Never nag for a release the user already chose to skip.
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_dismissedKey) == status.storeVersion) return;

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
      } else if (wantsUpdate == false) {
        // Soft prompt: remember the skip and keep the user on their version.
        await prefs.setString(_dismissedKey, status.storeVersion);
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
    final storeVersion = _cleanVersion(result['version'] as String? ?? '');

    // Defensive: ignore implausible versions so a bad/partial lookup can never
    // produce a bogus "update available" prompt.
    if (!_isPlausibleStoreVersion(storeVersion, localVersion)) return null;

    return AppUpdateStatus(
      localVersion: _cleanVersion(localVersion),
      storeVersion: storeVersion,
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

    final storeVersion = _cleanVersion(match);

    // The Play page is scraped, so the regex can occasionally capture an
    // unrelated number (e.g. a rating like "4.5"). Reject implausible jumps so
    // users on the latest build never see a bogus "update available" prompt.
    if (!_isPlausibleStoreVersion(storeVersion, localVersion)) return null;

    return AppUpdateStatus(
      localVersion: _cleanVersion(localVersion),
      storeVersion: storeVersion,
      storeUrl:
          'https://play.google.com/store/apps/details?id=$_androidPackageId',
    );
  }

  /// Guards against scraped numbers that are not a real app version by
  /// rejecting versions implausibly far ahead of the installed one (allows the
  /// next major release, rejects wildly different majors).
  static bool _isPlausibleStoreVersion(String store, String local) {
    final s = _parts(store);
    final l = _parts(local);
    return s[0] <= l[0] + 1;
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
