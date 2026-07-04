import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'change_password_widget.dart' show ChangePasswordWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ChangePasswordModel extends FlutterFlowModel<ChangePasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for passworconfirmation widget.
  FocusNode? passworconfirmationFocusNode;
  TextEditingController? passworconfirmationTextController;
  late bool passworconfirmationVisibility;
  String? Function(BuildContext, String?)?
      passworconfirmationTextControllerValidator;
  // Stores action output result for [Backend Call - API (firsttimechangepassword)] action in Button-Login widget.
  ApiCallResponse? apiResult4qc;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    passworconfirmationVisibility = false;
  }

  @override
  void dispose() {
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    passworconfirmationFocusNode?.dispose();
    passworconfirmationTextController?.dispose();
  }
}
