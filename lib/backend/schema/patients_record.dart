import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PatientsRecord extends FirestoreRecord {
  PatientsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _name = snapshotData['name'] as String?;
    _password = snapshotData['password'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('patients');

  static Stream<PatientsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PatientsRecord.fromSnapshot(s));

  static Future<PatientsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PatientsRecord.fromSnapshot(s));

  static PatientsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PatientsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PatientsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PatientsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PatientsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PatientsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPatientsRecordData({
  String? email,
  String? name,
  String? password,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'name': name,
      'password': password,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PatientsRecordDocumentEquality implements Equality<PatientsRecord> {
  const PatientsRecordDocumentEquality();

  @override
  bool equals(PatientsRecord? e1, PatientsRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.name == e2?.name &&
        e1?.password == e2?.password &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(PatientsRecord? e) =>
      const ListEquality().hash([e?.email, e?.name, e?.password, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is PatientsRecord;
}
