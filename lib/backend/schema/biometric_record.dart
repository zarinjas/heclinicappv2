import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BiometricRecord extends FirestoreRecord {
  BiometricRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "idplato" field.
  String? _idplato;
  String get idplato => _idplato ?? '';
  bool hasIdplato() => _idplato != null;

  // "biometricfinger" field.
  String? _biometricfinger;
  String get biometricfinger => _biometricfinger ?? '';
  bool hasBiometricfinger() => _biometricfinger != null;

  // "biometricface" field.
  String? _biometricface;
  String get biometricface => _biometricface ?? '';
  bool hasBiometricface() => _biometricface != null;

  void _initializeFields() {
    _idplato = snapshotData['idplato'] as String?;
    _biometricfinger = snapshotData['biometricfinger'] as String?;
    _biometricface = snapshotData['biometricface'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('biometric');

  static Stream<BiometricRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BiometricRecord.fromSnapshot(s));

  static Future<BiometricRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BiometricRecord.fromSnapshot(s));

  static BiometricRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BiometricRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BiometricRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BiometricRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BiometricRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BiometricRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBiometricRecordData({
  String? idplato,
  String? biometricfinger,
  String? biometricface,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'idplato': idplato,
      'biometricfinger': biometricfinger,
      'biometricface': biometricface,
    }.withoutNulls,
  );

  return firestoreData;
}

class BiometricRecordDocumentEquality implements Equality<BiometricRecord> {
  const BiometricRecordDocumentEquality();

  @override
  bool equals(BiometricRecord? e1, BiometricRecord? e2) {
    return e1?.idplato == e2?.idplato &&
        e1?.biometricfinger == e2?.biometricfinger &&
        e1?.biometricface == e2?.biometricface;
  }

  @override
  int hash(BiometricRecord? e) => const ListEquality()
      .hash([e?.idplato, e?.biometricfinger, e?.biometricface]);

  @override
  bool isValidKey(Object? o) => o is BiometricRecord;
}
