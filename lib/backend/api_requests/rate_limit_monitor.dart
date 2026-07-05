import 'dart:async';

class RateLimitMonitor {
  RateLimitMonitor._();

  static final RateLimitMonitor _instance = RateLimitMonitor._();
  static RateLimitMonitor get instance => _instance;

  int _remainingCalls = -1;
  int _rateLimitLimit = -1;
  bool _isPaused = false;
  DateTime? _pauseStartedAt;

  static const int _pauseThreshold = 5;
  static const Duration _pauseDuration = Duration(seconds: 60);

  bool get isPaused => _isPaused;
  int get remainingCalls => _remainingCalls;
  int get rateLimitLimit => _rateLimitLimit;

  bool _isSingleRecordEndpoint(String url) {
    return url.contains('/patient/') || url.contains('/search/');
  }

  void updateFromHeaders(Map<String, String> headers) {
    final remaining = headers['x-ratelimit-remaining'];
    final limit = headers['x-ratelimit-limit'];

    if (remaining != null) {
      _remainingCalls =
          int.tryParse(remaining.toLowerCase()) ?? _remainingCalls;
    }
    if (limit != null) {
      _rateLimitLimit = int.tryParse(limit.toLowerCase()) ?? _rateLimitLimit;
    }

    if (_remainingCalls >= 0 && _remainingCalls <= _pauseThreshold) {
      if (!_isPaused) {
        _isPaused = true;
        _pauseStartedAt = DateTime.now();
      }
    } else if (_remainingCalls > _pauseThreshold || _remainingCalls == -1) {
      _isPaused = false;
    }
  }

  Future<void> waitIfPaused(String url) async {
    if (!_isPaused) return;
    if (_isSingleRecordEndpoint(url)) return;

    while (_isPaused) {
      final elapsed = _pauseStartedAt != null
          ? DateTime.now().difference(_pauseStartedAt!)
          : Duration.zero;
      if (elapsed >= _pauseDuration) {
        _isPaused = false;
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void reset() {
    _remainingCalls = -1;
    _rateLimitLimit = -1;
    _isPaused = false;
    _pauseStartedAt = null;
  }
}
