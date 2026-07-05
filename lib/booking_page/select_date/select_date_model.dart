import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'select_date_widget.dart' show SelectDateWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectDateModel extends FlutterFlowModel<SelectDateWidget> {
  DateTimeRange? calendarSelectedDay;
  DateTime? datePicked;

  FocusNode? reasonFocusNode;
  TextEditingController? reasonTextController;
  String? Function(BuildContext, String?)? reasonTextControllerValidator;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {
    reasonFocusNode?.dispose();
    reasonTextController?.dispose();
  }
}
