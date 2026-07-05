import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/theme/app_theme.dart';
import '/components/doctor_list_widget.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
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
  Timer? _sliderTimer;

  bool _profileLoaded = false;
  bool _slidersLoaded = false;
  bool _upcomingLoaded = false;
  bool _articlesLoaded = false;

  bool _slidersError = false;
  bool _upcomingError = false;
  bool _articlesError = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageNewModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await _loadProfile();
    await Future.wait([
      _loadSliders(),
      _loadUpcomingAppointment(),
      _loadArticles(),
    ]);
    if (mounted) safeSetState(() {});
  }

  Future<void> _loadProfile() async {
    _model.profileres = await MedicalAppsApiGroup.profileCall.call(
      authorization: 'Bearer ${FFAppState().tokenauth}',
      accept: 'application/json',
    );

    if (_model.profileres?.succeeded ?? false) {
      if (MedicalAppsApiGroup.profileCall.changed(
            (_model.profileres?.jsonBody ?? ''),
          ) !=
          'oke') {
        if (!FFAppState().passwordChanged) {
          if (mounted) {
            final confirmDialogResponse = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => WebViewAware(
                    child: AlertDialog(
                      title: const Text('Change Password Required'),
                      content: const Text(
                          'For your security, please change your password the first time you log in.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ),
                ) ??
                false;
            if (confirmDialogResponse && mounted) {
              context.pushNamed(ChangePasswordWidget.routeName);
            }
          }
        }
      }
    }

    final idplato = MedicalAppsApiGroup.profileCall.idplato(
      (_model.profileres?.jsonBody ?? ''),
    ) ?? '';

    FFAppState().idplato = idplato;
    FFAppState().update(() {});

    _model.apiResultg6g = await GetAppointmentCall.call(
      patientId: idplato,
    );

    FFAppState().name = MedicalAppsApiGroup.profileCall.name(
      (_model.profileres?.jsonBody ?? ''),
    ) ?? '';
    safeSetState(() {});

    await FcmRecord.collection.doc(idplato).set(createFcmRecordData(
      idPatient: idplato,
      fcmToken: FFAppState().fcmtoken,
    ));

    FFAppState().idplato = idplato;
    FFAppState().name = MedicalAppsApiGroup.profileCall.name(
      (_model.profileres?.jsonBody ?? ''),
    ) ?? '';
    safeSetState(() {});

    _model.countNotifnotread = await queryHistorynotifRecordCount(
      queryBuilder: (r) => r
          .where('id_patient', isEqualTo: idplato)
          .where('read', isEqualTo: 'no'),
    );
    FFAppState().coutnnotif = _model.countNotifnotread?.toString() ?? '0';
    FFAppState().update(() {});

    if (FFAppState().fingerprint != true && mounted) {
      final confirmDialogResponse = await showDialog<bool>(
            context: context,
            builder: (ctx) => WebViewAware(
              child: AlertDialog(
                title: const Text('Try Biometric Login'),
                content: const Text(
                    'Enjoy quick and secure access using your fingerprint or face. Tap to enable it now.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ) ??
          false;
      if (confirmDialogResponse && mounted) {
        context.pushNamed(BiometricSetupPageWidget.routeName);
      }
    }

    FFAppState().coutnnotif = _model.countNotifnotread?.toString() ?? '0';
    FFAppState().update(() {});

    _model.apiResultu9n = await GetPatientbyidCall.call(idpatient: idplato);
    if (_model.apiResultu9n?.succeeded ?? false) {
      FFAppState().givenid = GetPatientbyidCall.givenid(
        (_model.apiResultu9n?.jsonBody ?? ''),
      ) ?? '';
      safeSetState(() {});
    }

    if (mounted) {
      setState(() => _profileLoaded = true);
    }
  }

  Future<void> _loadSliders() async {
    try {
      _model.slidersResponse = await MedicalAppsApiGroup.slidersCall.call(
        authorization: 'Bearer ${FFAppState().tokenauth}',
      );
      if (mounted) {
        setState(() {
          _slidersLoaded = true;
          _slidersError = !(_model.slidersResponse?.succeeded ?? false);
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _slidersLoaded = true;
        _slidersError = true;
      });
    }
  }

  Future<void> _loadUpcomingAppointment() async {
    try {
      _model.upcomingApptResponse = await GetAppointmentUpcomingCall.call(
        patientId: MedicalAppsApiGroup.profileCall.idplato(
          (_model.profileres?.jsonBody ?? ''),
        ),
      );
      if (mounted) {
        setState(() {
          _upcomingLoaded = true;
          _upcomingError = !(_model.upcomingApptResponse?.succeeded ?? false);
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _upcomingLoaded = true;
        _upcomingError = true;
      });
    }
  }

  Future<void> _loadArticles() async {
    try {
      _model.articlesResponse = await GetCmsArticlesCall.call(limit: 4);
      if (mounted) {
        setState(() {
          _articlesLoaded = true;
          _articlesError = !(_model.articlesResponse?.succeeded ?? false);
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _articlesLoaded = true;
        _articlesError = true;
      });
    }
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => await _loadInitialData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                _buildHeroSlider(),
                _buildQuickActions(),
                _buildLoyaltyPoints(),
                _buildUpcomingAppointment(),
                _buildOurDoctors(),
                _buildHealthTips(),
                _buildVideos(),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = FlutterFlowTheme.of(context);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 0.0, 8.0),
        child: Image.asset(
          'assets/images/hemed.png',
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4.0),
          child: badges.Badge(
            badgeContent: Text(
              FFAppState().coutnnotif,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: Colors.white,
                fontSize: 10.0,
                letterSpacing: 0.0,
              ),
            ),
            showBadge: FFAppState().coutnnotif != '0',
            shape: badges.BadgeShape.circle,
            badgeColor: AppColors.error,
            elevation: 4.0,
            padding: const EdgeInsetsDirectional.all(6.0),
            position: badges.BadgePosition.topEnd(),
            animationType: badges.BadgeAnimationType.scale,
            toAnimate: true,
            child: FlutterFlowIconButton(
              borderRadius: 12.0,
              buttonSize: 44.0,
              icon: Icon(
                Icons.notifications_sharp,
                color: theme.primary,
                size: 26.0,
              ),
              onPressed: () {
                context.pushNamed(NotificationPageWidget.routeName);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final theme = FlutterFlowTheme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 12.0),
      child: Text(
        '$greeting, ${FFAppState().name}',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeroSlider() {
    if (!_slidersLoaded) {
      return _buildHeroSkeleton();
    }

    if (_slidersError || !_model.slidersResponse!.succeeded) {
      return _buildSectionError('Hero slider', _loadSliders, height: 180.0);
    }

    final sliders = MedicalAppsApiGroup.slidersCall
            .image(_model.slidersResponse!.jsonBody)
            ?.toList() ??
        [];

    if (sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_model.pageViewController == null) {
      _model.pageViewController = PageController();
      _sliderTimer?.cancel();
      _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_model.pageViewController != null &&
            _model.pageViewController!.hasClients) {
          final nextPage = (_model.pageViewCurrentIndex + 1) % sliders.length;
          _model.pageViewController!.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: SizedBox(
        height: 180.0,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: PageView.builder(
                controller: _model.pageViewController,
                itemCount: sliders.length,
                itemBuilder: (_, index) {
                  final image = sliders[index];
                  return Image.network(
                    'https://hemedicalapps.com/$image',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.divider,
                      child: const Icon(Icons.image, size: 48.0, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Center(
                child: smooth_page_indicator.SmoothPageIndicator(
                  controller: _model.pageViewController!,
                  count: sliders.length,
                  effect: smooth_page_indicator.ExpandingDotsEffect(
                    expansionFactor: 2.0,
                    spacing: 8.0,
                    radius: 8.0,
                    dotWidth: 6.0,
                    dotHeight: 6.0,
                    dotColor: Colors.white.withOpacity(0.5),
                    activeDotColor: Colors.white,
                    paintStyle: PaintingStyle.fill,
                  ),
                  onDotClicked: (i) => _model.pageViewController!.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              color: theme.primaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
          ),
          const SizedBox(height: 12.0),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Book Appointment',
                      color: const Color(0xFF00C9A7),
                      onTap: () => context.pushNamed(BookingPageWidget.routeName),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.file_copy_sharp,
                      label: 'My Records',
                      color: const Color(0xFF3A8DFF),
                      onTap: () => context.pushNamed(
                        ReportsWidget.routeName,
                        queryParameters: {
                          'id': serializeParam(
                            MedicalAppsApiGroup.profileCall.idplato(
                              (_model.profileres?.jsonBody ?? ''),
                            ),
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.favorite_border,
                      label: 'Health',
                      color: const Color(0xFFEF4444),
                      onTap: () async {
                        await launchURL(
                          'https://wa.me/60136254528?text=Hello%20He%20Clinic',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.medical_information,
                      label: 'Packages',
                      color: const Color(0xFF8B5CF6),
                      onTap: () =>
                          context.pushNamed(ServicePackageWidget.routeName),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [AppShadows.low],
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28.0, color: color),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyPoints() {
    return const SizedBox.shrink();
  }

  Widget _buildUpcomingAppointment() {
    if (!_upcomingLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Appointment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            const SkeletonListTile(),
          ],
        ),
      );
    }

    if (_upcomingError) {
      return _buildSectionError(
        'Upcoming Appointment',
        _loadUpcomingAppointment,
      );
    }

    final response = _model.upcomingApptResponse;
    if (response == null || !response.succeeded) {
      return _buildEmptyStateCard(
        'Upcoming Appointment',
        'No upcoming appointments',
        'Schedule your next visit',
        icon: Icons.event_busy,
        onAction: () => context.pushNamed(BookingPageWidget.routeName),
        actionLabel: 'Book Now',
      );
    }

    final data = response.jsonBody;
    final appointments = data is List ? data : [];
    if (appointments.isEmpty) {
      return _buildEmptyStateCard(
        'Upcoming Appointment',
        'No upcoming appointments',
        'Schedule your next visit',
        icon: Icons.event_busy,
        onAction: () => context.pushNamed(BookingPageWidget.routeName),
        actionLabel: 'Book Now',
      );
    }

    final apptTitle = GetAppointmentUpcomingCall.title(response.jsonBody)?.firstOrNull ?? '';
    final startDate = GetAppointmentUpcomingCall.start(response.jsonBody)?.firstOrNull ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderWithAction(
            'Upcoming Appointment',
            'See All',
            () => context.pushNamed(MyBookingPageWidget.routeName),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppShadows.low],
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 22.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apptTitle.isNotEmpty ? apptTitle : 'Appointment',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (startDate.isNotEmpty) ...[
                            const SizedBox(height: 4.0),
                            Text(
                              startDate,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        context.pushNamed(MyBookingPageWidget.routeName),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOurDoctors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
      child: DoctorListWidget(
        layout: DoctorListLayout.horizontal,
        maxItems: 4,
        showSeeAll: true,
        onSeeAll: () => context.pushNamed(AllDoctorWidget.routeName),
      ),
    );
  }

  Widget _buildHealthTips() {
    final theme = FlutterFlowTheme.of(context);

    if (!_articlesLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Tips',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            const SkeletonTextBlock(lineCount: 3),
          ],
        ),
      );
    }

    if (_articlesError) {
      return _buildSectionError('Health Tips', _loadArticles);
    }

    final titles = GetCmsArticlesCall.title(_model.articlesResponse?.jsonBody ?? '') ?? [];
    final excerpts = GetCmsArticlesCall.excerpt(_model.articlesResponse?.jsonBody ?? '') ?? [];
    final images = GetCmsArticlesCall.featuredImage(_model.articlesResponse?.jsonBody ?? '') ?? [];
    final slugs = GetCmsArticlesCall.slug(_model.articlesResponse?.jsonBody ?? '') ?? [];
    final categories = GetCmsArticlesCall.category(_model.articlesResponse?.jsonBody ?? '') ?? [];
    final displayCount = titles.length;

    if (displayCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderWithAction(
            'Health Tips',
            'See All',
            () => context.pushNamed(AllArticlePageNewWidget.routeName),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 220.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: displayCount,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (_, index) => _buildArticleCard(
                title: titles[index],
                excerpt: index < excerpts.length ? _stripHtml(excerpts[index]) : '',
                imageUrl: index < images.length ? images[index] : '',
                slug: index < slugs.length ? slugs[index] : '',
                category: index < categories.length ? categories[index] : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String excerpt,
    required String imageUrl,
    required String slug,
    String? category,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          ArticleDetailPageWidget.routeName,
          queryParameters: {
            'title': serializeParam(title, ParamType.String),
            'content': serializeParam(excerpt, ParamType.String),
            'imageUrl': serializeParam(imageUrl, ParamType.String),
            'articleSlug': serializeParam(slug, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        width: 200.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [AppShadows.low],
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110.0,
              width: double.infinity,
              color: AppColors.divider,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.article_outlined,
                        size: 32.0,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.article_outlined,
                      size: 32.0,
                      color: AppColors.textSecondary,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stripHtml(title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (excerpt.isNotEmpty) ...[
                    const SizedBox(height: 6.0),
                    Text(
                      excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideos() {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderWithAction(
            'Videos',
            'See All',
            () => context.pushNamed(AllContentMediaWidget.routeName),
          ),
          const SizedBox(height: 8.0),
          StreamBuilder<List<VideosRecord>>(
            stream: queryVideosRecord(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SkeletonGrid(itemCount: 4);
              }

              final videos = snapshot.data!;
              if (videos.isEmpty) return const SizedBox.shrink();

              final displayVideos = videos.length > 4
                  ? videos.sublist(0, 4)
                  : videos;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: displayVideos.length,
                itemBuilder: (_, index) {
                  final video = displayVideos[index];
                  return GestureDetector(
                    onTap: () => launchURL(video.videoUrl),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: AppColors.divider,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child:                           video.thumbnail.isNotEmpty
                                ? Image.network(
                                    video.thumbnail,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _videoPlaceholder(),
                                  )
                                : _videoPlaceholder(),
                          ),
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.primary,
                              size: 22.0,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(AppRadius.lg),
                                ),
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Text(
                                video.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _videoPlaceholder() {
    return Container(
      color: AppColors.divider,
      child: const Center(
        child: Icon(Icons.video_library_outlined,
            size: 32.0, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: SkeletonSlider(),
    );
  }

  Widget _buildSectionSkeleton(String title, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionError(String sectionName, VoidCallback onRetry,
      {double? height}) {
    return ErrorStateWidget(onRetry: onRetry);
  }

  Widget _buildEmptyStateCard(String title, String message, String subMessage,
      {IconData icon = Icons.inbox_outlined,
      VoidCallback? onAction,
      String? actionLabel}) {
    return EmptyStateWidget(
      icon: icon,
      title: message,
      subtitle: subMessage,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  Widget _buildSectionHeaderWithAction(
    String title,
    String actionLabel,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
