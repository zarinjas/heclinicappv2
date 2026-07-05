import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_radius.dart';
import '/core/widgets/app_app_bar.dart';
import '/core/widgets/section_header.dart';
import '/core/widgets/quick_action_grid.dart';
import '/core/widgets/hero_slider.dart';
import '/core/widgets/loyalty_card.dart';
import '/core/widgets/appointment_card.dart';
import '/core/widgets/doctor_card.dart';
import '/core/widgets/article_card.dart';
import '/core/widgets/video_card.dart';
import '/core/widgets/app_skeleton.dart';
import '/core/widgets/app_empty_state.dart';
import '/core/widgets/app_error_state.dart';
import '/core/widgets/app_chip.dart';
import '/components/doctor_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String routeName = 'HomeScreen';
  static String routePath = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _profileLoaded = false;
  bool _slidersLoaded = false;
  bool _upcomingLoaded = false;
  bool _articlesLoaded = false;
  bool _videosLoaded = false;

  bool _slidersError = false;
  bool _upcomingError = false;
  bool _articlesError = false;
  bool _videosError = false;

  dynamic _profileResponse;
  dynamic _slidersResponse;
  dynamic _upcomingApptResponse;
  dynamic _articlesResponse;
  dynamic _videosResponse;

  @override
  void initState() {
    super.initState();
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
      _loadVideos(),
    ]);
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    _profileResponse = await MedicalAppsApiGroup.profileCall.call(
      authorization: 'Bearer ${FFAppState().tokenauth}',
      accept: 'application/json',
    );

    if (_profileResponse?.succeeded ?? false) {
      if (MedicalAppsApiGroup.profileCall.changed(
            (_profileResponse?.jsonBody ?? ''),
          ) !=
          'oke') {
        if (!FFAppState().passwordChanged && mounted) {
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

    final idplato = MedicalAppsApiGroup.profileCall.idplato(
      (_profileResponse?.jsonBody ?? ''),
    ) ?? '';

    FFAppState().idplato = idplato;
    FFAppState().update(() {});

    await GetAppointmentCall.call(patientId: idplato);

    FFAppState().name = MedicalAppsApiGroup.profileCall.name(
      (_profileResponse?.jsonBody ?? ''),
    ) ?? '';
    setState(() {});

    await FcmRecord.collection.doc(idplato).set(createFcmRecordData(
      idPatient: idplato,
      fcmToken: FFAppState().fcmtoken,
    ));

    FFAppState().idplato = idplato;
    FFAppState().name = MedicalAppsApiGroup.profileCall.name(
      (_profileResponse?.jsonBody ?? ''),
    ) ?? '';
    setState(() {});

    final countNotifnotread = await queryHistorynotifRecordCount(
      queryBuilder: (r) => r
          .where('id_patient', isEqualTo: idplato)
          .where('read', isEqualTo: 'no'),
    );
    FFAppState().coutnnotif = countNotifnotread?.toString() ?? '0';
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

    FFAppState().coutnnotif = countNotifnotread?.toString() ?? '0';
    FFAppState().update(() {});

    final apiResultu9n = await GetPatientbyidCall.call(idpatient: idplato);
    if (apiResultu9n?.succeeded ?? false) {
      FFAppState().givenid = GetPatientbyidCall.givenid(
        (apiResultu9n?.jsonBody ?? ''),
      ) ?? '';
      setState(() {});
    }

    if (mounted) {
      setState(() => _profileLoaded = true);
    }
  }

  Future<void> _loadSliders() async {
    try {
      _slidersResponse = await MedicalAppsApiGroup.slidersCall.call(
        authorization: 'Bearer ${FFAppState().tokenauth}',
      );
      if (mounted) {
        setState(() {
          _slidersLoaded = true;
          _slidersError = !(_slidersResponse?.succeeded ?? false);
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
      _upcomingApptResponse = await GetAppointmentUpcomingCall.call(
        patientId: MedicalAppsApiGroup.profileCall.idplato(
          (_profileResponse?.jsonBody ?? ''),
        ),
      );
      if (mounted) {
        setState(() {
          _upcomingLoaded = true;
          _upcomingError = !(_upcomingApptResponse?.succeeded ?? false);
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
      _articlesResponse = await GetCmsArticlesCall.call(limit: 4);
      if (mounted) {
        setState(() {
          _articlesLoaded = true;
          _articlesError = !(_articlesResponse?.succeeded ?? false);
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _articlesLoaded = true;
        _articlesError = true;
      });
    }
  }

  Future<void> _loadVideos() async {
    try {
      _videosResponse = await GetCmsVideosCall.call(limit: 6);
      if (mounted) {
        setState(() {
          _videosLoaded = true;
          _videosError = !(_videosResponse?.succeeded ?? false);
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _videosLoaded = true;
        _videosError = true;
      });
    }
  }

  StatusChipVariant _parseStatus(String? status) {
    if (status == null) return StatusChipVariant.pending;
    final lower = status.toLowerCase();
    switch (lower) {
      case 'confirmed':
        return StatusChipVariant.confirmed;
      case 'pending':
        return StatusChipVariant.pending;
      case 'cancelled':
      case 'canceled':
        return StatusChipVariant.cancelled;
      case 'completed':
        return StatusChipVariant.completed;
      default:
        return StatusChipVariant.pending;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgColor,
      appBar: AppAppBar.main(
        onNotificationTap: () =>
            context.pushNamed(NotificationPageWidget.routeName),
        notificationCount: int.tryParse(FFAppState().coutnnotif) ?? 0,
      ),
      body: SafeArea(
        top: true,
        child: RefreshIndicator(
          onRefresh: () async => await _loadInitialData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                _buildHeroSliderSection(),
                _buildQuickActionsSection(),
                _buildLoyaltySection(),
                _buildUpcomingAppointmentSection(),
                _buildDoctorsSection(),
                _buildArticlesSection(),
                _buildVideosSection(),
                const SizedBox(height: AppSpacing.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space8,
        AppSpacing.space24,
        AppSpacing.space12,
      ),
      child: Text(
        '${_getGreeting()}, ${FFAppState().name}',
        style: AppTextStyles.heading3.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildHeroSliderSection() {
    if (!_slidersLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: const HeroSliderSkeleton(),
      );
    }

    if (_slidersError || !_slidersResponse!.succeeded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: AppErrorState(
          title: 'Failed to load sliders',
          subtitle: 'Pull down to refresh or try again',
          onRetry: _loadSliders,
        ),
      );
    }

    final sliders = MedicalAppsApiGroup.slidersCall
            .image(_slidersResponse!.jsonBody)
            ?.toList() ??
        [];

    if (sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    final urlPrefix = 'https://hemedicalapps.com/';
    final slides = sliders.map((image) {
      return HeroSlide(imageUrl: '$urlPrefix$image');
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: HeroSlider(slides: slides),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppSpacing.space12),
          QuickActionGrid(
            actions: [
              QuickAction(
                icon: Icons.calendar_month_outlined,
                label: 'Book Appointment',
                onTap: () => context.pushNamed(BookingPageWidget.routeName),
              ),
              QuickAction(
                icon: Icons.file_copy_sharp,
                label: 'My Records',
                onTap: () => context.pushNamed(
                  ReportsWidget.routeName,
                  queryParameters: {
                    'id': serializeParam(
                      MedicalAppsApiGroup.profileCall.idplato(
                        (_profileResponse?.jsonBody ?? ''),
                      ),
                      ParamType.String,
                    ),
                  }.withoutNulls,
                ),
              ),
              QuickAction(
                icon: Icons.favorite_border,
                label: 'Health',
                onTap: () async {
                  await launchURL(
                    'https://wa.me/60136254528?text=Hello%20He%20Clinic',
                  );
                },
              ),
              QuickAction(
                icon: Icons.medical_information,
                label: 'Packages',
                onTap: () =>
                    context.pushNamed(ServicePackageWidget.routeName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: const LoyaltyCard(
        pointsBalance: 1250,
        tier: LoyaltyTier.gold,
        variant: LoyaltyCardVariant.compact,
      ),
    );
  }

  Widget _buildUpcomingAppointmentSection() {
    if (!_upcomingLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Upcoming Appointment',
              onSeeAll: () =>
                  context.pushNamed(MyBookingPageWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            const AppSkeleton.appointmentCard(),
          ],
        ),
      );
    }

    if (_upcomingError || !_upcomingApptResponse!.succeeded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Upcoming Appointment',
              onSeeAll: () =>
                  context.pushNamed(MyBookingPageWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppErrorState(
              title: 'Failed to load appointments',
              subtitle: 'Pull down to refresh',
              onRetry: _loadUpcomingAppointment,
            ),
          ],
        ),
      );
    }

    final titles = GetAppointmentUpcomingCall.title(
          _upcomingApptResponse!.jsonBody,
        )?.toList() ??
        [];
    final starts = GetAppointmentUpcomingCall.start(
          _upcomingApptResponse!.jsonBody,
        )?.toList() ??
        [];
    final statuss = GetAppointmentUpcomingCall.status(
          _upcomingApptResponse!.jsonBody,
        )?.toList() ??
        [];
    final dpnames = GetAppointmentUpcomingCall.doctorname(
          _upcomingApptResponse!.jsonBody,
        )?.toList() ??
        [];
    final dpbranches = GetAppointmentUpcomingCall.branch(
          _upcomingApptResponse!.jsonBody,
        )?.toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Upcoming Appointment',
            onSeeAll: () =>
                context.pushNamed(MyBookingPageWidget.routeName),
          ),
          const SizedBox(height: AppSpacing.space12),
          if (titles.isEmpty)
            AppEmptyState(
              icon: Icons.calendar_today,
              title: 'No upcoming appointments',
              subtitle: 'Book your next visit with us',
              ctaLabel: 'Book Now',
              onCtaTap: () =>
                  context.pushNamed(BookingPageWidget.routeName),
            )
          else
            for (var i = 0; i < titles.length && i < 1; i++)
              AppointmentCard(
                doctorName: dpnames.length > i ? dpnames[i] : '',
                specialty: '',
                branchName: dpbranches.length > i ? dpbranches[i] : '',
                date: starts.length > i ? starts[i] : '',
                time: '',
                status: _parseStatus(
                    statuss.length > i ? statuss[i] : null),
              ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Our Doctors',
            onSeeAll: () => context.pushNamed(AllDoctorWidget.routeName),
          ),
          const SizedBox(height: AppSpacing.space12),
          DoctorListWidget(
            layout: DoctorListLayout.horizontal,
            maxItems: 4,
            showSeeAll: false,
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (!_articlesLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Health Tips',
              onSeeAll: () =>
                  context.pushNamed(AllArticlePageNewWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, i) => SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: AppSpacing.space12),
                    child: const AppSkeleton.articleCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_articlesError || !_articlesResponse!.succeeded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Health Tips',
              onSeeAll: () =>
                  context.pushNamed(AllArticlePageNewWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppErrorState(
              title: 'Failed to load articles',
              subtitle: 'Pull down to refresh',
              onRetry: _loadArticles,
            ),
          ],
        ),
      );
    }

    final titles = GetCmsArticlesCall.title(
          _articlesResponse!.jsonBody,
        )?.toList() ??
        [];
    final excerpts = GetCmsArticlesCall.excerpt(
          _articlesResponse!.jsonBody,
        )?.toList() ??
        [];
    final images = GetCmsArticlesCall.featuredImage(
          _articlesResponse!.jsonBody,
        )?.toList() ??
        [];
    final slugs = GetCmsArticlesCall.slug(
          _articlesResponse!.jsonBody,
        )?.toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Health Tips',
            onSeeAll: () =>
                context.pushNamed(AllArticlePageNewWidget.routeName),
          ),
          const SizedBox(height: AppSpacing.space12),
          if (titles.isEmpty)
            const AppEmptyState(
              icon: Icons.article_outlined,
              title: 'No articles yet',
              subtitle: 'Check back later for health tips',
            )
          else
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: titles.length,
                itemBuilder: (_, i) {
                  return SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: AppSpacing.space12),
                      child: ArticleCard(
                        imageUrl:
                            images.length > i ? images[i] : '',
                        title: titles[i],
                        excerpt:
                            excerpts.length > i ? excerpts[i] : '',
                        author: '',
                        date: '',
                        onTap: () => context.pushNamed(
                          ArticleDetailPageWidget.routeName,
                          queryParameters: {
                            'slug': serializeParam(
                              slugs.length > i ? slugs[i] : '',
                              ParamType.String,
                            ),
                          }.withoutNulls,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideosSection() {
    if (!_videosLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Videos',
              onSeeAll: () =>
                  context.pushNamed(AllContentMediaWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            Row(
              children: const [
                Expanded(child: AppSkeleton.videoGrid()),
                SizedBox(width: AppSpacing.space16),
                Expanded(child: AppSkeleton.videoGrid()),
              ],
            ),
          ],
        ),
      );
    }

    if (_videosError || !_videosResponse!.succeeded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Videos',
              onSeeAll: () =>
                  context.pushNamed(AllContentMediaWidget.routeName),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppErrorState(
              title: 'Failed to load videos',
              subtitle: 'Pull down to refresh',
              onRetry: _loadVideos,
            ),
          ],
        ),
      );
    }

    final titles = GetCmsVideosCall.title(
          _videosResponse!.jsonBody,
        )?.toList() ??
        [];
    final thumbnails = GetCmsVideosCall.thumbnailUrl(
          _videosResponse!.jsonBody,
        )?.toList() ??
        [];
    final tiktokUrls = GetCmsVideosCall.tiktokUrl(
          _videosResponse!.jsonBody,
        )?.toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Videos',
            onSeeAll: () =>
                context.pushNamed(AllContentMediaWidget.routeName),
          ),
          const SizedBox(height: AppSpacing.space12),
          if (titles.isEmpty)
            const AppEmptyState(
              icon: Icons.videocam_outlined,
              title: 'No videos yet',
              subtitle: 'Check back later for health videos',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.space12,
                mainAxisSpacing: AppSpacing.space12,
                childAspectRatio: 0.75,
              ),
              itemCount: titles.length > 4 ? 4 : titles.length,
              itemBuilder: (_, i) {
                return VideoCard(
                  thumbnailUrl:
                      thumbnails.length > i ? thumbnails[i] : '',
                  title: titles[i],
                  author: '',
                  onTap: () async {
                    if (tiktokUrls.length > i &&
                        tiktokUrls[i].isNotEmpty) {
                      await launchURL(tiktokUrls[i]);
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
