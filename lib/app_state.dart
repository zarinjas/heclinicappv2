import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _isLoggedIn = prefs.getBool('ff_isLoggedIn') ?? _isLoggedIn;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _userEmail = '';
  String get userEmail => _userEmail;
  set userEmail(String value) {
    _userEmail = value;
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    prefs.setBool('ff_isLoggedIn', value);
  }

  String _registerEmail = '';
  String get registerEmail => _registerEmail;
  set registerEmail(String value) {
    _registerEmail = value;
  }

  String _username = '';
  String get username => _username;
  set username(String value) {
    _username = value;
  }

  String _password = '';
  String get password => _password;
  set password(String value) {
    _password = value;
  }

  String _tokenauth = '';
  String get tokenauth => _tokenauth;
  set tokenauth(String value) {
    _tokenauth = value;
  }

  String _fcmtoken = '';
  String get fcmtoken => _fcmtoken;
  set fcmtoken(String value) {
    _fcmtoken = value;
  }

  String _timepick = '';
  String get timepick => _timepick;
  set timepick(String value) {
    _timepick = value;
  }

  String _Upcoming = '';
  String get Upcoming => _Upcoming;
  set Upcoming(String value) {
    _Upcoming = value;
  }

  bool _notifappointment = false;
  bool get notifappointment => _notifappointment;
  set notifappointment(bool value) {
    _notifappointment = value;
  }

  String _idplato = '';
  String get idplato => _idplato;
  set idplato(String value) {
    _idplato = value;
  }

  String _coutnnotif = '0';
  String get coutnnotif => _coutnnotif;
  set coutnnotif(String value) {
    _coutnnotif = value;
  }

  void incrementNotifCount() {
    try {
      final current = int.parse(_coutnnotif);
      _coutnnotif = (current + 1).toString();
      notifyListeners();
    } catch (_) {
      _coutnnotif = '1';
      notifyListeners();
    }
  }

  void resetNotifCount() {
    _coutnnotif = '0';
    notifyListeners();
  }

  List<String> _Listcode = [];
  List<String> get Listcode => _Listcode;
  set Listcode(List<String> value) {
    _Listcode = value;
  }

  void addToListcode(String value) {
    Listcode.add(value);
  }

  void removeFromListcode(String value) {
    Listcode.remove(value);
  }

  void removeAtIndexFromListcode(int index) {
    Listcode.removeAt(index);
  }

  void updateListcodeAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    Listcode[index] = updateFn(_Listcode[index]);
  }

  void insertAtIndexInListcode(int index, String value) {
    Listcode.insert(index, value);
  }

  List<String> _ListDoctorName = [];
  List<String> get ListDoctorName => _ListDoctorName;
  set ListDoctorName(List<String> value) {
    _ListDoctorName = value;
  }

  void addToListDoctorName(String value) {
    ListDoctorName.add(value);
  }

  void removeFromListDoctorName(String value) {
    ListDoctorName.remove(value);
  }

  void removeAtIndexFromListDoctorName(int index) {
    ListDoctorName.removeAt(index);
  }

  void updateListDoctorNameAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    ListDoctorName[index] = updateFn(_ListDoctorName[index]);
  }

  void insertAtIndexInListDoctorName(int index, String value) {
    ListDoctorName.insert(index, value);
  }

  String _name = '';
  String get name => _name;
  set name(String value) {
    _name = value;
  }

  bool _fingerprint = false;
  bool get fingerprint => _fingerprint;
  set fingerprint(bool value) {
    _fingerprint = value;
  }

  bool _faceid = false;
  bool get faceid => _faceid;
  set faceid(bool value) {
    _faceid = value;
  }

  bool _passwordChanged = false;
  bool get passwordChanged => _passwordChanged;
  set passwordChanged(bool value) {
    _passwordChanged = value;
  }

  String _givenid = '';
  String get givenid => _givenid;
  set givenid(String value) {
    _givenid = value;
  }

  String _phonefield = '';
  String get phonefield => _phonefield;
  set phonefield(String value) {
    _phonefield = value;
  }

  String _nationalman = '';
  String get nationalman => _nationalman;
  set nationalman(String value) {
    _nationalman = value;
  }

  List<String> _defaultprovider = [];
  List<String> get defaultprovider => _defaultprovider;
  set defaultprovider(List<String> value) {
    _defaultprovider = value;
  }

  void addToDefaultprovider(String value) {
    defaultprovider.add(value);
  }

  void removeFromDefaultprovider(String value) {
    defaultprovider.remove(value);
  }

  void removeAtIndexFromDefaultprovider(int index) {
    defaultprovider.removeAt(index);
  }

  void updateDefaultproviderAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    defaultprovider[index] = updateFn(_defaultprovider[index]);
  }

  void insertAtIndexInDefaultprovider(int index, String value) {
    defaultprovider.insert(index, value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
