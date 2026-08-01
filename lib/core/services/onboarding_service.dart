import 'models/onboarding_slide.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class OnboardingService {
  OnboardingService._();
  static final OnboardingService _instance = OnboardingService._();
  static OnboardingService get instance => _instance;

  final _base = CmsServiceBase<OnboardingSlide>(
    cacheKey: 'onboarding_cache',
    cacheTimestampKey: 'onboarding_cache_ts',
  );

  bool _initialised = false;

  List<OnboardingSlide> get slides => _base.data;

  Future<void> init() async {
    if (_initialised) return;
    try {
      final data = await CmsApi.fetchOnboardingSlides();
      _base.setData(data);
      await _base.saveToCache(data, (s) => s.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache((json) => OnboardingSlide.fromJson(json));
      _base.setData(cached.isNotEmpty ? cached : OnboardingSlide.fallbackList);
    }
    if (!_base.hasData) _base.setData(OnboardingSlide.fallbackList);
    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final data = await CmsApi.fetchOnboardingSlides();
      _base.setData(data);
      await _base.saveToCache(data, (s) => s.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }
}
