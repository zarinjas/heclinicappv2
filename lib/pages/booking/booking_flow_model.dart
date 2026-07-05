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

  void selectBranch({
    required String id,
    required String name,
    required String image,
    required String address,
    required String hours,
  }) {
    _selectedBranchId = id;
    _selectedBranchName = name;
    _selectedBranchImage = image;
    _selectedBranchAddress = address;
    _selectedBranchHours = hours;
    notifyListeners();
  }
}
