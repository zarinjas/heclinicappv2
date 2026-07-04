import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ArticlesRecord extends FirestoreRecord {
  ArticlesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "reference_label" field.
  String? _referenceLabel;
  String get referenceLabel => _referenceLabel ?? '';
  bool hasReferenceLabel() => _referenceLabel != null;

  // "reference_url" field.
  String? _referenceUrl;
  String get referenceUrl => _referenceUrl ?? '';
  bool hasReferenceUrl() => _referenceUrl != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _content = snapshotData['content'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _imageUrl = snapshotData['image_url'] as String?;
    _referenceLabel = snapshotData['reference_label'] as String?;
    _referenceUrl = snapshotData['reference_url'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('articles');

  static Stream<ArticlesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ArticlesRecord.fromSnapshot(s));

  static Future<ArticlesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ArticlesRecord.fromSnapshot(s));

  static ArticlesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ArticlesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ArticlesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ArticlesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ArticlesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ArticlesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createArticlesRecordData({
  String? title,
  String? content,
  DateTime? timestamp,
  String? imageUrl,
  String? referenceLabel,
  String? referenceUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'image_url': imageUrl,
      'reference_label': referenceLabel,
      'reference_url': referenceUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class ArticlesRecordDocumentEquality implements Equality<ArticlesRecord> {
  const ArticlesRecordDocumentEquality();

  @override
  bool equals(ArticlesRecord? e1, ArticlesRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.content == e2?.content &&
        e1?.timestamp == e2?.timestamp &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.referenceLabel == e2?.referenceLabel &&
        e1?.referenceUrl == e2?.referenceUrl;
  }

  @override
  int hash(ArticlesRecord? e) => const ListEquality().hash([
        e?.title,
        e?.content,
        e?.timestamp,
        e?.imageUrl,
        e?.referenceLabel,
        e?.referenceUrl
      ]);

  @override
  bool isValidKey(Object? o) => o is ArticlesRecord;
}
