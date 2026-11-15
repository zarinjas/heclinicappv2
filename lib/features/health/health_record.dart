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

  /// File URLs attached to a clinical note (lab results, images, etc.).
  final List<String>? attachments;

  const HealthRecord({
    required this.type,
    required this.title,
    required this.date,
    required this.author,
    this.detailData,
    this.category,
    this.diagnosis,
    this.attachments,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        type: HealthRecordType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => HealthRecordType.letter,
        ),
        title: (json['title'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        detailData: json['detailData'] as String?,
        category: json['category'] as String?,
        diagnosis: (json['diagnosis'] as List?)?.map((e) => e.toString()).toList(),
        attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'date': date,
        'author': author,
        if (detailData != null) 'detailData': detailData,
        if (category != null) 'category': category,
        if (diagnosis != null) 'diagnosis': diagnosis,
        if (attachments != null) 'attachments': attachments,
      };

  String get typeLabel {
    switch (type) {
      case HealthRecordType.letter:
        return 'Letter';
      case HealthRecordType.lab:
        return 'Lab Result';
      case HealthRecordType.mc:
        return 'Medical Certificate';
    }
  }

  /// Content is HTML when the payload looks like markup (letters, and medical
  /// certificates that arrive through the `letter` endpoint).
  bool get isHtml => (detailData ?? '').contains('<');

  /// The record points at a hosted file (e.g. a PDF) rather than inline content.
  bool get isFile {
    final data = detailData;
    if (data == null || data.trim().isEmpty || isHtml) return false;
    return Uri.tryParse(data)?.hasScheme ?? false;
  }
}
