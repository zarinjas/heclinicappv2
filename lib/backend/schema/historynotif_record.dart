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

  // "message" field (backward compat — old field name).
  String? _message;
  String get message {
    if (_message != null && _message!.isNotEmpty) return _message!;
    return _body ?? '';
  }
  bool hasMessage() => _message != null || _body != null;

  // "tittle" field (backward compat — old field name).
  String? _tittle;
  String get tittle {
    if (_tittle != null && _tittle!.isNotEmpty) return _tittle!;
    return _title ?? '';
  }
  bool hasTittle() => _tittle != null || _title != null;

  // "title" field (new field name).
  String? _title;
  String get title => _title ?? tittle;
  bool hasTitle() => _title != null || _tittle != null;

  // "body" field (new field name).
  String? _body;
  String get body => _body ?? message;
  bool hasBody() => _body != null || _message != null;

  // "read" field — supports both bool (new) and string "yes"/"no" (old).
  dynamic _read;
  String get read => readBool ? 'yes' : 'no';
  bool get readBool {
    if (_read == null) return false;
    if (_read is bool) return _read;
    if (_read is String) return _read == 'yes';
    return false;
  }
  bool hasRead() => _read != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "appointment" field.
  String? _appointment;
  String get appointment => _appointment ?? '';
  bool hasAppointment() => _appointment != null;

  // "deep_link" field.
  String? _deepLink;
  String get deepLink => _deepLink ?? '';
  bool hasDeepLink() => _deepLink != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  void _initializeFields() {
    _idPatient = snapshotData['id_patient'] as String?;
    _message = snapshotData['message'] as String?;
    _tittle = snapshotData['tittle'] as String?;
    _title = snapshotData['title'] as String?;
    _body = snapshotData['body'] as String?;
    _read = snapshotData['read'];
    _createdAt = snapshotData['created_at'] as DateTime?;
    _appointment = snapshotData['appointment'] as String?;
    _deepLink = snapshotData['deep_link'] as String?;
    _type = snapshotData['type'] as String?;
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
  String? title,
  String? body,
  String? read,
  bool? readBool,
  DateTime? createdAt,
  String? appointment,
  String? deepLink,
  String? type,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id_patient': idPatient,
      'message': message,
      'tittle': tittle,
      'title': title,
      'body': body,
      'read': readBool ?? read,
      'created_at': createdAt,
      'appointment': appointment,
      'deep_link': deepLink,
      'type': type,
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
        e1?.title == e2?.title &&
        e1?.body == e2?.body &&
        e1?.readBool == e2?.readBool &&
        e1?.createdAt == e2?.createdAt &&
        e1?.appointment == e2?.appointment &&
        e1?.deepLink == e2?.deepLink &&
        e1?.type == e2?.type;
  }

  @override
  int hash(HistorynotifRecord? e) => const ListEquality().hash([
        e?.idPatient,
        e?.message,
        e?.tittle,
        e?.title,
        e?.body,
        e?.readBool,
        e?.createdAt,
        e?.appointment,
        e?.deepLink,
        e?.type,
      ]);

  @override
  bool isValidKey(Object? o) => o is HistorynotifRecord;
}
