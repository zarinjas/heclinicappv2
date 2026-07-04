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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'reports_model.dart';
export 'reports_model.dart';

class ReportsWidget extends StatefulWidget {
  const ReportsWidget({
    super.key,
    required this.id,
  });

  final String? id;

  static String routeName = 'Reports';
  static String routePath = '/reports';

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget>
    with TickerProviderStateMixin {
  late ReportsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportsModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          title: Text(
            'My Records',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 3.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment(0.0, 0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: FlutterFlowTheme.of(context).primaryText,
                        unselectedLabelColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        labelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleMediumIsCustom,
                                ),
                        unselectedLabelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleMediumIsCustom,
                                ),
                        indicatorColor: FlutterFlowTheme.of(context).primary,
                        tabs: [
                          Tab(
                            text: 'Visit',
                          ),
                          Tab(
                            text: 'My Labs',
                          ),
                          Tab(
                            text: 'My Documents',
                          ),
                        ],
                        controller: _model.tabBarController,
                        onTap: (i) async {
                          [() async {}, () async {}, () async {}][i]();
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _model.tabBarController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 10.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: LetterCopyCall.call(
                                patientId: FFAppState().idplato,
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Image.asset(
                                      'assets/images/output-onlinegiftools.gif',
                                    ),
                                  );
                                }
                                final listViewLetterCopyResponse =
                                    snapshot.data!;

                                return Builder(
                                  builder: (context) {
                                    final visitlist = LetterCopyCall.itemname(
                                          listViewLetterCopyResponse.jsonBody,
                                        )?.toList() ??
                                        [];

                                    return RefreshIndicator(
                                      onRefresh: () async {
                                        FFAppState().update(() {});
                                      },
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: visitlist.length,
                                        itemBuilder: (context, visitlistIndex) {
                                          final visitlistItem =
                                              visitlist[visitlistIndex];
                                          return Visibility(
                                            visible: (LetterCopyCall.inventori(
                                                  listViewLetterCopyResponse
                                                      .jsonBody,
                                                )?.elementAtOrNull(
                                                    visitlistIndex)) ==
                                                'package',
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 10.0, 0.0, 10.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 4.0,
                                                      color: Color(0x33000000),
                                                      offset: Offset(
                                                        0.0,
                                                        2.0,
                                                      ),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(10.0, 10.0,
                                                          10.0, 10.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  AutoSizeText(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      LetterCopyCall
                                                                          .itemname(
                                                                        listViewLetterCopyResponse
                                                                            .jsonBody,
                                                                      )?.elementAtOrNull(
                                                                          visitlistIndex),
                                                                      'Item name',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleMediumFamily,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(
                                                                thickness: 2.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child:
                                                                        FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        context
                                                                            .pushNamed(
                                                                          BookingPagecasseWidget
                                                                              .routeName,
                                                                          queryParameters:
                                                                              {
                                                                            'cas':
                                                                                serializeParam(
                                                                              LetterCopyCall.itemname(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )?.elementAtOrNull(visitlistIndex),
                                                                              ParamType.String,
                                                                            ),
                                                                          }.withoutNulls,
                                                                        );
                                                                      },
                                                                      text:
                                                                          'Book Appointment',
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            40.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              color: Colors.white,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        'Remaining Sessions : ',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          functions.countMatchingGivenId(
                                                                              LetterCopyCall.otherpackage(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .toList(),
                                                                              (LetterCopyCall.givenid(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .elementAtOrNull(visitlistIndex))!,
                                                                              LetterCopyCall.givenid(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .toList(),
                                                                              LetterCopyCall.kategori(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .toList(),
                                                                              LetterCopyCall.redemptions(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .toList(),
                                                                              LetterCopyCall.idlist(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .toList(),
                                                                              (LetterCopyCall.idlist(
                                                                                listViewLetterCopyResponse.jsonBody,
                                                                              )!
                                                                                  .elementAtOrNull(visitlistIndex))!),
                                                                          '0',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ].divide(SizedBox(
                                                                height: 4.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          FutureBuilder<ApiCallResponse>(
                            future: (_model.apiRequestCompleter1 ??=
                                    Completer<ApiCallResponse>()
                                      ..complete(GetReportCall.call(
                                        patientId: widget!.id,
                                      )))
                                .future,
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Image.asset(
                                    'assets/images/output-onlinegiftools.gif',
                                  ),
                                );
                              }
                              final columnGetReportResponse = snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final note = GetReportCall.note(
                                        columnGetReportResponse.jsonBody,
                                      )?.toList() ??
                                      [];

                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      safeSetState(() =>
                                          _model.apiRequestCompleter1 = null);
                                      await _model
                                          .waitForApiRequestCompleted1();
                                    },
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(note.length,
                                            (noteIndex) {
                                          final noteItem = note[noteIndex];
                                          return Visibility(
                                            visible: ((GetReportCall.kategori(
                                                      columnGetReportResponse
                                                          .jsonBody,
                                                    )?.elementAtOrNull(
                                                        noteIndex)) ==
                                                    'Labs') &&
                                                ((GetReportCall.trash(
                                                      columnGetReportResponse
                                                          .jsonBody,
                                                    )?.elementAtOrNull(
                                                        noteIndex)) !=
                                                    1) &&
                                                (functions.flattenOrPickAttachment(
                                                            GetReportCall
                                                                .attachment(
                                                          columnGetReportResponse
                                                              .jsonBody,
                                                        )?.elementAtOrNull(
                                                                noteIndex)) !=
                                                        null &&
                                                    functions.flattenOrPickAttachment(
                                                            GetReportCall
                                                                .attachment(
                                                          columnGetReportResponse
                                                              .jsonBody,
                                                        )?.elementAtOrNull(
                                                                noteIndex)) !=
                                                        ''),
                                            child: Builder(
                                              builder: (context) => Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 10.0, 0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    if (functions.flattenOrPickAttachment(
                                                                GetReportCall
                                                                    .attachment(
                                                              columnGetReportResponse
                                                                  .jsonBody,
                                                            )?.elementAtOrNull(
                                                                    noteIndex)) !=
                                                            null &&
                                                        functions.flattenOrPickAttachment(
                                                                GetReportCall
                                                                    .attachment(
                                                              columnGetReportResponse
                                                                  .jsonBody,
                                                            )?.elementAtOrNull(
                                                                    noteIndex)) !=
                                                            '') {
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child: WebViewAware(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          dialogContext)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child:
                                                                    ConfirmdialogAlertWidget(
                                                                  linkurl: functions.flattenOrPickAttachment(
                                                                      GetReportCall
                                                                          .attachment(
                                                                    columnGetReportResponse
                                                                        .jsonBody,
                                                                  )?.elementAtOrNull(
                                                                          noteIndex)),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child: WebViewAware(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          dialogContext)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 500.0,
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width *
                                                                      0.8,
                                                                  child:
                                                                      AlertReportWidget(
                                                                    author: (GetReportCall
                                                                            .author(
                                                                      columnGetReportResponse
                                                                          .jsonBody,
                                                                    )!
                                                                        .elementAtOrNull(
                                                                            noteIndex))!,
                                                                    time: (GetReportCall
                                                                            .time(
                                                                      columnGetReportResponse
                                                                          .jsonBody,
                                                                    )!
                                                                        .elementAtOrNull(
                                                                            noteIndex))!,
                                                                    note: (GetReportCall
                                                                            .note(
                                                                      columnGetReportResponse
                                                                          .jsonBody,
                                                                    )!
                                                                        .elementAtOrNull(
                                                                            noteIndex))!,
                                                                    kategori: (GetReportCall
                                                                            .kategori(
                                                                      columnGetReportResponse
                                                                          .jsonBody,
                                                                    )!
                                                                        .elementAtOrNull(
                                                                            noteIndex))!,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: ListTile(
                                                      title: Text(
                                                        functions.getnamepdf(functions
                                                            .flattenOrPickAttachment(
                                                                GetReportCall
                                                                    .attachment(
                                                          columnGetReportResponse
                                                              .jsonBody,
                                                        )?.elementAtOrNull(
                                                                    noteIndex))!),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleLargeFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleLargeIsCustom,
                                                                ),
                                                      ),
                                                      subtitle: Text(
                                                        (GetReportCall.time(
                                                          columnGetReportResponse
                                                              .jsonBody,
                                                        )!
                                                            .elementAtOrNull(
                                                                noteIndex))!,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMediumIsCustom,
                                                                ),
                                                      ),
                                                      trailing: Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 24.0,
                                                      ),
                                                      tileColor: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      dense: false,
                                                      contentPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  0.0,
                                                                  12.0,
                                                                  0.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          FutureBuilder<ApiCallResponse>(
                            future: (_model.apiRequestCompleter2 ??=
                                    Completer<ApiCallResponse>()
                                      ..complete(GetReportCall.call(
                                        patientId: widget!.id,
                                      )))
                                .future,
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Image.asset(
                                    'assets/images/output-onlinegiftools.gif',
                                  ),
                                );
                              }
                              final listViewGetReportResponse = snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final note = GetReportCall.author(
                                        listViewGetReportResponse.jsonBody,
                                      )?.toList() ??
                                      [];

                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      safeSetState(() =>
                                          _model.apiRequestCompleter2 = null);
                                      await _model
                                          .waitForApiRequestCompleted2();
                                    },
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: note.length,
                                      itemBuilder: (context, noteIndex) {
                                        final noteItem = note[noteIndex];
                                        return Visibility(
                                          visible: ((GetReportCall.kategori(
                                                    listViewGetReportResponse
                                                        .jsonBody,
                                                  )?.elementAtOrNull(
                                                      noteIndex)) ==
                                                  'Radiology') &&
                                              ((GetReportCall.trash(
                                                    listViewGetReportResponse
                                                        .jsonBody,
                                                  )?.elementAtOrNull(
                                                      noteIndex)) !=
                                                  1) &&
                                              (functions.flattenOrPickAttachment(
                                                          GetReportCall
                                                              .attachment(
                                                        listViewGetReportResponse
                                                            .jsonBody,
                                                      )?.elementAtOrNull(
                                                              noteIndex)) !=
                                                      null &&
                                                  functions
                                                          .flattenOrPickAttachment(
                                                              GetReportCall
                                                                  .attachment(
                                                        listViewGetReportResponse
                                                            .jsonBody,
                                                      )?.elementAtOrNull(
                                                                  noteIndex)) !=
                                                      ''),
                                          child: Builder(
                                            builder: (context) => Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 10.0, 0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  if (functions.flattenOrPickAttachment(
                                                              GetReportCall
                                                                  .attachment(
                                                            listViewGetReportResponse
                                                                .jsonBody,
                                                          )?.elementAtOrNull(
                                                                  noteIndex)) !=
                                                          null &&
                                                      functions.flattenOrPickAttachment(
                                                              GetReportCall
                                                                  .attachment(
                                                            listViewGetReportResponse
                                                                .jsonBody,
                                                          )?.elementAtOrNull(
                                                                  noteIndex)) !=
                                                          '') {
                                                    var confirmDialogResponse =
                                                        await showDialog<bool>(
                                                              context: context,
                                                              builder:
                                                                  (alertDialogContext) {
                                                                return WebViewAware(
                                                                  child:
                                                                      AlertDialog(
                                                                    title: Text(
                                                                        'Your documents are now available.'),
                                                                    content: Text(
                                                                        'You can view this documents or book an appointment for further consultation.'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            false),
                                                                        child: Text(
                                                                            'View Documents'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            true),
                                                                        child: Text(
                                                                            'Appointment Booking'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) ??
                                                            false;
                                                    if (confirmDialogResponse) {
                                                      context.pushNamed(
                                                        BookingPagecasseWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'cas': serializeParam(
                                                            'My Radiologi',
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    } else {
                                                      await launchURL(functions
                                                          .flattenOrPickAttachment(
                                                              GetReportCall
                                                                  .attachment(
                                                        listViewGetReportResponse
                                                            .jsonBody,
                                                      )?.elementAtOrNull(
                                                                  noteIndex))!);
                                                    }
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child: WebViewAware(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        dialogContext)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child: Container(
                                                                height: 500.0,
                                                                width: MediaQuery.sizeOf(
                                                                            context)
                                                                        .width *
                                                                    0.8,
                                                                child:
                                                                    AlertReportWidget(
                                                                  author: (GetReportCall
                                                                          .author(
                                                                    listViewGetReportResponse
                                                                        .jsonBody,
                                                                  )!
                                                                      .elementAtOrNull(
                                                                          noteIndex))!,
                                                                  time: (GetReportCall
                                                                          .time(
                                                                    listViewGetReportResponse
                                                                        .jsonBody,
                                                                  )!
                                                                      .elementAtOrNull(
                                                                          noteIndex))!,
                                                                  note: (GetReportCall
                                                                          .note(
                                                                    listViewGetReportResponse
                                                                        .jsonBody,
                                                                  )!
                                                                      .elementAtOrNull(
                                                                          noteIndex))!,
                                                                  kategori: (GetReportCall
                                                                          .kategori(
                                                                    listViewGetReportResponse
                                                                        .jsonBody,
                                                                  )!
                                                                      .elementAtOrNull(
                                                                          noteIndex))!,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: ListTile(
                                                    title: Text(
                                                      functions.getnamepdf(functions
                                                          .flattenOrPickAttachment(
                                                              GetReportCall
                                                                  .attachment(
                                                        listViewGetReportResponse
                                                            .jsonBody,
                                                      )?.elementAtOrNull(
                                                                  noteIndex))!),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleLarge
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLargeFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLargeIsCustom,
                                                          ),
                                                    ),
                                                    subtitle: Text(
                                                      (GetReportCall.time(
                                                        listViewGetReportResponse
                                                            .jsonBody,
                                                      )!
                                                          .elementAtOrNull(
                                                              noteIndex))!,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumIsCustom,
                                                          ),
                                                    ),
                                                    trailing: Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 24.0,
                                                    ),
                                                    tileColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                    dense: false,
                                                    contentPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(12.0, 0.0,
                                                                12.0, 0.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
