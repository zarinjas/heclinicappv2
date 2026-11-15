import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/api_url.dart';
import '../../env_config.dart';
import 'document_viewer_screen.dart';

/// Renders a clinical letter's HTML in-app at full fidelity (bold, tables,
/// images, links) instead of stripping it to plain text.
///
/// - Images are downloaded with the patient's bearer token and inlined as data
///   URIs, because Plato-hosted images sit behind authentication that a bare
///   WebView subresource request cannot carry.
/// - Taps on PDF/image links open the same in-app viewer used by documents.
/// - The HTML is sanitised (script/iframe/object removed) as a defence against
///   injected content, and clinical notes are never rendered through here.
class LetterHtmlView extends StatefulWidget {
  final String html;
  final String? authToken;

  const LetterHtmlView({super.key, required this.html, this.authToken});

  @override
  State<LetterHtmlView> createState() => _LetterHtmlViewState();
}

class _LetterHtmlViewState extends State<LetterHtmlView> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onPageFinished: (_) {
          if (mounted) {
            setState(() {
              _loading = false;
              _loaded = true;
            });
          }
        },
        onWebResourceError: (_) {},
      ));
    _prepareAndLoad();
  }

  Future<void> _prepareAndLoad() async {
    try {
      final sanitized = _sanitize(widget.html);
      final withImages = await _inlineImages(
        sanitized,
        EnvConfig.platomBaseUrl,
        widget.authToken,
      );
      await _controller.loadHtmlString(
        withImages,
        baseUrl: EnvConfig.platomBaseUrl,
      );
    } catch (_) {
      // Fall back to the original HTML so the letter still shows if image
      // inlining fails.
      try {
        await _controller.loadHtmlString(
          _sanitize(widget.html),
          baseUrl: EnvConfig.platomBaseUrl,
        );
      } catch (e) {
        if (mounted) setState(() => _error = e.toString());
      }
    }
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    final url = request.url;
    final uri = Uri.tryParse(url);
    if (uri == null) return NavigationDecision.prevent;

    // Initial HTML load, in-page anchors and data URIs stay inside the view.
    if (url.startsWith('about:blank') || uri.scheme == 'data' || uri.scheme.isEmpty) {
      return NavigationDecision.navigate;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return NavigationDecision.prevent;
    }

    // Until the letter itself has finished loading, allow the document to
    // settle. After that, any http(s) navigation is a user tap on a link.
    if (!_loaded) return NavigationDecision.navigate;

    // File links (PDF / image) open in the authenticated in-app viewer.
    if (_isFileLink(url)) {
      if (mounted) _openFile(url);
      return NavigationDecision.prevent;
    }

    // Everything else (e.g. an external reference) opens in the browser.
    if (mounted) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    return NavigationDecision.prevent;
  }

  void _openFile(String url) {
    final resolved = resolveBackendUrl(url, baseUrl: EnvConfig.platomBaseUrl);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          name: _fileNameFromUrl(url),
          url: resolved,
          authToken: widget.authToken,
        ),
      ),
    );
  }

  static String _fileNameFromUrl(String url) {
    final withoutQuery = url.split('?').first;
    final name = withoutQuery.split('/').last;
    return name.isEmpty ? 'Attachment' : name;
  }

  static bool _isFileLink(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return path.contains('.pdf') ||
        path.contains('.png') ||
        path.contains('.jpg') ||
        path.contains('.jpeg') ||
        path.contains('.gif') ||
        path.contains('.webp');
  }

  Future<String> _inlineImages(String html, String baseUrl, String? token) async {
    final imgTag = RegExp(r'<img\b([^>]*)>', caseSensitive: false);
    final srcAttr = RegExp(
      r'''src\s*=\s*("([^"]*)"|'([^']*)')''',
      caseSensitive: false,
    );

    final matches = imgTag.allMatches(html).toList();
    final replacements = <String, String>{};

    await Future.wait(matches.map((m) async {
      final tag = m.group(1) ?? '';
      final srcMatch = srcAttr.firstMatch(tag);
      if (srcMatch == null) return;
      final raw = srcMatch.group(2) ?? srcMatch.group(3) ?? '';
      if (raw.isEmpty || raw.startsWith('data:')) return;
      final dataUri = await _fetchAsDataUri(
        resolveBackendUrl(raw, baseUrl: baseUrl),
        token,
      );
      if (dataUri == null) return;
      replacements[srcMatch.group(0)!] = 'src="$dataUri"';
    }));

    if (replacements.isEmpty) return html;

    return html.replaceAllMapped(imgTag, (m) {
      final tag = m.group(1) ?? '';
      var updated = tag;
      replacements.forEach((from, to) {
        if (updated.contains(from)) updated = updated.replaceFirst(from, to);
      });
      return '<img$updated>';
    });
  }

  Future<String?> _fetchAsDataUri(String url, String? token) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final headers = (token != null && token.trim().isNotEmpty)
        ? <String, String>{'Authorization': 'Bearer ${token.trim()}'}
        : <String, String>{};
    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final mime = (response.headers['content-type'] ?? _mimeFromUrl(url))
          .split(';')
          .first
          .trim();
      return 'data:$mime;base64,${base64Encode(response.bodyBytes)}';
    } catch (_) {
      return null;
    }
  }

  static String _mimeFromUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  static String _sanitize(String html) {
    var out = html;
    out = out.replaceAll(
      RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
      '',
    );
    out = out.replaceAll(
      RegExp(r'<iframe\b[^>]*>[\s\S]*?</iframe>', caseSensitive: false),
      '',
    );
    out = out.replaceAll(
      RegExp(r'<object\b[^>]*>[\s\S]*?</object>', caseSensitive: false),
      '',
    );
    out = out.replaceAll(RegExp(r'<embed\b[^>]*>', caseSensitive: false), '');
    out = out.replaceAll(
      RegExp(r'''\son\w+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)'''),
      '',
    );
    out = out.replaceAll(RegExp(r'javascript\s*:', caseSensitive: false), '');
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}
