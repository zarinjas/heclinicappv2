// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:phone_form_field/phone_form_field.dart';

class Phonefield extends StatefulWidget {
  const Phonefield({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Phonefield> createState() => _PhonefieldState();
}

class _PhonefieldState extends State<Phonefield> {
  late final PhoneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PhoneController(
      initialValue: PhoneNumber.parse('+60'), // ✅ benar
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: PhoneFormField(
        controller: _controller,
        countrySelectorNavigator: const CountrySelectorNavigator.bottomSheet(),
        isCountryButtonPersistent: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
        validator: PhoneValidator.validMobile(context),
        onChanged: (phone) {
          FFAppState().phonefield = phone?.international ?? '';
        },
      ),
    );
  }
}
