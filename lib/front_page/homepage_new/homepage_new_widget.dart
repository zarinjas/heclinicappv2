import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
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
import 'homepage_new_model.dart';
export 'homepage_new_model.dart';

class HomepageNewWidget extends StatefulWidget {
  const HomepageNewWidget({super.key});

  static String routeName = 'HomepageNew';
  static String routePath = '/homepageNew';

  @override
  State<HomepageNewWidget> createState() => _HomepageNewWidgetState();
}

class _HomepageNewWidgetState extends State<HomepageNewWidget> {
  late HomepageNewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageNewModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.profileres = await MedicalAppsApiGroup.profileCall.call(
        authorization: 'Bearer ${FFAppState().tokenauth}',
        accept: 'application/json',
      );

      await actions.printanything(
        List.generate(
            random_data.randomInteger(5, 5),
            (index) => random_data.randomString(
                  0,
                  0,
                  true,
                  false,
                  false,
                )).toList(),
        MedicalAppsApiGroup.profileCall.idplato(
          (_model.profileres?.jsonBody ?? ''),
        ),
      );
      if ((_model.profileres?.succeeded ?? true)) {
        if (MedicalAppsApiGroup.profileCall.changed(
              (_model.profileres?.jsonBody ?? ''),
            ) !=
            'oke') {
          if (!FFAppState().passwordChanged) {
            var confirmDialogResponse = await showDialog<bool>(
                  context: context,
                  builder: (alertDialogContext) {
                    return WebViewAware(
                      child: AlertDialog(
                        title: Text('Change Password Required'),
                        content: Text(
                            'For your security, please change your password the first time you log in.'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext, true),
                            child: Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                  },
                ) ??
                false;

            context.pushNamed(ChangePasswordWidget.routeName);
          }
        }
      }
      FFAppState().idplato = MedicalAppsApiGroup.profileCall.idplato(
        (_model.profileres?.jsonBody ?? ''),
      )!;
      FFAppState().update(() {});
      _model.apiResultg6g = await GetAppointmentCall.call(
        patientId: MedicalAppsApiGroup.profileCall.idplato(
          (_model.profileres?.jsonBody ?? ''),
        ),
        modifiedSince:
            functions.dateToUnixSeconds(getCurrentTimestamp)?.toString(),
      );

      if ((_model.apiResultg6g?.succeeded ?? true)) {
        if (GetAppointmentCall.start(
                  (_model.apiResultg6g?.jsonBody ?? ''),
                )?.lastOrNull !=
                null &&
            GetAppointmentCall.start(
                  (_model.apiResultg6g?.jsonBody ?? ''),
                )?.lastOrNull !=
                '') {
          FFAppState().name = MedicalAppsApiGroup.profileCall.name(
            (_model.profileres?.jsonBody ?? ''),
          )!;
          safeSetState(() {});
        }
      }

      await FcmRecord.collection
          .doc(MedicalAppsApiGroup.profileCall.idplato(
            (_model.profileres?.jsonBody ?? ''),
          )!)
          .set(createFcmRecordData(
            idPatient: MedicalAppsApiGroup.profileCall.idplato(
              (_model.profileres?.jsonBody ?? ''),
            ),
            fcmToken: FFAppState().fcmtoken,
          ));
      FFAppState().idplato = MedicalAppsApiGroup.profileCall.idplato(
        (_model.profileres?.jsonBody ?? ''),
      )!;
      FFAppState().name = MedicalAppsApiGroup.profileCall.name(
        (_model.profileres?.jsonBody ?? ''),
      )!;
      safeSetState(() {});
      _model.countNotifnotread = await queryHistorynotifRecordCount(
        queryBuilder: (historynotifRecord) => historynotifRecord
            .where(
              'id_patient',
              isEqualTo: FFAppState().idplato,
            )
            .where(
              'read',
              isEqualTo: 'no',
            ),
      );
      FFAppState().coutnnotif = _model.countNotifnotread!.toString();
      FFAppState().update(() {});
      if (FFAppState().fingerprint == true) {
        FFAppState().fingerprint = true;
        safeSetState(() {});
      } else {
        FFAppState().coutnnotif = _model.countNotifnotread!.toString();
        FFAppState().update(() {});
        var confirmDialogResponse = await showDialog<bool>(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('Try Biometric Login'),
                    content: Text(
                        'Enjoy quick and secure access using your fingerprint or face. Tap to enable it now.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, true),
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            false;
        if (confirmDialogResponse) {
          context.pushNamed(BiometricSetupPageWidget.routeName);
        }
      }

      FFAppState().coutnnotif = _model.countNotifnotread!.toString();
      FFAppState().update(() {});
      _model.apiResultu9n = await GetPatientbyidCall.call(
        idpatient: MedicalAppsApiGroup.profileCall.idplato(
          (_model.profileres?.jsonBody ?? ''),
        ),
      );

      if ((_model.apiResultu9n?.succeeded ?? true)) {
        FFAppState().givenid = GetPatientbyidCall.givenid(
          (_model.apiResultu9n?.jsonBody ?? ''),
        )!;
        safeSetState(() {});
      }
    });

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

    return FutureBuilder<ApiCallResponse>(
      future: _model.news(
        requestFn: () => GetAppointmentCall.call(
          patientId: MedicalAppsApiGroup.profileCall.idplato(
            (_model.profileres?.jsonBody ?? ''),
          ),
        ),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Image.asset(
                'assets/images/ezgif.com-animated-gif-maker.gif',
              ),
            ),
          );
        }
        final homepageNewGetAppointmentResponse = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              surfaceTintColor: Colors.transparent,
              leadingWidth: 80,
              leading: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 8, 0, 8),
                child: Image.asset(
                  'assets/images/hemed.png',
                  fit: BoxFit.contain,
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    FFAppState().name,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              actions: [
                badges.Badge(
                  badgeContent: Text(
                    FFAppState().coutnnotif,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: Colors.white,
                          fontSize: 10.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  showBadge: FFAppState().coutnnotif != '0',
                  shape: badges.BadgeShape.circle,
                  badgeColor: Color(0xFFF00106),
                  elevation: 4.0,
                  padding:
                      EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                  position: badges.BadgePosition.topEnd(),
                  animationType: badges.BadgeAnimationType.scale,
                  toAnimate: true,
                  child: FlutterFlowIconButton(
                    borderRadius: 12.0,
                    buttonSize: 44.0,
                    icon: Icon(
                      Icons.notifications_sharp,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                    onPressed: () async {
                      context.pushNamed(NotificationPageWidget.routeName);
                    },
                  ),
                ),
                FlutterFlowIconButton(
                  borderRadius: 12.0,
                  buttonSize: 44.0,
                  icon: Icon(
                    Icons.menu,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 28.0,
                  ),
                  onPressed: () async {
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
              ],
            ),
            endDrawer: Drawer(
              elevation: 16.0,
              child: WebViewAware(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 10.0, 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                if (scaffoldKey.currentState!.isDrawerOpen ||
                                    scaffoldKey.currentState!.isEndDrawerOpen) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Icon(
                                Icons.close_outlined,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/hemed.png',
                              height: 103.88,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 50.0,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: FaIcon(
                                    FontAwesomeIcons.facebookSquare,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://www.facebook.com/hemedclinic/');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: Icon(
                                    Icons.tiktok_rounded,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://www.tiktok.com/@hemedical.clinic');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: FaIcon(
                                    FontAwesomeIcons.instagram,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://www.instagram.com/hemedclinic/');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: FaIcon(
                                    FontAwesomeIcons.youtubeSquare,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://www.youtube.com/@hemedicalclinic');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://api.whatsapp.com/send?phone=60136254528&text=Hello%20He%20Clinic');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: FaIcon(
                                    FontAwesomeIcons.twitter,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await launchURL(
                                        'https://x.com/hemedclinic');
                                  },
                                ),
                              ].divide(SizedBox(width: 0.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(HomepageNewWidget.routeName);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.home,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Home',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                    NotificationPageWidget.routeName);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.notifications_active_sharp,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Notifications',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                    BranchLocationNewCopyWidget.routeName);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.pin_drop_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Branch Location',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  ReportsWidget.routeName,
                                  queryParameters: {
                                    'id': serializeParam(
                                      '',
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.file_copy_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'My Records',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context
                                    .pushNamed(MyBookingPageWidget.routeName);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Book Appointment',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context
                                    .pushNamed(ServicePackageWidget.routeName);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.medical_information,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Services',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  ProfileEditPageWidget.routeName,
                                  queryParameters: {
                                    'avatar': serializeParam(
                                      '',
                                      ParamType.String,
                                    ),
                                    'name': serializeParam(
                                      '',
                                      ParamType.String,
                                    ),
                                    'idplato': serializeParam(
                                      '',
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.settings_sharp,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Settings',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 5.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                var confirmDialogResponse =
                                    await showDialog<bool>(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return WebViewAware(
                                              child: AlertDialog(
                                                title: Text('Warning'),
                                                content: Text(
                                                    'Logging out will end your current session. Proceed?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            alertDialogContext,
                                                            false),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            alertDialogContext,
                                                            true),
                                                    child: Text('Confirm'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ) ??
                                        false;
                                if (confirmDialogResponse) {
                                  await actions.logout();

                                  context.goNamed(
                                    LoginPageWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType:
                                            PageTransitionType.scale,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).error,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 5.0, 16.0, 5.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.logout_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 22.0,
                                            ),
                                            Text(
                                              'Logout',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 17.0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 6.0)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    safeSetState(() {});
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        StreamBuilder<List<HistorynotifRecord>>(
                          stream: queryHistorynotifRecord(
                            queryBuilder: (historynotifRecord) =>
                                historynotifRecord
                                    .where(
                                      'id_patient',
                                      isEqualTo: FFAppState().idplato,
                                    )
                                    .where(
                                      'appointment',
                                      isNotEqualTo: 'no',
                                    ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<HistorynotifRecord>
                                containerHistorynotifRecordList =
                                snapshot.data!;

                            return Container(
                              decoration: BoxDecoration(),
                              child: Visibility(
                                visible: (containerHistorynotifRecordList
                                                .lastOrNull?.appointment !=
                                            null &&
                                        containerHistorynotifRecordList
                                                .lastOrNull?.appointment !=
                                            '') &&
                                    functions.isFutureDateTime(
                                        containerHistorynotifRecordList
                                            .lastOrNull?.appointment)!,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                      MyBookingPageWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.bottomToTop,
                                        ),
                                      },
                                    );
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: 133.48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context).primary,
                                          Color(0xFF013F86)
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(0.0, -1.0),
                                        end: AlignmentDirectional(0, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.bell,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    size: 12.0,
                                                  ),
                                                  Text(
                                                    'Reminder',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color:
                                                              Color(0xFFCECECE),
                                                          fontSize: 13.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 6.0)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Text(
                                                        '${functions.getdayname(containerHistorynotifRecordList.lastOrNull?.appointment)} ${containerHistorynotifRecordList.lastOrNull?.appointment}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .warning,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    'Your Upcoming Appointment ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              if (functions.isOneDayBefore(
                                                      containerHistorynotifRecordList
                                                          .lastOrNull
                                                          ?.appointment) ??
                                                  true)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 5.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              await launchURL(
                                                                  'https://api.whatsapp.com/send/?phone=60136254528&text=Hello%2C+I+would+like+to+confirm+my+appointment.%0A%0AName%3A+${FFAppState().name}%0AIC+Number%3A+${MedicalAppsApiGroup.profileCall.nric(
                                                                (_model.profileres
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )}%0APhone%3A+${MedicalAppsApiGroup.profileCall.nohp(
                                                                (_model.profileres
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )}%0AConfirmed+Date%3A+${containerHistorynotifRecordList.lastOrNull?.appointment}%0A%0AYes%2C+I+confirm+that+I+will+attend+the+appointment.%0A%0AThank+you%21&type=phone_number&app_absent=0');
                                                            },
                                                            text:
                                                                'Confirmation',
                                                            options:
                                                                FFButtonOptions(
                                                              height: 40.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: Color(
                                                                  0xFF09F038),
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: Colors
                                                                            .white,
                                                              fontSize:
                                                                             12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        5.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child:
                                                                FFButtonWidget(
                                                              onPressed:
                                                                  () async {
                                                                context
                                                                    .pushNamed(
                                                                  SelectDateWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'branch':
                                                                        serializeParam(
                                                                      'test',
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                    'isReschedule':
                                                                        serializeParam(
                                                                      true,
                                                                      ParamType
                                                                          .bool,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              },
                                                              text:
                                                                  'Reschedule',
                                                              options:
                                                                  FFButtonOptions(
                                                                height: 40.0,
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        0.0,
                                                                        16.0,
                                                                        0.0),
                                                                iconPadding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                color: Color(
                                                                    0xFFF08009),
                                                                textStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                                elevation: 0.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FlutterFlowIconButton(
                                                borderRadius: 48.0,
                                                buttonSize: 60.0,
                                                fillColor: Colors.white,
                                                icon: FaIcon(
                                                  FontAwesomeIcons
                                                      .calendarCheck,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 34.0,
                                                ),
                                                onPressed: () {
                                                  print(
                                                      'IconButton pressed ...');
                                                },
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(width: 30.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Container(
                              height: 177.0,
                              decoration: BoxDecoration(),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FutureBuilder<ApiCallResponse>(
                                  future: MedicalAppsApiGroup.slidersCall.call(
                                    authorization:
                                        'Bearer ${FFAppState().tokenauth}',
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final pageViewSlidersResponse =
                                        snapshot.data!;

                                    return Builder(
                                      builder: (context) {
                                        final sliders =
                                            MedicalAppsApiGroup.slidersCall
                                                    .image(
                                                      pageViewSlidersResponse
                                                          .jsonBody,
                                                    )
                                                    ?.toList() ??
                                                [];

                                        return Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Stack(
                                            children: [
                                              PageView.builder(
                                                controller: _model
                                                        .pageViewController ??=
                                                    PageController(
                                                        initialPage: max(
                                                            0,
                                                            min(
                                                                0,
                                                                sliders.length -
                                                                    1))),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: sliders.length,
                                                itemBuilder:
                                                    (context, slidersIndex) {
                                                  final slidersItem =
                                                      sliders[slidersIndex];
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          'https://hemedicalapps.com/${MedicalAppsApiGroup.slidersCall.image(
                                                                pageViewSlidersResponse
                                                                    .jsonBody,
                                                              )?.elementAtOrNull(slidersIndex)}',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.7),
                                                child: smooth_page_indicator
                                                    .SmoothPageIndicator(
                                                  controller: _model
                                                          .pageViewController ??=
                                                      PageController(
                                                          initialPage: max(
                                                              0,
                                                              min(
                                                                  0,
                                                                  sliders.length -
                                                                      1))),
                                                  count: sliders.length,
                                                  axisDirection:
                                                      Axis.horizontal,
                                                  onDotClicked: (i) async {
                                                    await _model
                                                        .pageViewController!
                                                        .animateToPage(
                                                      i,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease,
                                                    );
                                                    safeSetState(() {});
                                                  },
                                                  effect: smooth_page_indicator
                                                      .ExpandingDotsEffect(
                                                    expansionFactor: 2.0,
                                                    spacing: 8.0,
                                                    radius: 8.0,
                                                    dotWidth: 6.0,
                                                    dotHeight: 6.0,
                                                    dotColor: Color(0xFFD7D7D7),
                                                    activeDotColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                    paintStyle:
                                                        PaintingStyle.fill,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily:
                                          FlutterFlowTheme.of(context)
                                              .titleSmallFamily,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          ReportsWidget.routeName,
                                          queryParameters: {
                                            'id': serializeParam(
                                              MedicalAppsApiGroup
                                                  .profileCall
                                                  .idplato(
                                                (_model.profileres
                                                        ?.jsonBody ??
                                                    ''),
                                              ),
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF3A8DFF),
                                                  Color(0xFF1E3C72)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Icon(
                                                Icons.file_copy_sharp,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'My Records',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await launchURL(
                                            'https://wa.me/60136254528?text=Reason%20%3A%20Tele%20Consult%0Aname%20:%20${FFAppState().name}%0AIC%20NUMBER%20:%20${MedicalAppsApiGroup.profileCall.nric(
                                          (_model.profileres?.jsonBody ??
                                              ''),
                                        )}%0AID%20Patient%20:%20${FFAppState().givenid}');
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFF08009),
                                                  Color(0xFFCA3B00)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Icon(
                                                Icons.contacts_rounded,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Tele Consult',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            BookingPageWidget.routeName);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF22C1C3),
                                                  Color(0xFF0A7A9F)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Icon(
                                                Icons
                                                    .calendar_month_outlined,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Appointment',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            AllDoctorWidget.routeName);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF33E82F),
                                                  Color(0xFF0D5E0B)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: FaIcon(
                                                FontAwesomeIcons
                                                    .clinicMedical,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Our Doctors',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            ServicePackageWidget
                                                .routeName);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFE7FC9),
                                                  Color(0xFFE53EA5)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Icon(
                                                Icons
                                                    .medical_information,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Services',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await launchURL(
                                            'https://api.whatsapp.com/send?phone=60136254528&text=Hello%20He%20Clinic');
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF22C1C3),
                                                  Color(0xFF2F80ED)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin:
                                                    AlignmentDirectional(
                                                        0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14.0),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: FaIcon(
                                                FontAwesomeIcons
                                                    .commentDots,
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Contact Us',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                    context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Articles',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                      AllArticlePageNewWidget.routeName);
                                },
                                child: Text(
                                  'See All',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 300.0,
                          decoration: BoxDecoration(),
                          child: StreamBuilder<List<ArticlesRecord>>(
                            stream: queryArticlesRecord(
                              queryBuilder: (articlesRecord) =>
                                  articlesRecord.orderBy('timestamp'),
                              limit: 10,
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              List<ArticlesRecord> listViewArticlesRecordList =
                                  snapshot.data!;

                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemCount: listViewArticlesRecordList.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 8.0),
                                itemBuilder: (context, listViewIndex) {
                                  final listViewArticlesRecord =
                                      listViewArticlesRecordList[listViewIndex];
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                        ArticleDetailPageWidget.routeName,
                                        queryParameters: {
                                          'title': serializeParam(
                                            listViewArticlesRecord.title,
                                            ParamType.String,
                                          ),
                                          'imageUrl': serializeParam(
                                            listViewArticlesRecord.imageUrl,
                                            ParamType.String,
                                          ),
                                          'referenceLabel': serializeParam(
                                            listViewArticlesRecord
                                                .referenceLabel,
                                            ParamType.String,
                                          ),
                                          'referenceUrl': serializeParam(
                                            listViewArticlesRecord.referenceUrl,
                                            ParamType.String,
                                          ),
                                          'content': serializeParam(
                                            listViewArticlesRecord.content,
                                            ParamType.String,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                    child: Container(
                                      width: 218.5,
                                      height: 399.4,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      alignment: AlignmentDirectional(0.0, 1.0),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(1.0, 0.0),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional(1.0, -1.0),
                                          children: [
                                            Stack(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 1.0),
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    listViewArticlesRecord
                                                        .imageUrl,
                                                    width: 200.0,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    alignment:
                                                        Alignment(0.0, 0.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0x73122560),
                                                        Color(0xFF122560),
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                      ],
                                                      stops: [0.0, 1.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              -0.34, -1.0),
                                                      end: AlignmentDirectional(
                                                          0.34, 1.0),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(15.0, 0.0, 15.0,
                                                          10.0),
                                                  child: Text(
                                                    listViewArticlesRecord
                                                        .title,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, -1.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 10.0, 15.0, 0.0),
                                                child: Container(
                                                  width: 55.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .warning,
                                                        Color(0xFFA97F03)
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    'He Articles',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          fontSize: 9.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Hemed Info',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(HemedInfoWidget.routeName);
                                },
                                child: Text(
                                  'See All',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<List<InfoRecord>>(
                          stream: queryInfoRecord(
                            limit: 3,
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<InfoRecord> carouselInfoRecordList =
                                snapshot.data!;

                            return Container(
                              width: double.infinity,
                              height: 230.1,
                              child: CarouselSlider.builder(
                                itemCount: carouselInfoRecordList.length,
                                itemBuilder: (context, carouselIndex, _) {
                                  final carouselInfoRecord =
                                      carouselInfoRecordList[carouselIndex];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: Image.network(
                                      carouselInfoRecord.img,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                                carouselController:
                                    _model.carouselController ??=
                                        CarouselSliderController(),
                                options: CarouselOptions(
                                  initialPage: max(
                                      0,
                                      min(1,
                                          carouselInfoRecordList.length - 1)),
                                  viewportFraction: 0.5,
                                  disableCenter: true,
                                  enlargeCenterPage: true,
                                  enlargeFactor: 0.25,
                                  enableInfiniteScroll: true,
                                  scrollDirection: Axis.horizontal,
                                  autoPlay: true,
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  autoPlayInterval:
                                      Duration(milliseconds: (800 + 4000)),
                                  autoPlayCurve: Curves.linear,
                                  pauseAutoPlayInFiniteScroll: true,
                                  onPageChanged: (index, _) =>
                                      _model.carouselCurrentIndex = index,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Content & Media',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                      AllContentMediaWidget.routeName);
                                },
                                child: Text(
                                  'See All',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 300.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: StreamBuilder<List<VideosRecord>>(
                            stream: queryVideosRecord(),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Image.asset(
                                    'assets/images/ezgif.com-animated-gif-maker.gif',
                                  ),
                                );
                              }
                              List<VideosRecord> listViewVideosRecordList =
                                  snapshot.data!;

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemCount: listViewVideosRecordList.length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewVideosRecord =
                                      listViewVideosRecordList[listViewIndex];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10.0, 0.0, 10.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await launchURL(
                                            listViewVideosRecord.videoUrl);
                                      },
                                      child: Container(
                                        width: 200.0,
                                        height: 300.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Container(
                                          width: 200.0,
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  listViewVideosRecord
                                                      .thumbnail,
                                                  width: 200.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Icon(
                                                Icons.play_arrow_sharp,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                size: 74.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
