import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/flutter_flow/flutter_flow_web_view.dart';

/// A single clinical case note. The note body is HTML from Plato, rendered by
/// FlutterFlowWebView — that stays; only the surrounding chrome was migrated
/// off FlutterFlowTheme onto the design system.
class AlertReportWidget extends StatelessWidget {
  const AlertReportWidget({
    super.key,
    required this.author,
    required this.time,
    required this.note,
    required this.kategori,
    this.diagnosis,
  });

  final String? author;
  final String? time;
  final String? note;
  final String? kategori;
  final List<String>? diagnosis;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final divider = isDark ? AppColors.dividerDark : AppColors.divider;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final diag = diagnosis ?? const [];

    return Container(
      width: 500.0,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
        border: Border.all(color: divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space12,
                AppSpacing.space8,
                AppSpacing.space12,
                AppSpacing.space12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.space12),
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          style: AppTextStyles.body1.copyWith(color: textColor),
                          children: [
                            const TextSpan(text: 'Author: '),
                            TextSpan(
                              text: author ?? '-',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _tag(kategori?.isNotEmpty == true ? kategori! : 'Case Note'),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: divider),
            if (diag.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space8,
                  AppSpacing.space8,
                  AppSpacing.space8,
                  AppSpacing.space8,
                ),
                child: Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space8,
                  children: diag.map(_tag).toList(),
                ),
              ),
            FlutterFlowWebView(
              content: note ?? '',
              width: MediaQuery.sizeOf(context).width,
              height: 380.38,
              verticalScroll: false,
              horizontalScroll: false,
              html: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        border: Border.all(color: AppColors.accent),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
