import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';

/// In-app viewer for a patient document (PDF or image) with a download action.
///
/// The document is served behind a signed, time-limited URL (already
/// self-authenticating), so no extra auth header is required here.
///
/// - Images render natively via [Image.network].
/// - PDFs render in a [WebView]: iOS' WKWebView displays PDFs natively, while
///   Android's WebView cannot, so Android falls back to Google Docs' embedded
///   viewer. A "Open / Download" action is always available for external
///   viewing and saving.
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

  bool get _isImage => mimeType.toLowerCase().startsWith('image/');

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late final WebViewController _controller;

  String get _webUrl {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        widget._isImage) {
      return widget.url;
    }
    // Android WebView can't render PDFs directly; route through Google's
    // embedded viewer. The signed URL is time-limited and public, matching
    // what the external browser would already receive.
    return 'https://docs.google.com/viewer?url='
        '${Uri.encodeComponent(widget.url)}&embedded=true';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_webUrl));
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
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: AppColors.primary),
          tooltip: 'Open / Download',
          onPressed: _openExternally,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildContent()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: AppButton.secondary(
                label: 'Open / Download',
                icon: const Icon(Icons.file_download_outlined, size: 20),
                onPressed: _openExternally,
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget._isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => _buildLoadFailed(),
          ),
        ),
      );
    }

    return WebViewWidget(controller: _controller);
  }

  Widget _buildLoadFailed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Could not preview this document.',
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
}
