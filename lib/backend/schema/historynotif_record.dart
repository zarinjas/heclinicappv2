import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistorynotifRecord extends FirestoreRecord {
  HistorynotifRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id_patient" field.
  String? _idPatient;
  String get idPatient => _idPatient ?? '';
  bool hasIdPatient() => _idPatient != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "tittle" field.
  String? _tittle;
  String get tittle => _tittle ?? '';
  bool hasTittle() => _tittle != null;

  // "read" field.
  String? _read;
  String get read => _read ?? '';
  bool hasRead() => _read != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "appointment" field.
  String? _appointment;
  String get appointment => _appointment ?? '';
  bool hasAppointment() => _appointment != null;

  void _initializeFields() {
    _idPatient = snapshotData['id_patient'] as String?;
    _message = snapshotData['message'] as String?;
    _tittle = snapshotData['tittle'] as String?;
    _read = snapshotData['read'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _appointment = snapshotData['appointment'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('historynotif');

  static Stream<HistorynotifRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => HistorynotifRecord.fromSnapshot(s));

  static Future<HistorynotifRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => HistorynotifRecord.fromSnapshot(s));

  static HistorynotifRecord fromSnapshot(DocumentSnapshot snapshot) =>
      HistorynotifRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static HistorynotifRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      HistorynotifRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'HistorynotifRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is HistorynotifRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createHistorynotifRecordData({
  String? idPatient,
  String? message,
  String? tittle,
  String? read,
  DateTime? createdAt,
  String? appointment,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id_patient': idPatient,
      'message': message,
      'tittle': tittle,
      'read': read,
      'created_at': createdAt,
      'appointment': appointment,
    }.withoutNulls,
  );

  return firestoreData;
}

class HistorynotifRecordDocumentEquality
    implements Equality<HistorynotifRecord> {
  const HistorynotifRecordDocumentEquality();

  @override
  bool equals(HistorynotifRecord? e1, HistorynotifRecord? e2) {
    return e1?.idPatient == e2?.idPatient &&
        e1?.message == e2?.message &&
        e1?.tittle == e2?.tittle &&
        e1?.read == e2?.read &&
        e1?.createdAt == e2?.createdAt &&
        e1?.appointment == e2?.appointment;
  }

  @override
  int hash(HistorynotifRecord? e) => const ListEquality().hash([
        e?.idPatient,
        e?.message,
        e?.tittle,
        e?.read,
        e?.createdAt,
        e?.appointment
      ]);

  @override
  bool isValidKey(Object? o) => o is HistorynotifRecord;
}
