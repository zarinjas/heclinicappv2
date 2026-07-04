// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// make function to print anything
import 'dart:developer' as developer;

Future printanything(
  List<String>? list,
  String? string,
) async {
  if (list != null && list.isNotEmpty) {
    developer.log('Printing list contents:');
    for (int i = 0; i < list.length; i++) {
      developer.log('[$i]: ${list[i]}');
    }
  } else {
    developer.log('List is null or empty');
  }

  if (string != null && string.isNotEmpty) {
    developer.log('Printing string: $string');
  } else {
    developer.log('String is null or empty');
  }

  // Also print to console for debug purposes
  if (list != null && list.isNotEmpty) {
    print('List: $list');
  }

  if (string != null && string.isNotEmpty) {
    print('String: $string');
  }
}
