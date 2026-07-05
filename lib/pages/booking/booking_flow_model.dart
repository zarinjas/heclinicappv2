import 'package:flutter/material.dart';

class BookingFlowModel extends ChangeNotifier {
  static BookingFlowModel _instance = BookingFlowModel._internal();

  factory BookingFlowModel() => _instance;

  BookingFlowModel._internal();

  static void reset() {
    _instance = BookingFlowModel._internal();
  }

  String _selectedBranchId = '';
  String get selectedBranchId => _selectedBranchId;

  String _selectedBranchName = '';
  String get selectedBranchName => _selectedBranchName;

  String _selectedBranchImage = '';
  String get selectedBranchImage => _selectedBranchImage;

  String _selectedBranchAddress = '';
  String get selectedBranchAddress => _selectedBranchAddress;

  String _selectedBranchHours = '';
  String get selectedBranchHours => _selectedBranchHours;

  String _selectedBranchWhatsApp = '';
  String get selectedBranchWhatsApp => _selectedBranchWhatsApp;

  void selectBranch({
    required String id,
    required String name,
    required String image,
    required String address,
    required String hours,
    String whatsApp = '',
  }) {
    _selectedBranchId = id;
    _selectedBranchName = name;
    _selectedBranchImage = image;
    _selectedBranchAddress = address;
    _selectedBranchHours = hours;
    _selectedBranchWhatsApp = whatsApp;
    notifyListeners();
  }

  String _selectedDoctorId = '';
  String get selectedDoctorId => _selectedDoctorId;

  String _selectedDoctorName = '';
  String get selectedDoctorName => _selectedDoctorName;

  bool _isNoPreference = false;
  bool get isNoPreference => _isNoPreference;

  void selectDoctor({
    required String id,
    required String name,
    required bool isNoPreference,
  }) {
    _selectedDoctorId = id;
    _selectedDoctorName = name;
    _isNoPreference = isNoPreference;
    notifyListeners();
  }

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String _selectedTime = '';
  String get selectedTime => _selectedTime;

  String _selectedSlotId = '';
  String get selectedSlotId => _selectedSlotId;

  void selectDateTime({
    required DateTime date,
    required String time,
    required String slotId,
  }) {
    _selectedDate = date;
    _selectedTime = time;
    _selectedSlotId = slotId;
    notifyListeners();
  }
}
