import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'splash_screen_model.dart';
export 'splash_screen_model.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  static String routeName = 'SplashScreen';
  static String routePath = '/splashScreen';

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  late SplashScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.outputbio = await actions.loadBiometricStatus();
      await actions.getFCM();
      await Future.delayed(
        Duration(
          milliseconds: 3000,
        ),
      );
      if (FFAppState().tokenauth != null && FFAppState().tokenauth != '') {
        if (_model.outputbio! && !kIsWeb) {
          final _localAuth = LocalAuthentication();
          bool _isBiometricSupported = false;
          try {
            _isBiometricSupported = await _localAuth.isDeviceSupported();
          } catch (_) {
            _isBiometricSupported = false;
          }

          if (_isBiometricSupported) {
            try {
              _model.outputbioverif = await _localAuth.authenticate(
                  localizedReason:
                      'Biometric login helps confirm your identity securely. We do not store or access your fingerprint data.');
            } on PlatformException {
              _model.outputbioverif = false;
            }
            safeSetState(() {});
          }

          FFAppState().fingerprint = true;
          safeSetState(() {});
          if (_model.outputbioverif!) {
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
            context.pushNamed(HomepageNewWidget.routeName);
          } else {
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('Unable to Verify'),
                    content: Text(
                        'We couldn\'t verify your identity using biometrics. You can try again or choose manual login instead.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(alertDialogContext),
                        child: Text('Ok'),
                      ),
                    ],
                  ),
                );
              },
            );

            context.pushNamed(LoginPageWidget.routeName);
          }
        } else {
          FFAppState().fingerprint = false;
          safeSetState(() {});
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
          context.pushNamed(HomepageNewWidget.routeName);
        }
      } else {
        context.pushNamed(OnBoardingNewWidget.routeName);
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/ezgif.com-animated-gif-maker.gif',
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 0.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
