import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OtpsRecord extends FirestoreRecord {
  OtpsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "expiredAt" field.
  DateTime? _expiredAt;
  DateTime? get expiredAt => _expiredAt;
  bool hasExpiredAt() => _expiredAt != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _code = snapshotData['code'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _expiredAt = snapshotData['expiredAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('otps');

  static Stream<OtpsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OtpsRecord.fromSnapshot(s));

  static Future<OtpsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OtpsRecord.fromSnapshot(s));

  static OtpsRecord fromSnapshot(DocumentSnapshot snapshot) => OtpsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OtpsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OtpsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OtpsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OtpsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOtpsRecordData({
  String? email,
  String? code,
  DateTime? createdAt,
  DateTime? expiredAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'code': code,
      'createdAt': createdAt,
      'expiredAt': expiredAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class OtpsRecordDocumentEquality implements Equality<OtpsRecord> {
  const OtpsRecordDocumentEquality();

  @override
  bool equals(OtpsRecord? e1, OtpsRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.code == e2?.code &&
        e1?.createdAt == e2?.createdAt &&
        e1?.expiredAt == e2?.expiredAt;
  }

  @override
  int hash(OtpsRecord? e) => const ListEquality()
      .hash([e?.email, e?.code, e?.createdAt, e?.expiredAt]);

  @override
  bool isValidKey(Object? o) => o is OtpsRecord;
}
