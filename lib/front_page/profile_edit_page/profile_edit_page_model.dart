import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'profile_edit_page_widget.dart' show ProfileEditPageWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ProfileEditPageModel extends FlutterFlowModel<ProfileEditPageWidget> {
  ///  Local state fields for this page.

  String? img;

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataIej = false;
  FFUploadedFile uploadedLocalFile_uploadDataIej =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Backend Call - API (UpdateProfil)] action in CircleImage widget.
  ApiCallResponse? apiResultjy2;
  // State field(s) for yourname widget.
  FocusNode? yournameFocusNode;
  TextEditingController? yournameTextController;
  String? Function(BuildContext, String?)? yournameTextControllerValidator;
  // State field(s) for address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;
  // State field(s) for dob widget.
  FocusNode? dobFocusNode;
  TextEditingController? dobTextController;
  String? Function(BuildContext, String?)? dobTextControllerValidator;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (UpdateProfil)] action in Button-Login widget.
  ApiCallResponse? apiResultsbl;
  // Stores action output result for [Backend Call - API (EditPatiend)] action in Button-Login widget.
  ApiCallResponse? apiResultzu5;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yournameFocusNode?.dispose();
    yournameTextController?.dispose();

    addressFocusNode?.dispose();
    addressTextController?.dispose();

    dobFocusNode?.dispose();
    dobTextController?.dispose();
  }
}
