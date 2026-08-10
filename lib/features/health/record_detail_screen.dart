import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import 'health_record.dart';

/// Shows the full content of a single clinical record.
///
/// The record is passed in whole, since the list call already returned the
/// content — there is no per-record Plato endpoint to re-fetch from.
class RecordDetailScreen extends StatelessWidget {
  final HealthRecord record;

  const RecordDetailScreen({super.key, required this.record});

  /// Letters come back as HTML. Rendering a full engine for them is overkill,
  /// so tags are stripped and entities decoded for readable plain text.
  static String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '');

    const entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
    };
    entities.forEach((k, v) => text = text.replaceAll(k, v));

    // Collapse the blank-line runs left behind by stripping tags.
    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  Future<void> _openFile(BuildContext context) async {
    final path = record.detailData;
    if (path == null || path.isEmpty) return;

    final uri = Uri.tryParse(path);
    if (uri == null) {
      _notify(context, 'This file link is invalid.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) _notify(context, 'Could not open this file.');
    } catch (_) {
      if (context.mounted) _notify(context, 'Could not open this file.');
    }
  }

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          ],
        ),
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
            record.isHtml ? _stripHtml(content) : content,
            style: AppTextStyles.body1.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
