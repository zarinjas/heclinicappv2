import 'models/clinic_info.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class ClinicInfoService {
  ClinicInfoService._();
  static final ClinicInfoService _instance = ClinicInfoService._();
  static ClinicInfoService get instance => _instance;

  final _base = CmsServiceBase<ClinicInfo>(
    cacheKey: 'clinic_info_cache',
    cacheTimestampKey: 'clinic_info_cache_ts',
  );

  bool _initialised = false;

  List<ClinicInfo> get items => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchClinicInfos();
      _base.setData(remote);
      await _base.saveToCache(remote, (c) => c.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => ClinicInfo.fromJson(json),
      );
      _base.setData(cached);
    }

    if (!_base.hasData) {
      _base.setData(ClinicInfo.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchClinicInfos();
      _base.setData(remote);
      await _base.saveToCache(remote, (c) => c.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
