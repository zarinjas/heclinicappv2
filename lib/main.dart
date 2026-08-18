import 'dart:async';

import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/push_notifications/push_notifications_util.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'backend/api_requests/api_interceptor.dart';
import 'theme/app_theme.dart';

import 'core/services/article_service.dart';
import 'core/services/video_service.dart';
import 'core/services/hero_service.dart';
import 'core/services/doctor_service.dart';
import 'core/services/branch_service.dart';
import 'core/services/package_service.dart';
import 'core/services/promotion_service.dart';
import 'core/services/branding_service.dart';
import 'core/services/onboarding_service.dart';
import 'core/services/telehealth_service.dart';
import 'core/services/legal_service.dart';
import 'core/services/device_token_service.dart';

/// Runs a CMS/branding init in the background and swallows failures — every
/// service falls back to cached/fallback data on its own, so a slow or broken
/// network must never delay the first frame.
Future<void> _safeInit(Future<void> Function() init) async {
  try {
    await init();
  } catch (_) {
    // A failed background init just falls back to cached data.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Never fetch fonts over the network at runtime — all families used by the
  // app (Poppins, Plus Jakarta Sans, Roboto) are bundled in assets/fonts, so
  // the first frame is not blocked waiting on Google Fonts.
  GoogleFonts.config.allowRuntimeFetching = false;
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  // Start initial custom actions code
  await actions.loadLoginData();
  await actions.requestNotificationPermissionsUser();
  await actions.setupFCMForegroundHandler();
  // End initial custom actions code

  final appState = FFAppState();
  await appState.initializePersistedState();

  // Push the current FCM token to the backend for already-logged-in users and
  // keep it in sync when FCM rotates it. Fire-and-forget so it never delays
  // the first frame; the call no-ops when there is no auth token yet.
  DeviceTokenService.instance.register();

  // Load all CMS + branding data in the background so the app renders with
  // cached/fallback content immediately and refreshes in place once the
  // network responds — the first frame must never wait on a fetch.
  for (final init in <Future<void> Function()>[
    BrandingService.instance.init,
    HeroService.instance.init,
    DoctorService.instance.init,
    BranchService.instance.init,
    ArticleService.instance.init,
    VideoService.instance.init,
    PackageService.instance.init,
    PromotionService.instance.init,
    OnboardingService.instance.init,
    TelehealthService.instance.init,
    LegalService.instance.init,
  ]) {
    unawaited(_safeInit(init));
  }

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class _MyAppState extends State<MyApp> {
  // Force light mode. The app follows a white/light brand palette and the dark
  // variant has not been designed against it, so honouring the OS setting made
  // the app render dark for anyone with system dark mode on.
  //
  // The dark ThemeData is still built and passed to MaterialApp, so flipping
  // this back to ThemeMode.system is all that is needed once dark mode has
  // been designed and reviewed.
  ThemeMode _themeMode = ThemeMode.light;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});
  final fcmTokenSub = fcmTokenUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = heClinicFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // Rebuild theme once branding (primary/accent/loading GIF) is loaded.
    BrandingService.instance.onChanged = () {
      if (mounted) safeSetState(() {});
    };
    BrandingService.instance.init().then((_) {
      if (mounted) safeSetState(() {});
    });

    _registerApiInterceptor();
  }

  void _registerApiInterceptor() {
    final interceptor = ApiInterceptor.instance;

    interceptor.onUnauthorized = () {
      FFAppState().isLoggedIn = false;
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ));
        while (appNavigatorKey.currentState?.canPop() == true) {
          appNavigatorKey.currentState?.pop();
        }
        GoRouter.of(context).go('/login');
      }
    };

    interceptor.onServerError = (statusCode, callName) {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Server error. Please try again. (${statusCode})'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Try Again',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ));
      }
    };

    interceptor.onRateLimited = (callName) {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Too many requests, please try again shortly.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
      }
    };

    interceptor.onNetworkError = (message) {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No internet connection — showing last synced data'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
      }
    };
  }

  @override
  void dispose() {
    authUserSub.cancel();
    fcmTokenSub.cancel();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'He Clinic',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: AppTheme.fromBranding(BrandingService.instance.branding),
      darkTheme: AppTheme.fromBranding(BrandingService.instance.branding,
          brightness: Brightness.dark),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'HomepageNew';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'HomepageNew': HomeScreen(),
      'myBookingPage': AppointmentsScreenWidget(),
      'health': HealthScreen(),
      'notificationPage': NotificationsScreen(),
      'Profile': ProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);
    final unreadCount = FFAppState().coutnnotif;
    final primaryColor = BrandingService.instance.primaryColor;
    final accentColor = BrandingService.instance.accentColor;

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: primaryColor,
        selectedItemColor: accentColor,
        unselectedItemColor: const Color(0x80FFFFFF),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 26.0),
            activeIcon: Icon(Icons.home, size: 26.0),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 26.0),
            activeIcon: Icon(Icons.calendar_today, size: 26.0),
            label: 'Appointments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline, size: 26.0),
            activeIcon: Icon(Icons.favorite, size: 26.0),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadCount != '0' && unreadCount.isNotEmpty,
              label: Text(
                unreadCount,
                style: const TextStyle(fontSize: 10.0, color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined, size: 26.0),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadCount != '0' && unreadCount.isNotEmpty,
              label: Text(
                unreadCount,
                style: const TextStyle(fontSize: 10.0, color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications, size: 26.0),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 26.0),
            activeIcon: Icon(Icons.person, size: 26.0),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
