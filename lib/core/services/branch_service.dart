import 'models/branch.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class BranchService {
  BranchService._();
  static final BranchService _instance = BranchService._();
  static BranchService get instance => _instance;

  final _base = CmsServiceBase<Branch>(
    cacheKey: 'branches_cache',
    cacheTimestampKey: 'branches_cache_ts',
  );

  bool _initialised = false;

  List<Branch> get branches => _base.data;

  Future<void> init() async {
    if (_initialised) return;

    try {
      final remote = await CmsApi.fetchBranches();
      _base.setData(remote);
      await _base.saveToCache(remote, (b) => b.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => Branch.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : Branch.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(Branch.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final remote = await CmsApi.fetchBranches();
      _base.setData(remote);
      await _base.saveToCache(remote, (b) => b.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
