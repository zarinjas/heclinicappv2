import 'models/doctor.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class DoctorService {
  DoctorService._();
  static final DoctorService _instance = DoctorService._();
  static DoctorService get instance => _instance;

  final _base = CmsServiceBase<Doctor>(
    cacheKey: 'doctors_cache',
    cacheTimestampKey: 'doctors_cache_ts',
  );

  bool _initialised = false;

  List<Doctor> get doctors => _base.data;

  List<Doctor> doctorsForBranch(int branchId) {
    return _base.data.where((d) => d.branchId == branchId).toList();
  }

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchDoctors();
      _base.setData(remote);
      await _base.saveToCache(remote, (d) => d.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => Doctor.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : Doctor.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(Doctor.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchDoctors();
      _base.setData(remote);
      await _base.saveToCache(remote, (d) => d.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
