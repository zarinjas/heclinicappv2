import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FcmRecord extends FirestoreRecord {
  FcmRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id_patient" field.
  String? _idPatient;
  String get idPatient => _idPatient ?? '';
  bool hasIdPatient() => _idPatient != null;

  // "fcm_token" field.
  String? _fcmToken;
  String get fcmToken => _fcmToken ?? '';
  bool hasFcmToken() => _fcmToken != null;

  void _initializeFields() {
    _idPatient = snapshotData['id_patient'] as String?;
    _fcmToken = snapshotData['fcm_token'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('fcm');

  static Stream<FcmRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FcmRecord.fromSnapshot(s));

  static Future<FcmRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FcmRecord.fromSnapshot(s));

  static FcmRecord fromSnapshot(DocumentSnapshot snapshot) => FcmRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FcmRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FcmRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FcmRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FcmRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFcmRecordData({
  String? idPatient,
  String? fcmToken,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id_patient': idPatient,
      'fcm_token': fcmToken,
    }.withoutNulls,
  );

  return firestoreData;
}

class FcmRecordDocumentEquality implements Equality<FcmRecord> {
  const FcmRecordDocumentEquality();

  @override
  bool equals(FcmRecord? e1, FcmRecord? e2) {
    return e1?.idPatient == e2?.idPatient && e1?.fcmToken == e2?.fcmToken;
  }

  @override
  int hash(FcmRecord? e) =>
      const ListEquality().hash([e?.idPatient, e?.fcmToken]);

  @override
  bool isValidKey(Object? o) => o is FcmRecord;
}
