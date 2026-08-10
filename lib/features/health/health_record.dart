import '../../core/widgets/health_record_card.dart';

/// A clinical record shown in the Health tab.
///
/// Records come from Plato through the authenticated proxy: notes from
/// `patient/{id}/note`, letters from `letter`, and the medical certificate from
/// the MC endpoint.
class HealthRecord {
  final HealthRecordType type;
  final String title;
  final String date;
  final String author;

  /// Full content for the detail screen: note text, letter HTML, or MC path.
  final String? detailData;

  final String? category;
  final List<String>? diagnosis;

  const HealthRecord({
    required this.type,
    required this.title,
    required this.date,
    required this.author,
    this.detailData,
    this.category,
    this.diagnosis,
  });

  String get typeLabel {
    switch (type) {
      case HealthRecordType.note:
        return 'Clinical Note';
      case HealthRecordType.letter:
        return 'Letter';
      case HealthRecordType.lab:
        return 'Lab Result';
      case HealthRecordType.mc:
        return 'Medical Certificate';
    }
  }

  /// Letters arrive as HTML; the detail screen strips tags for display.
  bool get isHtml => type == HealthRecordType.letter;

  /// The MC is a file path rather than inline content.
  bool get isFile => type == HealthRecordType.mc;
}
