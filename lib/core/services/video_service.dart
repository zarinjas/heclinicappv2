import 'models/video.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class VideoService {
  VideoService._();
  static final VideoService _instance = VideoService._();
  static VideoService get instance => _instance;

  final _base = CmsServiceBase<Video>(
    cacheKey: 'videos_cache',
    cacheTimestampKey: 'videos_cache_ts',
  );

  bool _initialised = false;

  List<Video> get videos => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final response = await CmsApi.fetchVideos();
      _base.setData(response.data);
      await _base.saveToCache(response.data, (v) => v.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => Video.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : Video.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(Video.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final response = await CmsApi.fetchVideos();
      _base.setData(response.data);
      await _base.saveToCache(response.data, (v) => v.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
