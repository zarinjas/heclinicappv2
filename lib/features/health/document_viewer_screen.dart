import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';

enum _DocKind { image, pdf, other }

/// In-app viewer for a patient document (PDF or image) with a download action.
///
/// The file bytes are downloaded through the signed, time-limited URL (which is
/// self-authenticating, so no auth header is needed) and then rendered natively
/// with [Image] / [pdfx], instead of relying on a WebView that cannot display
/// PDFs on every platform. A "Open / Download" action always remains available
/// for external viewing and saving.
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
  String? _error;
  Uint8List? _bytes;
  _DocKind _kind = _DocKind.other;
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
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
        final document = await PdfDocument.openData(bytes);
        if (!mounted) {
          await document.close();
          return;
        }
        setState(() {
          _kind = kind;
          _pdfController = PdfController(document: Future.value(document));
          _loading = false;
        });
        return;
      }

      setState(() {
        _error = 'This file type is not supported for in-app preview. '
            'Use "Open / Download" to view it in another app.';
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
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: AppColors.primary),
          tooltip: 'Open / Download',
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
              child: AppButton.secondary(
                label: 'Open / Download',
                icon: const Icon(Icons.file_download_outlined, size: 20),
                onPressed: _loading ? null : _openExternally,
                isFullWidth: true,
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
              const SizedBox(height: AppSpacing.space16),
              AppButton.secondary(
                label: 'Open in browser',
                onPressed: _openExternally,
              ),
            ],
          ),
        ),
      );
    }

    switch (_kind) {
      case _DocKind.image:
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(
              _bytes!,
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
        return PdfView(controller: _pdfController!);
      case _DocKind.other:
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
                  'Use "Open / Download" to view it in another app.',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }
}
