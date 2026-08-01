import 'models/promotion.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class PromotionService {
  PromotionService._();
  static final PromotionService _instance = PromotionService._();
  static PromotionService get instance => _instance;

  final _base = CmsServiceBase<Promotion>(
    cacheKey: 'promotions_cache',
    cacheTimestampKey: 'promotions_cache_ts',
  );

  bool _initialised = false;

  List<Promotion> get promotions => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchPromotions();
      _base.setData(remote);
      await _base.saveToCache(remote, (p) => p.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => Promotion.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : Promotion.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(Promotion.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchPromotions();
      _base.setData(remote);
      await _base.saveToCache(remote, (p) => p.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
