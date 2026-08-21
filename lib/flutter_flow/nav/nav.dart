import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';

import '/auth/base_auth_user_provider.dart';

import '/backend/push_notifications/push_notifications_handler.dart'
    show PushNotificationsHandler;
import '/features/shell/main_shell.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';
import '/pages/booking/branch_selection_screen.dart';
import '/pages/booking/doctor_selection_screen.dart';
import '/pages/booking/date_time_slot_screen.dart';
import '/pages/booking/confirmation_screen.dart';
import '/pages/appointments/appointments_screen.dart';

// New features/auth screens
import '/features/auth/splash_screen.dart';
import '/features/profile/personal_info_screen.dart';
import '/features/auth/onboarding_screen.dart';
import '/features/auth/welcome_screen.dart';
import '/features/auth/login_screen.dart';
import '/features/auth/register_step1_screen.dart';
import '/features/auth/register_step2_screen.dart';
import '/features/auth/register_step3_screen.dart';
import '/features/auth/forgot_email_screen.dart';
import '/features/auth/trouble_signing_in_screen.dart';
import '/features/auth/claim_account_screen.dart';
import '/features/auth/forgot_otp_screen.dart';
import '/features/auth/forgot_newpassword_screen.dart';
import '/features/auth/first_change_password_screen.dart';
import '/features/auth/bind_email_screen.dart';
import '/features/content/articles_list_screen.dart';
import '/features/content/article_detail_screen.dart';
import '/features/content/videos_list_screen.dart';
import '/features/content/packages_screen.dart';
import '/features/content/doctors_list_screen.dart';
import '/features/content/branch_detail_screen.dart';
import '/features/content/telehealth_screen.dart';
import '/features/content/vouchers_list_screen.dart';
import '/features/content/my_vouchers_screen.dart';
import '/features/loyalty/my_points_screen.dart';
import '/features/loyalty/redeem_points_sheet.dart';
import '/features/profile/biometric_screen.dart';
import '/features/profile/clinic_info_screen.dart';
import '/features/profile/privacy_screen.dart';
import '/features/profile/terms_screen.dart';
import '/features/profile/notification_prefs_screen.dart';
import '/features/profile/about_screen.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => (user?.loggedIn ?? false) || FFAppState().isLoggedIn;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser? newUser) {
    if (newUser == null) return;
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? const MainShell() : const SplashScreen(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? const MainShell() : const SplashScreen(),
        ),
        // Legacy article route kept as a push-notification target.
        FFRoute(
          name: 'ArticleDetailPage',
          path: '/articleDetailPage',
          builder: (context, params) => ArticleDetailScreen(
            articleTitle: params.getParam('title', ParamType.String),
            articleSlug: params.getParam('slug', ParamType.String),
          ),
        ),
        // Legacy FlutterFlow booking route. The old screen is gone; both the
        // saved links and push notifications now land on the Visits tab.
        FFRoute(
          name: 'bookingPage',
          path: '/bookingPage',
          builder: (context, params) =>
              const MainShell(initialTab: 'myBookingPage'),
        ),
        // Legacy date-picker route; the booking flow now lives in
        // lib/pages/booking/. Send stale links to the branch step.
        FFRoute(
          name: 'SelectDate',
          path: '/selectDate',
          builder: (context, params) => const BranchSelectionScreenWidget(),
        ),
        FFRoute(
          name: AppointmentsScreenWidget.routeName,
          path: AppointmentsScreenWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const MainShell(initialTab: 'myBookingPage')
              : const AppointmentsScreenWidget(),
        ),
        FFRoute(
          name: QueueTrackerScreenWidget.routeName,
          path: QueueTrackerScreenWidget.routePath,
          builder: (context, params) => const QueueTrackerScreenWidget(),
        ),
        FFRoute(
          name: PaymentHistoryScreenWidget.routeName,
          path: PaymentHistoryScreenWidget.routePath,
          builder: (context, params) => const PaymentHistoryScreenWidget(),
        ),


        FFRoute(
          name: SplashScreen.legacyRouteName,
          path: SplashScreen.legacyRoutePath,
          builder: (context, params) => const SplashScreen(),
        ),
        FFRoute(
          name: 'allDoctor',
          path: '/allDoctor',
          builder: (context, params) => const DoctorsListScreen(),
        ),
        FFRoute(
          name: 'servicePackage',
          path: '/servicePackage',
          builder: (context, params) => const PackagesScreen(),
        ),
        FFRoute(
          name: ChangePasswordWidget.routeName,
          path: ChangePasswordWidget.routePath,
          builder: (context, params) => ChangePasswordWidget(),
        ),
        FFRoute(
          name: ReportsWidget.routeName,
          path: ReportsWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const MainShell(initialTab: 'health')
              : ReportsWidget(
                  id: params.getParam(
                    'id',
                    ParamType.String,
                  ),
                ),
        ),
        // Legacy FlutterFlow home route, kept as a push-notification target.
        FFRoute(
          name: 'HomepageNew',
          path: '/homepageNew',
          builder: (context, params) =>
              const MainShell(initialTab: 'HomepageNew'),
        ),
        FFRoute(
          name: 'allArticlePageNew',
          path: '/allArticlePageNew',
          builder: (context, params) => const ArticlesListScreen(),
        ),
        FFRoute(
          name: 'allContentMedia',
          path: '/allContentMedia',
          builder: (context, params) => const VideosListScreen(),
        ),
        FFRoute(
          name: HemedInfoWidget.routeName,
          path: HemedInfoWidget.routePath,
          builder: (context, params) => HemedInfoWidget(),
        ),
        FFRoute(
          name: PersonalInfoScreen.routeName,
          path: PersonalInfoScreen.routePath,
          builder: (context, params) => const PersonalInfoScreen(),
        ),
        // The old FlutterFlow /profileEditPage path is kept so saved links and
        // any lingering deep links land on the rewritten screen.
        FFRoute(
          name: 'ProfileEditPage',
          path: '/profileEditPage',
          builder: (context, params) => const PersonalInfoScreen(),
        ),
        FFRoute(
          name: 'branchLocationNewCopy',
          path: '/branchLocationNewCopy',
          builder: (context, params) => const ClinicInfoScreen(),
        ),
        FFRoute(
          name: 'notificationPage',
          path: '/notificationPage',
          builder: (context, params) =>
              const MainShell(initialTab: 'notificationPage'),
        ),
        // 'Visits' is a documented push-notification target. The old widget
        // was unreachable in-app; send it to the Visits tab instead.
        // Legacy push-notification targets from the FlutterFlow build. Their
        // screens are gone, so each maps to its current equivalent. Without
        // these, a push using an old name throws on navigation.
        FFRoute(
          name: 'LoginPage',
          path: '/loginPage',
          builder: (context, params) => const LoginScreen(),
        ),
        FFRoute(
          name: 'RegisterPage',
          path: '/registerPage',
          builder: (context, params) => const RegisterStep1Screen(),
        ),
        FFRoute(
          name: 'ForgotPassword',
          path: '/forgotPassword',
          builder: (context, params) => const ForgotEmailScreen(),
        ),
        FFRoute(
          name: 'onBoarding',
          path: '/onBoardingLegacy',
          builder: (context, params) => const OnboardingScreen(),
        ),
        FFRoute(
          name: 'onBoardingNew',
          path: '/onBoardingNew',
          builder: (context, params) => const OnboardingScreen(),
        ),
        FFRoute(
          name: 'Visits',
          path: '/visits',
          builder: (context, params) =>
              const MainShell(initialTab: 'myBookingPage'),
        ),
        // Legacy biometric route; the FlutterFlow setup page is gone. Kept as
        // a push-notification target, pointing at the new BiometricScreen.
        FFRoute(
          name: 'BiometricSetupPage',
          path: '/biometricSetupPage',
          builder: (context, params) => const BiometricScreen(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const MainShell(initialTab: 'Profile')
              : ProfileWidget(),
        ),
        FFRoute(
          name: 'hemedInfoCopy',
          path: '/hemedInfoCopy',
          builder: (context, params) => const ClinicInfoScreen(),
        ),
        FFRoute(
          name: BranchSelectionScreenWidget.routeName,
          path: BranchSelectionScreenWidget.routePath,
          builder: (context, params) => const BranchSelectionScreenWidget(),
        ),
        FFRoute(
          name: DoctorSelectionScreenWidget.routeName,
          path: DoctorSelectionScreenWidget.routePath,
          builder: (context, params) => const DoctorSelectionScreenWidget(),
        ),
        FFRoute(
          name: DateTimeSlotSelectionScreenWidget.routeName,
          path: DateTimeSlotSelectionScreenWidget.routePath,
          builder: (context, params) =>
              const DateTimeSlotSelectionScreenWidget(),
        ),
        FFRoute(
          name: BookingConfirmationScreenWidget.routeName,
          path: BookingConfirmationScreenWidget.routePath,
          builder: (context, params) =>
              const BookingConfirmationScreenWidget(),
        ),

        // ── New features/auth routes ────────────────────────────────────────
        FFRoute(
          name: SplashScreen.routeName,
          path: SplashScreen.routePath,
          builder: (context, params) => const SplashScreen(),
        ),
        FFRoute(
          name: OnboardingScreen.routeName,
          path: OnboardingScreen.routePath,
          builder: (context, params) => const OnboardingScreen(),
        ),
        FFRoute(
          name: WelcomeScreen.routeName,
          path: WelcomeScreen.routePath,
          builder: (context, params) => const WelcomeScreen(),
        ),
        FFRoute(
          name: LoginScreen.routeName,
          path: LoginScreen.routePath,
          builder: (context, params) => const LoginScreen(),
        ),
        FFRoute(
          name: RegisterStep1Screen.routeName,
          path: RegisterStep1Screen.routePath,
          builder: (context, params) => const RegisterStep1Screen(),
        ),
        FFRoute(
          name: RegisterStep2Screen.routeName,
          path: RegisterStep2Screen.routePath,
          builder: (context, params) => const RegisterStep2Screen(),
        ),
        FFRoute(
          name: RegisterStep3Screen.routeName,
          path: RegisterStep3Screen.routePath,
          builder: (context, params) => const RegisterStep3Screen(),
        ),
        FFRoute(
          name: ForgotEmailScreen.routeName,
          path: ForgotEmailScreen.routePath,
          builder: (context, params) => const ForgotEmailScreen(),
        ),
        FFRoute(
          name: TroubleSigningInScreen.routeName,
          path: TroubleSigningInScreen.routePath,
          builder: (context, params) => const TroubleSigningInScreen(),
        ),
        FFRoute(
          name: ClaimAccountScreen.routeName,
          path: ClaimAccountScreen.routePath,
          builder: (context, params) => const ClaimAccountScreen(),
        ),
        FFRoute(
          name: ForgotOtpScreen.routeName,
          path: ForgotOtpScreen.routePath,
          builder: (context, params) => const ForgotOtpScreen(),
        ),
        FFRoute(
          name: ForgotNewpasswordScreen.routeName,
          path: ForgotNewpasswordScreen.routePath,
          builder: (context, params) => const ForgotNewpasswordScreen(),
        ),
        FFRoute(
          name: FirstChangePasswordScreen.routeName,
          path: FirstChangePasswordScreen.routePath,
          builder: (context, params) => const FirstChangePasswordScreen(),
        ),
        FFRoute(
          name: BindEmailScreen.routeName,
          path: BindEmailScreen.routePath,
          builder: (context, params) => const BindEmailScreen(),
        ),

        // ── Content screens ──────────────────────────────────────────────
        FFRoute(
          name: '/articlesList',
          path: '/articlesList',
          builder: (context, params) => const ArticlesListScreen(),
        ),
        FFRoute(
          name: '/articleDetail',
          path: '/articleDetail',
          builder: (context, params) => ArticleDetailScreen(
            articleSlug: params.getParam('articleSlug', ParamType.String) as String?,
          ),
        ),
        FFRoute(
          name: '/videosList',
          path: '/videosList',
          builder: (context, params) => const VideosListScreen(),
        ),
        FFRoute(
          name: '/packages',
          path: '/packages',
          builder: (context, params) => const PackagesScreen(),
        ),
        FFRoute(
          name: '/doctors-list',
          path: '/doctors-list',
          builder: (context, params) => const DoctorsListScreen(),
        ),
        FFRoute(
          name: '/branch-detail',
          path: '/branch-detail',
          builder: (context, params) => const BranchDetailScreen(),
        ),
        FFRoute(
          name: '/telehealth',
          path: '/telehealth',
          builder: (context, params) => const TelehealthScreen(),
        ),
        FFRoute(
          name: '/vouchers',
          path: '/vouchers',
          builder: (context, params) => const VouchersListScreen(),
        ),
        FFRoute(
          name: '/my-vouchers',
          path: '/my-vouchers',
          builder: (context, params) => const MyVouchersScreen(),
        ),
        FFRoute(
          name: '/my-points',
          path: '/my-points',
          builder: (context, params) => const MyPointsScreen(),
        ),
        FFRoute(
          name: BiometricScreen.routeName,
          path: BiometricScreen.routePath,
          builder: (context, params) => const BiometricScreen(),
        ),
        FFRoute(
          name: '/clinic-info',
          path: '/clinic-info',
          builder: (context, params) => const ClinicInfoScreen(),
        ),
        FFRoute(
          name: '/privacy',
          path: '/privacy',
          builder: (context, params) => const PrivacyScreen(),
        ),
        FFRoute(
          name: '/terms',
          path: '/terms',
          builder: (context, params) => const TermsScreen(),
        ),
        FFRoute(
          name: NotificationPrefsScreen.routeName,
          path: NotificationPrefsScreen.routePath,
          builder: (context, params) => const NotificationPrefsScreen(),
        ),
        FFRoute(
          name: AboutScreen.routeName,
          path: AboutScreen.routePath,
          builder: (context, params) => const AboutScreen(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splashScreen';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : PushNotificationsHandler(child: page);

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
