import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cms_api.dart';

/// Caches onboarding background media (videos / GIFs) on the device so they
/// play instantly on subsequent app launches instead of being re-downloaded
/// from the network every time.
///
/// Flow:
///  - On splash we [prefetch] the media while the branding loads, so by the
///    time the user reaches the onboarding screen the files are already local.
///  - [_SlideMedia] asks [getIfCached] first and plays straight from the local
///    file (no network round-trip). If it isn't cached yet it streams from the
///    network and [download]s in the background for next time.
class OnboardingMediaCache {
  OnboardingMediaCache._();
  static final OnboardingMediaCache instance = OnboardingMediaCache._();

  static final CacheManager _cache = CacheManager(
    Config(
      'onboarding_media',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 30,
    ),
  );

  /// The locally cached file for [rawUrl], or null if it hasn't been cached.
  Future<FileInfo?> getIfCached(String rawUrl) async {
    final url = CmsApi.resolveMediaUrl(rawUrl);
    if (url.isEmpty) return null;
    try {
      return await _cache.getFileFromCache(url);
    } catch (_) {
      return null;
    }
  }

  /// Downloads and caches [rawUrl] (safe to call fire-and-forget).
  Future<void> download(String rawUrl) async {
    final url = CmsApi.resolveMediaUrl(rawUrl);
    if (url.isEmpty) return;
    try {
      await _cache.downloadFile(url);
    } catch (_) {
      // Ignore — playback falls back to network streaming.
    }
  }

  /// Warm the cache for a batch of media URLs. Files already cached are skipped.
  Future<void> prefetch(Iterable<String?> urls) async {
    final seen = <String>{};
    for (final raw in urls) {
      if (raw == null || raw.isEmpty) continue;
      final url = CmsApi.resolveMediaUrl(raw);
      if (url.isEmpty || !seen.add(url)) continue;
      try {
        final cached = await _cache.getFileFromCache(url);
        if (cached == null) {
          await _cache.downloadFile(url);
        }
      } catch (_) {
        // Ignore prefetch failures.
      }
    }
  }
}
