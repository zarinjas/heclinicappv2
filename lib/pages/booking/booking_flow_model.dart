import 'package:flutter/material.dart';

class BookingFlowModel extends ChangeNotifier {
  static final BookingFlowModel _instance = BookingFlowModel._internal();

  factory BookingFlowModel() => _instance;

  BookingFlowModel._internal();

  /// Clears the current booking selection in place. The singleton instance is
  /// kept so screens that captured `BookingFlowModel()` keep referencing the
  /// same object (replacing it here broke the flow and dropped the branch).
  static void reset() => _instance.clear();

  void clear() {
    _selectedBranchId = '';
    _selectedBranchName = '';
    _selectedBranchImage = '';
    _selectedBranchAddress = '';
    _selectedBranchHours = '';
    _selectedBranchOperatingHours = {};
    _selectedBranchWhatsApp = '';
    _selectedDoctorId = '';
    _selectedDoctorName = '';
    _isNoPreference = false;
    _selectedDoctorCalendarColorIds = [];
    _selectedDate = null;
    _selectedTime = '';
    _selectedSlotId = '';
    _bookingRemark = '';
    notifyListeners();
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

  Map<String, String> _selectedBranchOperatingHours = {};
  Map<String, String> get selectedBranchOperatingHours =>
      _selectedBranchOperatingHours;

  String _selectedBranchWhatsApp = '';
  String get selectedBranchWhatsApp => _selectedBranchWhatsApp;

  void selectBranch({
    required String id,
    required String name,
    required String image,
    required String address,
    required String hours,
    required Map<String, String> operatingHours,
    String whatsApp = '',
  }) {
    _selectedBranchId = id;
    _selectedBranchName = name;
    _selectedBranchImage = image;
    _selectedBranchAddress = address;
    _selectedBranchHours = hours;
    _selectedBranchOperatingHours = operatingHours;
    _selectedBranchWhatsApp = whatsApp;
    notifyListeners();
  }

  String _selectedDoctorId = '';
  String get selectedDoctorId => _selectedDoctorId;

  String _selectedDoctorName = '';
  String get selectedDoctorName => _selectedDoctorName;

  bool _isNoPreference = false;
  bool get isNoPreference => _isNoPreference;

  List<String> _selectedDoctorCalendarColorIds = [];
  List<String> get selectedDoctorCalendarColorIds =>
      _selectedDoctorCalendarColorIds;

  void selectDoctor({
    required String id,
    required String name,
    required bool isNoPreference,
    List<String> calendarColorIds = const [],
  }) {
    _selectedDoctorId = id;
    _selectedDoctorName = name;
    _isNoPreference = isNoPreference;
    _selectedDoctorCalendarColorIds = calendarColorIds;
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

  String _bookingRemark = '';
  String get bookingRemark => _bookingRemark;

  void setRemark(String remark) {
    _bookingRemark = remark;
    notifyListeners();
  }
}
