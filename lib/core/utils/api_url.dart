import '../../env_config.dart';

bool _isLoopbackHost(String host) {
  final h = host.toLowerCase();
  return h == 'localhost' ||
      h == '127.0.0.1' ||
      h == '::1' ||
      h == '0.0.0.0';
}

String _originOf(String base) {
  final uri = Uri.tryParse(base);
  if (uri == null || uri.host.isEmpty) return '';
  final scheme = uri.scheme.isEmpty ? 'https' : uri.scheme;
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '$scheme://${uri.host}$port';
}

/// Turns a backend-provided file URL into one the device can actually open.
///
/// Backends often return relative paths (e.g. a medical-certificate path like
/// `/pdfs/mc_001.pdf`) or absolute URLs built from their own `APP_URL` (e.g.
/// `http://localhost:8080/...`), neither of which a real phone can reach. This:
///
/// - returns fully-qualified URLs on a real host unchanged;
/// - prepends the API origin to relative paths;
/// - rebases loopback hosts (`localhost`, `127.0.0.1`) onto the API origin.
String resolveBackendUrl(String url, {String? baseUrl}) {
  final base = baseUrl ?? EnvConfig.laravelBaseUrl;
  if (url.isEmpty) return url;

  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  // Signed URLs (Laravel temporarySignedRoute) must be used exactly as they
  // were generated — changing the host invalidates the signature. Leave them
  // untouched even if they point at a loopback host.
  if (uri.queryParameters.containsKey('signature')) return url;

  if (uri.hasScheme && !_isLoopbackHost(uri.host)) return url;

  final origin = _originOf(base);
  if (origin.isEmpty) return url;

  final path = uri.hasScheme
      ? (uri.path.isEmpty ? '/' : uri.path)
      : (url.startsWith('/') ? url : '/$url');
  final query = uri.hasQuery ? '?${uri.query}' : '';
  return '$origin$path$query';
}
