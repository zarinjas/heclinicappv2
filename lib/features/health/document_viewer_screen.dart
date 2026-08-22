import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';

enum _DocKind { image, pdf, other }

/// In-app viewer for a patient document (PDF or image) with a download action.
///
/// The file bytes are downloaded first through the signed, time-limited URL so
/// we can verify it is a real PDF/image (and surface a clear error otherwise,
/// instead of a blank screen). PDFs are then previewed in a [WebView]:
/// - iOS' WKWebView renders PDFs natively from the already-downloaded bytes;
/// - Android's WebView cannot, so it falls back to Google Docs' embedded
///   viewer.
///
/// "Download" saves the file through the system share sheet (Save to Files /
/// Drive etc.) and "Open in Browser" opens the signed URL externally.
class DocumentViewerScreen extends StatefulWidget {
  final String name;
  final String url;
  final String mimeType;

  const DocumentViewerScreen({
    super.key,
    required this.name,
    required this.url,
    this.mimeType = '',
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _loading = true;
  bool _downloading = false;
  String? _error;
  Uint8List? _bytes;
  _DocKind _kind = _DocKind.other;
  WebViewController? _webController;
  File? _tempPdfFile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _webController = null;
    final temp = _tempPdfFile;
    if (temp != null) {
      try {
        temp.delete();
      } catch (_) {}
    }
    super.dispose();
  }

  /// URL the WebView loads for a PDF. iOS renders PDFs natively from the local
  /// file; Android routes through Google's embedded viewer (the signed URL is
  /// time-limited and public, matching what the external browser would already
  /// receive).
  String get _webUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://docs.google.com/viewer?url='
          '${Uri.encodeComponent(widget.url)}&embedded=true';
    }
    return widget.url;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      _fail('This document link is invalid.');
      return;
    }

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        _fail(
          'Could not load this document (HTTP ${response.statusCode}). '
          'The link may have expired — pull to refresh the list and try again.',
        );
        return;
      }

      final bytes = response.bodyBytes;
      if (!mounted) return;

      final kind = await _detectKind(bytes);
      if (!mounted) return;

      if (kind == _DocKind.image) {
        setState(() {
          _bytes = bytes;
          _kind = kind;
          _loading = false;
        });
        return;
      }

      if (kind == _DocKind.pdf) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (details) {
                if (mounted) {
                  _fail(
                    'Could not preview this document. '
                    'Use "Open in Browser" or "Download" instead.',
                  );
                }
              },
            ),
          );

        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          // WKWebView renders PDFs natively. Loading the downloaded bytes from
          // a local file is more reliable than re-fetching the signed URL
          // (no expiry, redirect or CORS concerns inside the WebView).
          final dir = await getTemporaryDirectory();
          final file = File(
            '${dir.path}/doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          await file.writeAsBytes(bytes, flush: true);
          if (!mounted) {
            try {
              file.delete();
            } catch (_) {}
            return;
          }
          _tempPdfFile = file;
          await controller.loadFile(file.path);
        } else {
          await controller.loadRequest(Uri.parse(_webUrl));
        }

        if (!mounted) return;
        setState(() {
          _bytes = bytes;
          _kind = kind;
          _webController = controller;
          _loading = false;
        });
        return;
      }

      setState(() {
        _error = 'This file type is not supported for in-app preview. '
            'Use "Open in Browser" or "Download" to view it in another app.';
        _loading = false;
      });
    } catch (_) {
      _fail(
        'Could not open this document. It may be damaged or the link may have '
        'expired — pull to refresh the list and try again.',
      );
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  Future<_DocKind> _detectKind(Uint8List bytes) async {
    if (_isPdfMagic(bytes)) return _DocKind.pdf;

    final mime = widget.mimeType.toLowerCase();
    if (mime.startsWith('image/')) return _DocKind.image;

    // Unknown/blank mime type: sniff the bytes — treat decodable data as an
    // image, otherwise fall through to the unsupported state.
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      codec.dispose();
      return _DocKind.image;
    } catch (_) {
      return _DocKind.other;
    }
  }

  static bool _isPdfMagic(Uint8List bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46; // %PDF

  String get _fileExtension {
    switch (_kind) {
      case _DocKind.pdf:
        return 'pdf';
      case _DocKind.image:
        final m = widget.mimeType.toLowerCase();
        if (m.contains('png')) return 'png';
        if (m.contains('webp')) return 'webp';
        if (m.contains('gif')) return 'gif';
        return 'jpg';
      case _DocKind.other:
        return 'bin';
    }
  }

  String _safeFileName() {
    final base = widget.name.trim().isNotEmpty ? widget.name.trim() : 'document';
    final cleaned = base.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final hasExtension = RegExp(r'\.[a-zA-Z0-9]{1,5}$').hasMatch(cleaned);
    return hasExtension ? cleaned : '$cleaned.$_fileExtension';
  }

  Future<void> _download() async {
    final bytes = _bytes;
    if (bytes == null) {
      AppToast.error(context, message: 'Document is not ready yet.');
      return;
    }
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final dir = await getTemporaryDirectory();
      final fileName = _safeFileName();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              mimeType: _kind == _DocKind.pdf ? 'application/pdf' : null,
              name: fileName,
            ),
          ],
          title: widget.name,
          subject: widget.name,
          sharePositionOrigin: _shareOrigin,
        ),
      );
    } catch (_) {
      if (mounted) {
        AppToast.error(context, message: 'Could not save this document.');
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  /// Anchor rect for the share sheet (required on iPad to avoid a crash).
  Rect? get _shareOrigin {
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      AppToast.error(context, message: 'This document link is invalid.');
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        AppToast.error(context, message: 'Could not open this document.');
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, message: 'Could not open this document.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(
        title: widget.name,
        // The default back button resolves the go_router navigator, which does
        // not pop this MaterialPageRoute. Use this screen's own navigator.
        onBack: () => Navigator.of(context).maybePop(),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: AppColors.primary),
          tooltip: 'Open in Browser',
          onPressed: _loading ? null : _openExternally,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.primary(
                    label: 'Download',
                    icon: const Icon(Icons.download_outlined, size: 20),
                    onPressed: (_loading || _downloading) ? null : _download,
                    isLoading: _downloading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  AppButton.secondary(
                    label: 'Open in Browser',
                    icon: const Icon(Icons.open_in_new, size: 20),
                    onPressed: _loading ? null : _openExternally,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.error),
              const SizedBox(height: AppSpacing.space16),
              Text(
                _error!,
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    switch (_kind) {
      case _DocKind.image:
        final bytes = _bytes;
        if (bytes == null) {
          return _buildUnsupported();
        }
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                size: 56,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      case _DocKind.pdf:
        final controller = _webController;
        if (controller == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return WebViewWidget(controller: controller);
      case _DocKind.other:
        return _buildUnsupported();
    }
  }

  Widget _buildUnsupported() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'This file type is not supported for in-app preview. '
              'Use "Download" to save it.',
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
