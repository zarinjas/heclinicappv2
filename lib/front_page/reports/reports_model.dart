import '/backend/api_requests/api_calls.dart';
import '/component/alert_report/alert_report_widget.dart';
import '/components/confirmdialog_alert_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'reports_widget.dart' show ReportsWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

enum RecordType { note, letter, mc }

enum FilterType { all, notes, letters, mc }

class VitalDataPoint {
  final DateTime timestamp;
  final double value;

  const VitalDataPoint({
    required this.timestamp,
    required this.value,
  });
}

class VitalType {
  final String name;
  final String unit;
  final List<VitalDataPoint> dataPoints;

  const VitalType({
    required this.name,
    required this.unit,
    required this.dataPoints,
  });
}

class HealthRecord {
  final RecordType type;
  final String title;
  final String date;
  final String author;
  final String? detailData;
  final String? kategori;
  final List<String>? diagnosis;

  const HealthRecord({
    required this.type,
    required this.title,
    required this.date,
    required this.author,
    this.detailData,
    this.kategori,
    this.diagnosis,
  });
}

class ReportsModel extends FlutterFlowModel<ReportsWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  Completer<ApiCallResponse>? apiRequestCompleter1;
  Completer<ApiCallResponse>? apiRequestCompleter2;

  // Records tab state
  FilterType selectedFilter = FilterType.all;
  List<HealthRecord> recordsList = [];
  bool isLoading = false;
  String? errorMessage;

  // Vitals tab state
  List<VitalType> vitalsData = [];
  bool isLoadingVitals = false;
  String? vitalsError;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter1?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForApiRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter2?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
