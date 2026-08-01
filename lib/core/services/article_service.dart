import 'models/article.dart';
import 'cms_api.dart';
import 'cms_service_base.dart';

class ArticleService {
  ArticleService._();
  static final ArticleService _instance = ArticleService._();
  static ArticleService get instance => _instance;

  final _base = CmsServiceBase<Article>(
    cacheKey: 'articles_cache',
    cacheTimestampKey: 'articles_cache_ts',
  );

  bool _initialised = false;

  List<Article> get articles => _base.data;

  Article? articleBySlug(String slug) {
    for (final a in _base.data) {
      if (a.slug == slug) return a;
    }
    return Article.fallbackBySlug(slug);
  }

  List<Article> get healthTips => _base.data
      .where((a) =>
          a.category != null &&
          a.category!.toLowerCase().contains('health'))
      .toList();

  Future<void> init() async {
    if (_initialised) return;

    try {
      final response = await CmsApi.fetchArticles();
      _base.setData(response.data);
      await _base.saveToCache(response.data, (a) => a.toJson());
    } catch (_) {
      final cached = await _base.loadFromCache(
        (json) => Article.fromJson(json),
      );
      _base.setData(
          cached.isNotEmpty ? cached : Article.fallbackList);
    }

    if (!_base.hasData) {
      _base.setData(Article.fallbackList);
    }

    _initialised = true;
  }

  Future<bool> refresh() async {
    try {
      final response = await CmsApi.fetchArticles();
      _base.setData(response.data);
      await _base.saveToCache(response.data, (a) => a.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() => _base.clearCache();
}
