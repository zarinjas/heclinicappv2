import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'register_page_widget.dart' show RegisterPageWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class RegisterPageModel extends FlutterFlowModel<RegisterPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode1;
  TextEditingController? yournameTextController1;
  String? Function(BuildContext, String?)? yournameTextController1Validator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode2;
  TextEditingController? yournameTextController2;
  String? Function(BuildContext, String?)? yournameTextController2Validator;
  // State field(s) for nricDropDown widget.
  String? nricDropDownValue;
  FormFieldController<String>? nricDropDownValueController;
  // State field(s) for dateofbird widget.
  FocusNode? dateofbirdFocusNode;
  TextEditingController? dateofbirdTextController;
  String? Function(BuildContext, String?)? dateofbirdTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for drugDropDown widget.
  String? drugDropDownValue;
  FormFieldController<String>? drugDropDownValueController;
  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode3;
  TextEditingController? yournameTextController3;
  String? Function(BuildContext, String?)? yournameTextController3Validator;
  // State field(s) for titleDropDown widget.
  String? titleDropDownValue;
  FormFieldController<String>? titleDropDownValueController;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for foodDropDown widget.
  String? foodDropDownValue;
  FormFieldController<String>? foodDropDownValueController;
  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode4;
  TextEditingController? yournameTextController4;
  String? Function(BuildContext, String?)? yournameTextController4Validator;
  // State field(s) for reffDropDown widget.
  String? reffDropDownValue;
  FormFieldController<String>? reffDropDownValueController;
  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode5;
  TextEditingController? yournameTextController5;
  String? Function(BuildContext, String?)? yournameTextController5Validator;
  // Stores action output result for [Backend Call - API (ceknumberphone)] action in Button-Login widget.
  ApiCallResponse? ceknumber;
  // Stores action output result for [Backend Call - API (Register)] action in Button-Login widget.
  ApiCallResponse? apiResult21w;
  // Stores action output result for [Backend Call - API (Register)] action in Button-Login widget.
  ApiCallResponse? apiResult21;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yournameFocusNode1?.dispose();
    yournameTextController1?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    yournameFocusNode2?.dispose();
    yournameTextController2?.dispose();

    dateofbirdFocusNode?.dispose();
    dateofbirdTextController?.dispose();

    yournameFocusNode3?.dispose();
    yournameTextController3?.dispose();

    yournameFocusNode4?.dispose();
    yournameTextController4?.dispose();

    yournameFocusNode5?.dispose();
    yournameTextController5?.dispose();
  }
}
