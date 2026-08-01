import 'models/hero_banner.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class HeroService {
  HeroService._();
  static final HeroService _instance = HeroService._();
  static HeroService get instance => _instance;

  final _base = CmsServiceBase<HeroBanner>(
    cacheKey: 'hero_sliders_cache',
    cacheTimestampKey: 'hero_sliders_cache_ts',
  );

  bool _initialised = false;

  List<HeroBanner> get banners => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchSliders();
      _base.setData(remote);
      await _base.saveToCache(remote, (b) => b.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => HeroBanner.fromJson(json),
      );
      _base.setData(cached.isNotEmpty ? cached : HeroBanner.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(HeroBanner.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchSliders();
      _base.setData(remote);
      await _base.saveToCache(remote, (b) => b.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
