import 'package:html/parser.dart' as html_parser;

/// Strips HTML tags from [html] and returns readable plain text.
///
/// Paragraph and line breaks are preserved as newlines (suitable for the
/// record detail view), and HTML entities are decoded using the `html` parser
/// so `&nbsp;`, `&amp;`, `&#39;`, etc. all resolve correctly.
String stripHtml(String html) {
  if (html.isEmpty) return '';

  var text = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</div\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');

  // Decode any remaining entities (the parser also handles numeric refs).
  text = html_parser.parseFragment(text).text ?? '';

  return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

/// Like [stripHtml], but collapses all whitespace to single spaces. Use for
/// single-line contexts such as list titles.
String stripHtmlToSingleLine(String html) =>
    stripHtml(html).replaceAll(RegExp(r'\s+'), ' ').trim();
