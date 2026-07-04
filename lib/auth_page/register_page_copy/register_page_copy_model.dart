import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'register_page_copy_widget.dart' show RegisterPageCopyWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class RegisterPageCopyModel extends FlutterFlowModel<RegisterPageCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode;
  TextEditingController? yournameTextController;
  String? Function(BuildContext, String?)? yournameTextControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for icnumber widget.
  FocusNode? icnumberFocusNode;
  TextEditingController? icnumberTextController;
  String? Function(BuildContext, String?)? icnumberTextControllerValidator;
  // Stores action output result for [Backend Call - API (Register)] action in Button-Login widget.
  ApiCallResponse? apiresultnya;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yournameFocusNode?.dispose();
    yournameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    icnumberFocusNode?.dispose();
    icnumberTextController?.dispose();
  }
}
