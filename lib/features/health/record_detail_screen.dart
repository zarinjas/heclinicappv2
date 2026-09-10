import 'package:flutter/material.dart';
import '/core/widgets/app_toast.dart';

import '../../app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/api_url.dart';
import '../../core/utils/html_text.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../env_config.dart';
import 'document_viewer_screen.dart';
import 'health_record.dart';

/// Shows the full content of a single clinical record.
///
/// The record is passed in whole, since the list call already returned the
/// content — there is no per-record Plato endpoint to re-fetch from.
class RecordDetailScreen extends StatelessWidget {
  final HealthRecord record;

  const RecordDetailScreen({super.key, required this.record});

  /// Opens the record's attached file (the medical certificate) in the same
  /// in-app viewer used for documents, with Download / Open in Browser actions.
  void _openFile(BuildContext context) {
    final url = record.detailData;
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _notify(context, 'This file link is invalid.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          name: record.title,
          url: url,
          // The MC is served by Plato behind the patient's bearer token.
          authToken: FFAppState().tokenauth,
        ),
      ),
    );
  }

  void _notify(BuildContext context, String message) {
    AppToast.info(context, message: message);
  }

  /// Opens an attached file (lab result, image, etc.) in the in-app viewer.
  void _openAttachment(BuildContext context, String url) {
    final resolved = resolveBackendUrl(url, baseUrl: EnvConfig.platomBaseUrl);
    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) {
      _notify(context, 'This attachment link is invalid.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          name: _fileNameFromUrl(url),
          url: resolved,
          // Plato-hosted files sit behind the patient's bearer token.
          authToken: FFAppState().tokenauth,
        ),
      ),
    );
  }

  static String _fileNameFromUrl(String url) {
    final withoutQuery = url.split('?').first;
    final name = withoutQuery.split('/').last;
    return name.isEmpty ? 'Attachment' : name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppAppBar.sub(title: record.typeLabel),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: AppSpacing.space16),
            _buildContent(context, isDark),
            if (record.attachments != null && record.attachments!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space16),
              _buildAttachments(context, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, bool isDark) {
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attachments', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.space4),
          for (final url in record.attachments!)
            InkWell(
              onTap: () => _openAttachment(context, url),
              borderRadius: BorderRadius.circular(AppSpacing.space8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 20, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        _fileNameFromUrl(url),
                        style: AppTextStyles.body1.copyWith(color: secondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 20, color: secondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.title, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.space8),
          if (record.author.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: secondary),
                const SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Text(
                    record.author,
                    style: AppTextStyles.body2.copyWith(color: secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          if (record.date.isNotEmpty)
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: secondary),
                const SizedBox(width: AppSpacing.space4),
                Text(
                  record.date,
                  style: AppTextStyles.body2.copyWith(color: secondary),
                ),
              ],
            ),
          if (record.category != null && record.category!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            AppChip(label: record.category!, type: AppChipType.status),
          ],
          if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            Text('Diagnosis', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.space8),
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: record.diagnosis!
                  .map((d) => AppChip(label: d, type: AppChipType.status))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final content = record.detailData;

    if (content == null || content.trim().isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          icon: Icons.article_outlined,
          title: 'No content',
          subtitle: 'This record has no additional details',
        ),
      );
    }

    // The medical certificate is a file, not inline text.
    if (record.isFile) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppColors.accent),
                const SizedBox(width: AppSpacing.space12),
                Expanded(child: Text(record.title, style: AppTextStyles.body1)),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            FilledButton.icon(
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open certificate'),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.space8),
          SelectableText(
            record.isHtml ? stripHtml(content) : content,
            style: AppTextStyles.body1.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
