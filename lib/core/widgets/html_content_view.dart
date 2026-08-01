import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class HtmlContentView extends StatelessWidget {
  const HtmlContentView({
    super.key,
    required this.html,
    this.textColor,
  });

  final String html;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor =
        textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.primary);
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final document = html_parser.parseFragment(html);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: document.nodes
          .whereType<html_dom.Element>()
          .map((node) => _buildNode(node, context, bodyColor, secondaryColor))
          .toList(),
    );
  }

  Widget _buildNode(
    html_dom.Element node,
    BuildContext context,
    Color bodyColor,
    Color secondaryColor,
  ) {
    final tag = node.localName;
    switch (tag) {
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space16, bottom: AppSpacing.space8),
          child: Text(
            node.text,
            style: AppTextStyles.heading1.copyWith(color: bodyColor, height: 1.35),
          ),
        );
      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space16, bottom: AppSpacing.space8),
          child: Text(
            node.text,
            style: AppTextStyles.heading2.copyWith(color: bodyColor, height: 1.35),
          ),
        );
      case 'h3':
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space12, bottom: AppSpacing.space8),
          child: Text(
            node.text,
            style: AppTextStyles.heading3.copyWith(color: bodyColor, height: 1.4),
          ),
        );
      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: _buildRichText(node, context, bodyColor, secondaryColor),
        );
      case 'ul':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: node.children.map((li) => _buildListItem(li, '•', context, bodyColor)).toList(),
          ),
        );
      case 'ol':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(node.children.length, (i) {
              final li = node.children[i];
              return _buildListItem(li, '${i + 1}.', context, bodyColor);
            }),
          ),
        );
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.space12),
          padding: const EdgeInsets.all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: const Border(
              left: BorderSide(color: AppColors.accent, width: 3),
            ),
          ),
          child: _buildRichText(node, context, secondaryColor, secondaryColor),
        );
      case 'pre':
      case 'code':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.space12),
          padding: const EdgeInsets.all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
          ),
          child: Text(
            node.text,
            style: const TextStyle(
              color: Color(0xFFF9FAFB),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        );
      case 'img':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            child: Image.network(
              node.attributes['src'] ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: isDark(context) ? AppColors.surfaceDark : AppColors.divider,
                child: const Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      default:
        return _buildRichText(node, context, bodyColor, secondaryColor);
    }
  }

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Widget _buildListItem(
    html_dom.Element li,
    String bullet,
    BuildContext context,
    Color bodyColor,
  ) {
    final secondaryColor =
        isDark(context) ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space8, top: 1),
            child: Text(
              bullet,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: _buildRichText(li, context, bodyColor, secondaryColor)),
        ],
      ),
    );
  }

  Widget _buildRichText(
    html_dom.Element node,
    BuildContext context,
    Color textColor,
    Color secondaryColor,
  ) {
    final spans = <TextSpan>[];

    void walk(html_dom.Node n, TextStyle style) {
      if (n is html_dom.Text) {
        spans.add(TextSpan(text: n.text));
        return;
      }
      if (n is html_dom.Element) {
        final tag = n.localName;
        if (tag == 'strong' || tag == 'b') {
          for (final c in n.nodes) {
            walk(c, style.copyWith(fontWeight: FontWeight.w700));
          }
          return;
        }
        if (tag == 'em' || tag == 'i') {
          for (final c in n.nodes) {
            walk(c, style.copyWith(fontStyle: FontStyle.italic));
          }
          return;
        }
        if (tag == 'code') {
          for (final c in n.nodes) {
            walk(c, style.copyWith(fontFamily: 'monospace'));
          }
          return;
        }
        if (tag == 'br') {
          spans.add(const TextSpan(text: '\n'));
          return;
        }
        if (tag == 'a') {
          final href = n.attributes['href'];
          final linkStyle = style.copyWith(
            color: AppColors.accent,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.accent,
          );
          final recognizer = TapGestureRecognizer();
          recognizer.onTap = () {
            if (href != null && href.isNotEmpty) _launch(href);
          };
          spans.add(TextSpan(
            text: n.text,
            style: linkStyle,
            recognizer: recognizer,
          ));
          return;
        }
        for (final c in n.nodes) {
          walk(c, style);
        }
      }
    }

    for (final child in node.nodes) {
      walk(child, AppTextStyles.body1.copyWith(color: textColor, height: 1.6));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: AppTextStyles.body1.copyWith(color: textColor, height: 1.6),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
