import 'models/service_package.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class PackageService {
  PackageService._();
  static final PackageService _instance = PackageService._();
  static PackageService get instance => _instance;

  final _base = CmsServiceBase<ServicePackage>(
    cacheKey: 'packages_cache',
    cacheTimestampKey: 'packages_cache_ts',
  );

  bool _initialised = false;

  List<ServicePackage> get packages => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchServicePackages();
      _base.setData(remote);
      await _base.saveToCache(remote, (p) => p.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => ServicePackage.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : ServicePackage.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(ServicePackage.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchServicePackages();
      _base.setData(remote);
      await _base.saveToCache(remote, (p) => p.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
