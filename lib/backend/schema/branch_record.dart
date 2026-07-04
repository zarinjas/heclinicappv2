import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BranchRecord extends FirestoreRecord {
  BranchRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "branchName" field.
  String? _branchName;
  String get branchName => _branchName ?? '';
  bool hasBranchName() => _branchName != null;

  // "branchAddress" field.
  String? _branchAddress;
  String get branchAddress => _branchAddress ?? '';
  bool hasBranchAddress() => _branchAddress != null;

  // "branchImg" field.
  String? _branchImg;
  String get branchImg => _branchImg ?? '';
  bool hasBranchImg() => _branchImg != null;

  // "branchCategories" field.
  String? _branchCategories;
  String get branchCategories => _branchCategories ?? '';
  bool hasBranchCategories() => _branchCategories != null;

  // "branchNumber" field.
  int? _branchNumber;
  int get branchNumber => _branchNumber ?? 0;
  bool hasBranchNumber() => _branchNumber != null;

  // "latitude" field.
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  bool hasLatitude() => _latitude != null;

  // "longitude" field.
  double? _longitude;
  double get longitude => _longitude ?? 0.0;
  bool hasLongitude() => _longitude != null;

  void _initializeFields() {
    _branchName = snapshotData['branchName'] as String?;
    _branchAddress = snapshotData['branchAddress'] as String?;
    _branchImg = snapshotData['branchImg'] as String?;
    _branchCategories = snapshotData['branchCategories'] as String?;
    _branchNumber = castToType<int>(snapshotData['branchNumber']);
    _latitude = castToType<double>(snapshotData['latitude']);
    _longitude = castToType<double>(snapshotData['longitude']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('branch');

  static Stream<BranchRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BranchRecord.fromSnapshot(s));

  static Future<BranchRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BranchRecord.fromSnapshot(s));

  static BranchRecord fromSnapshot(DocumentSnapshot snapshot) => BranchRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BranchRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BranchRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BranchRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BranchRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBranchRecordData({
  String? branchName,
  String? branchAddress,
  String? branchImg,
  String? branchCategories,
  int? branchNumber,
  double? latitude,
  double? longitude,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'branchName': branchName,
      'branchAddress': branchAddress,
      'branchImg': branchImg,
      'branchCategories': branchCategories,
      'branchNumber': branchNumber,
      'latitude': latitude,
      'longitude': longitude,
    }.withoutNulls,
  );

  return firestoreData;
}

class BranchRecordDocumentEquality implements Equality<BranchRecord> {
  const BranchRecordDocumentEquality();

  @override
  bool equals(BranchRecord? e1, BranchRecord? e2) {
    return e1?.branchName == e2?.branchName &&
        e1?.branchAddress == e2?.branchAddress &&
        e1?.branchImg == e2?.branchImg &&
        e1?.branchCategories == e2?.branchCategories &&
        e1?.branchNumber == e2?.branchNumber &&
        e1?.latitude == e2?.latitude &&
        e1?.longitude == e2?.longitude;
  }

  @override
  int hash(BranchRecord? e) => const ListEquality().hash([
        e?.branchName,
        e?.branchAddress,
        e?.branchImg,
        e?.branchCategories,
        e?.branchNumber,
        e?.latitude,
        e?.longitude
      ]);

  @override
  bool isValidKey(Object? o) => o is BranchRecord;
}
