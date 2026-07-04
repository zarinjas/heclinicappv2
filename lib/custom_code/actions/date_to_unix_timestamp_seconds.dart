// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl/intl.dart';

Future<int> dateToUnixTimestampSeconds(DateTime inputDate) async {
  // Set jam, menit, detik ke 00:00:00 UTC (normalize ke awal hari UTC)
  final utcDate = DateTime.utc(inputDate.year, inputDate.month, inputDate.day);

  // Dapatkan timestamp dalam detik
  final unixSeconds = utcDate.millisecondsSinceEpoch ~/ 1000;

  return unixSeconds;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
