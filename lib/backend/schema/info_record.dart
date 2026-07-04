import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InfoRecord extends FirestoreRecord {
  InfoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "img" field.
  String? _img;
  String get img => _img ?? '';
  bool hasImg() => _img != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _img = snapshotData['img'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('info');

  static Stream<InfoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => InfoRecord.fromSnapshot(s));

  static Future<InfoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => InfoRecord.fromSnapshot(s));

  static InfoRecord fromSnapshot(DocumentSnapshot snapshot) => InfoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InfoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InfoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InfoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InfoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInfoRecordData({
  String? title,
  String? img,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'img': img,
    }.withoutNulls,
  );

  return firestoreData;
}

class InfoRecordDocumentEquality implements Equality<InfoRecord> {
  const InfoRecordDocumentEquality();

  @override
  bool equals(InfoRecord? e1, InfoRecord? e2) {
    return e1?.title == e2?.title && e1?.img == e2?.img;
  }

  @override
  int hash(InfoRecord? e) => const ListEquality().hash([e?.title, e?.img]);

  @override
  bool isValidKey(Object? o) => o is InfoRecord;
}
