import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'homepage_new_widget.dart' show HomepageNewWidget;
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class HomepageNewModel extends FlutterFlowModel<HomepageNewWidget> {
  ApiCallResponse? profileres;
  ApiCallResponse? apiResultg6g;
  int? countNotifnotread;
  ApiCallResponse? apiResultu9n;
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  ApiCallResponse? slidersResponse;
  ApiCallResponse? upcomingApptResponse;
  ApiCallResponse? articlesResponse;

  final _newsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> news({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _newsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearNewsCache() => _newsManager.clear();
  void clearNewsCacheKey(String? uniqueKey) =>
      _newsManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    clearNewsCache();
  }
}
