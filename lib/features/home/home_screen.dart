import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/loyalty_api.dart';
import '/core/services/appointment_cache.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/services/article_service.dart';
import '/core/services/doctor_service.dart';
import '/core/services/branch_service.dart';
import '/core/services/hero_service.dart';
import '/core/services/video_service.dart';
import '/core/services/promotion_service.dart';
import '/core/services/cms_api.dart';
import '/core/services/clinic_info_service.dart';
import '/core/services/notification_inbox_service.dart';
import '/core/services/models/article.dart';
import '/core/services/models/doctor.dart';
import '/core/services/models/branch.dart';
import '/core/services/models/hero_banner.dart';
import '/core/services/models/video.dart';
import '/core/services/models/promotion.dart';
import '/core/services/models/clinic_info.dart';
import '/core/widgets/app_app_bar.dart';
import '/core/widgets/app_card.dart';
import '/core/widgets/app_chip.dart';
import '/core/widgets/app_empty_state.dart';

import '/core/widgets/app_skeleton.dart';
import '/core/widgets/appointment_card.dart';
import '/core/widgets/branch_card.dart';
import '/core/widgets/compact_quick_actions.dart';
import '/core/widgets/doctor_card.dart';
import '/core/widgets/featured_article_banner.dart';
import '/core/widgets/gradient_hero_slider.dart';
import '/core/widgets/loyalty_card.dart';
import '/core/widgets/mini_article_card.dart';
import '/core/widgets/package_progress_card.dart';
import '/core/widgets/section_header.dart';
import '/core/widgets/video_card.dart';
import '/components/doctor_detail_sheet.dart';
import '/info_page/hemed_info/hemed_info_widget.dart';
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _profLoaded = false;
  bool _heroLoaded = false;
  bool _apptLoaded = false;
  bool _docLoaded = false;
  bool _branchLoaded = false;
  bool _articleLoaded = false;
  bool _videoLoaded = false;
  bool _promoLoaded = false;
  bool _clinicInfoLoaded = false;
  bool _loyaltyLoaded = false;
  bool _pkgLoaded = false;

  bool _heroErr = false;
  bool _apptErr = false;
  bool _docErr = false;
  bool _branchErr = false;
  bool _articleErr = false;
  bool _videoErr = false;
  bool _loyaltyErr = false;
  bool _clinicInfoErr = false;
  bool _pkgErr = false;

  List<HeroBanner> _heroes = HeroBanner.fallbackList;
  List<Doctor> _doctors = Doctor.fallbackList;
  List<Branch> _branches = Branch.fallbackList;
  List<Article> _articles = Article.fallbackList;
  List<Video> _videos = Video.fallbackList;
  List<Promotion> _promos = Promotion.fallbackList;
  List<ClinicInfo> _clinicInfos = ClinicInfo.fallbackList;

  int _loyaltyBalance = 0;

  List<_PatientPackage> _packages = const [];

  dynamic _apptResponse;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    _loadGreeting();
    await Future.wait([
      _loadHeroes(),
      _loadAppointment(),
      _loadDoctors(),
      _loadBranches(),
      _loadArticles(),
      _loadVideos(),
      _loadPromotions(),
      _loadClinicInfo(),
      _loadLoyalty(),
      _loadPackages(),
      _loadUnreadNotifications(),
    ]);
    if (mounted) setState(() {});
  }

  /// Seed the notification badge from the server. Push handlers only ever
  /// increment it locally, so without this the count is lost on restart and
  /// notifications that arrived while the app was closed are never counted.
  Future<void> _loadUnreadNotifications() async {
    if (FFAppState().tokenauth.isEmpty) return;

    final unread = await NotificationInboxService.instance.unreadCount();
    if (!mounted) return;

    if (unread <= 0) {
      FFAppState().resetNotifCount();
    } else {
      FFAppState().coutnnotif = unread.toString();
    }
  }

  void _loadGreeting() {
    setState(() => _profLoaded = true);
  }

  Future<void> _loadHeroes() async {
    try {
      await HeroService.instance.init();
      if (mounted) setState(() {
        _heroes = HeroService.instance.banners;
        _heroLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _heroLoaded = true; _heroErr = true; });
    }
  }

  Future<void> _loadAppointment() async {
    try {
      final id = FFAppState().idplato;
      if (id.isEmpty) { if (mounted) setState(() => _apptLoaded = true); return; }

      // Paint the cached appointment instantly, then refresh from the network
      // so the card is never blocked behind a cold request.
      if (_apptResponse == null) {
        final cached = await AppointmentCache.loadUpcoming();
        if (cached != null && mounted) {
          setState(() {
            _apptResponse = ApiCallResponse(cached, const {}, 200);
            _apptLoaded = true;
            _apptErr = false;
          });
        }
      }

      final response = await GetAppointmentUpcomingCall.call(patientId: id);
      if (response.succeeded) {
        await AppointmentCache.saveUpcoming(response.jsonBody);
      }
      if (mounted) setState(() {
        _apptLoaded = true;
        if (response.succeeded) {
          _apptResponse = response;
          _apptErr = false;
        } else if (_apptResponse == null) {
          _apptErr = true;
        }
      });
    } catch (_) {
      if (mounted) setState(() {
        _apptLoaded = true;
        if (_apptResponse == null) _apptErr = true;
      });
    }
  }

  Future<void> _loadLoyalty() async {
    try {
      final id = FFAppState().idplato;
      if (id.isEmpty) {
        if (mounted) setState(() => _loyaltyLoaded = true);
        return;
      }
      final response = await LoyaltyApi.getLoyaltyBalanceCall.call();
      if (mounted) setState(() {
        _loyaltyBalance = GetLoyaltyBalanceCall.balance(response.jsonBody) ?? 0;
        _loyaltyLoaded = true;
        _loyaltyErr = !(response.succeeded &&
            (GetLoyaltyBalanceCall.status(response.jsonBody) == true));
      });
    } catch (_) {
      if (mounted) setState(() { _loyaltyLoaded = true; _loyaltyErr = true; });
    }
  }

  Future<void> _loadPackages() async {
    try {
      final id = FFAppState().idplato;
      if (id.isEmpty) {
        if (mounted) setState(() => _pkgLoaded = true);
        return;
      }

      // Package sessions are tracked by clinic staff in Plato: a combo package
      // is an invoice line with inventory == 'package' and a `redemptions`
      // count, and each redeemed session is another treatment line sharing the
      // same given_id + invoice_id. Remaining = total - redeemed.
      final response = await GetInvoiceCall.call(patientId: id);
      if (!response.succeeded) {
        if (mounted) setState(() { _pkgLoaded = true; _pkgErr = true; });
        return;
      }

      final body = response.jsonBody;
      final names = GetInvoiceCall.itemname(body);
      final inventory = GetInvoiceCall.inventori(body);
      final givenIds = GetInvoiceCall.givenid(body);
      final categories = GetInvoiceCall.kategori(body);
      final redemptions = GetInvoiceCall.redemptions(body);
      final others = GetInvoiceCall.otherpackage(body);
      final invoiceIds = GetInvoiceCall.idlist(body);

      final packages = <_PatientPackage>[];
      final seen = <String>{};

      if (names != null &&
          inventory != null &&
          givenIds != null &&
          categories != null &&
          redemptions != null &&
          others != null &&
          invoiceIds != null) {
        for (var i = 0; i < names.length; i++) {
          if (i >= inventory.length || inventory[i] != 'package') continue;
          if (i >= givenIds.length || i >= invoiceIds.length) continue;

          final givenId = givenIds[i];
          // Same package can appear on several invoices — show it once.
          if (givenId.isEmpty || !seen.add(givenId)) continue;

          final total = i < redemptions.length ? redemptions[i] : 0;
          final remainingRaw = countMatchingGivenId(
            others,
            givenId,
            givenIds,
            categories,
            redemptions,
            invoiceIds,
            invoiceIds[i],
          );
          final remaining = int.tryParse(remainingRaw ?? '') ?? 0;

          packages.add(_PatientPackage(
            name: names[i],
            total: total,
            remaining: remaining < 0 ? 0 : remaining,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _packages = packages;
          _pkgLoaded = true;
          _pkgErr = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _pkgLoaded = true; _pkgErr = true; });
    }
  }

  Future<void> _loadDoctors() async {
    try {
      final service = DoctorService.instance;
      final wasInitialised = service.isInitialised;
      await service.init();
      // Always re-fetch once the service has loaded before, so doctors that
      // were toggled "Show in App" in the Admin Panel appear without needing
      // an app restart.
      if (wasInitialised) {
        await service.refresh();
      }
      if (mounted) setState(() {
        _doctors = service.doctors;
        _docLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _docLoaded = true; _docErr = true; });
    }
  }

  Future<void> _loadBranches() async {
    try {
      await BranchService.instance.init();
      if (mounted) setState(() {
        _branches = BranchService.instance.branches;
        _branchLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _branchLoaded = true; _branchErr = true; });
    }
  }

  Future<void> _loadArticles() async {
    try {
      await ArticleService.instance.init();
      if (mounted) setState(() {
        _articles = ArticleService.instance.articles;
        _articleLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _articleLoaded = true; _articleErr = true; });
    }
  }

  Future<void> _loadVideos() async {
    try {
      await VideoService.instance.init();
      if (mounted) setState(() {
        _videos = VideoService.instance.videos;
        _videoLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _videoLoaded = true; _videoErr = true; });
    }
  }

  Future<void> _loadPromotions() async {
    try {
      final service = PromotionService.instance;
      final wasInitialised = service.isInitialised;
      await service.init();
      // Always re-fetch once the service has loaded before, so promotions
      // created in the Admin Panel appear without needing an app restart.
      if (wasInitialised) {
        await service.refresh();
      }
      if (mounted) setState(() {
        _promos = service.promotions;
        _promoLoaded = true;
      });
    } catch (_) {
      _promoLoaded = true;
    }
  }

  Future<void> _loadClinicInfo() async {
    try {
      await ClinicInfoService.instance.init();
      if (mounted) setState(() {
        _clinicInfos = ClinicInfoService.instance.items;
        _clinicInfoLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _clinicInfoLoaded = true; _clinicInfoErr = true; });
    }
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Greeting inside the App Bar — next to the logo, vertically centered.
  Widget _buildGreetingWidget() {
    final name = FFAppState().name.isNotEmpty ? FFAppState().name : 'User';
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_getGreeting()},',
            style: AppTextStyles.body2.copyWith(
              color: Colors.white70,
              fontSize: 10,
              height: 1.2,
            ),
          ),
          Text(
            name,
            style: AppTextStyles.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  StatusChipVariant _parseStatus(String? s) {
    if (s == null) return StatusChipVariant.pending;
    switch (s.toLowerCase()) {
      case 'confirmed': return StatusChipVariant.confirmed;
      case 'pending': return StatusChipVariant.pending;
      case 'cancelled': case 'canceled': return StatusChipVariant.cancelled;
      case 'completed': return StatusChipVariant.completed;
      default: return StatusChipVariant.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    context.watch<FFAppState>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.main(
        title: _buildGreetingWidget(),
        onNotificationTap: () => context.pushNamed('notificationPage'),
        notificationCount: int.tryParse(FFAppState().coutnnotif) ?? 0,
      ),
      body: SafeArea(
        top: true,
        child: RefreshIndicator(
          onRefresh: _loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(isDark),
                _buildQuickActions(isDark),
                _buildLoyaltySection(isDark),
                _buildAppointmentSection(isDark),
                _buildPackagesSection(isDark),
                _buildVouchersSection(isDark),
                _buildDoctorsSection(isDark),
                _buildBranchesSection(isDark),
                _buildArticlesSection(isDark),
                _buildClinicInfoSection(isDark),
                _buildVideosSection(isDark),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    if (!_heroLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: AppSkeleton.slider(),
      );
    }
    if (_heroErr || _heroes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: GradientHeroSlider(
        slides: _heroes.map((b) => GradientHeroSlide(
          title: b.title,
          subtitle: b.subtitle,
          imageUrl: b.imageUrl,
          cta: b.buttonText,
          gradient: b.gradient,
          onTap: b.linkUrl != null && b.linkUrl!.isNotEmpty
              ? () => launchUrl(Uri.parse(b.linkUrl!))
              : null,
        )).toList(),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: CompactQuickActions(
        horizontalPadding: 0,
        actions: [
        CompactQuickAction(
          icon: Icons.event_available_outlined,
          label: 'Book Visit',
          tint: const Color(0xFF3B8DFF),
          onTap: () => context.push('/branchSelectionScreen'),
        ),
        CompactQuickAction(
          icon: Icons.folder_open_outlined,
          label: 'Records',
          tint: const Color(0xFF27F5A3),
          onTap: () => context.pushNamed('Reports'),
        ),
        CompactQuickAction(
          icon: Icons.video_call_outlined,
          label: 'Telehealth',
          tint: const Color(0xFFF5A623),
          onTap: () => context.pushNamed('/telehealth'),
        ),
        CompactQuickAction(
          icon: Icons.medical_information_outlined,
          label: 'Packages',
          tint: const Color(0xFF2868F5),
          onTap: () => context.pushNamed('/packages'),
        ),
      ]),
    );
  }

  Widget _buildAppointmentSection(bool isDark) {
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    if (!_apptLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Upcoming Appointment',
              onSeeAll: () => context.pushNamed('AppointmentsScreen'),
            ),
            const SizedBox(height: 12),
            AppSkeleton.appointmentCard(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Upcoming Appointment',
            onSeeAll: () => context.pushNamed('AppointmentsScreen'),
          ),
          const SizedBox(height: 12),
          _buildAppointmentCard(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    if (_apptErr || _apptResponse == null) {
      return AppEmptyState(
        icon: Icons.calendar_today,
        title: 'No upcoming appointments',
        subtitle: 'Book your next visit with us',
        ctaLabel: 'Book Now',
        onCtaTap: () => context.push('/branchSelectionScreen'),
      );
    }

    final titles = GetAppointmentUpcomingCall.title(_apptResponse!.jsonBody)?.toList() ?? [];
    final starts = GetAppointmentUpcomingCall.start(_apptResponse!.jsonBody)?.toList() ?? [];
    final statuss = GetAppointmentUpcomingCall.status(_apptResponse!.jsonBody)?.toList() ?? [];
    final dpnames = GetAppointmentUpcomingCall.doctorname(_apptResponse!.jsonBody)?.toList() ?? [];
    final dpbranches = GetAppointmentUpcomingCall.branch(_apptResponse!.jsonBody)?.toList() ?? [];

    if (titles.isEmpty) {
      return AppEmptyState(
        icon: Icons.calendar_today,
        title: 'No upcoming appointments',
        subtitle: 'Book your next visit with us',
        ctaLabel: 'Book Now',
        onCtaTap: () => context.push('/branchSelectionScreen'),
      );
    }

    final i = 0;
    final docName = dpnames.length > i ? dpnames[i] : '';
    final doctor = _doctors.cast<Doctor?>().firstWhere(
      (d) => d?.name == docName, orElse: () => null,
    );

    return AppointmentCard(
      doctorPhotoUrl: doctor?.photoUrl,
      doctorInitials: doctor?.initials ?? (docName.isNotEmpty ? docName[0].toUpperCase() : '?'),
      doctorGradient: doctor?.avatarGradient ?? const [AppColors.accent, AppColors.accentBlue],
      doctorName: docName,
      specialty: doctor?.specialty ?? '',
      branchName: dpbranches.length > i ? dpbranches[i] : '',
      date: starts.length > i ? starts[i] : '',
      time: '',
      status: _parseStatus(statuss.length > i ? statuss[i] : null),
      countdownDueAt: null,
      onTap: () => context.pushNamed('AppointmentsScreen'),
      onDetailsTap: () => context.pushNamed('AppointmentsScreen'),
      onAddToCalendar: null,
    );
  }

  Widget _buildLoyaltySection(bool isDark) {
    if (!_loyaltyLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: const LoyaltyCardSkeleton(),
      );
    }
    // Always show the card — even when the patient has no balance yet.
    // On API error, fall back to 0 points so the section still renders.
    final balance = _loyaltyErr ? 0 : _loyaltyBalance;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: LoyaltyCard(
        pointsBalance: balance,
        showTier: false,
        showProgress: false,
        onRedeem: () => context.pushNamed('/my-points'),
        onViewHistory: () => context.pushNamed('/my-points'),
      ),
    );
  }

  Widget _buildPackagesSection(bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    Widget emptyState() {
      return AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space24,
        ),
        child: Column(
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 36,
              color: textSecondary,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'No Packages Available',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Your treatment packages will appear here',
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(color: textSecondary),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Packages'),
          const SizedBox(height: 12),
          if (!_pkgLoaded)
            AppSkeleton.card(height: 88)
          else if (_pkgErr || _packages.isEmpty)
            emptyState()
          else
            ..._packages.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                child: PackageProgressCard(
                  name: p.name,
                  total: p.total,
                  remaining: p.remaining,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVouchersSection(bool isDark) {
    if (!_promoLoaded) return const SizedBox.shrink();
    if (_promos.isEmpty) return const SizedBox.shrink();

    final items = _promos.take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Deals & Vouchers',
            onSeeAll: () => context.pushNamed('/vouchers'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = items[i];
                final imageUrl = p.imageUrl;
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  return _buildPromoImageCard(p, imageUrl);
                }
                final gradient = p.placeholderGradient;
                final discount = p.ctaText ?? p.promoCode ?? p.title;
                return GestureDetector(
                  onTap: () => context.pushNamed('/vouchers'),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          discount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Claim', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: gradient[0])),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildPromoImageCard(Promotion p, String imageUrl) {
    return GestureDetector(
      onTap: () => context.pushNamed('/vouchers'),
      child: SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2,
            child: Image.network(
              CmsApi.resolveMediaUrl(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: p.placeholderGradient,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsSection(bool isDark) {
    if (!_docLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Our Doctors', onSeeAll: () => context.pushNamed('/doctors-list')),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, i) => SizedBox(
                  width: 104,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AppSkeleton.doctorHorizontal(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_docErr || _doctors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Our Doctors', onSeeAll: () => context.pushNamed('/doctors-list')),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _doctors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final d = _doctors[i];
                return SizedBox(
                  width: 104,
                  child: DoctorCard(
                    photoUrl: d.photoUrl,
                    initials: d.initials,
                    avatarGradient: d.avatarGradient,
                    name: d.name,
                    specialty: d.specialty,
                    variant: DoctorCardVariant.horizontal,
                    onTap: () => DoctorDetailSheet.show(
                      context,
                      doctorName: d.name,
                      specialty: d.specialty,
                      qualifications: d.qualifications,
                      branchName: d.branchName,
                      photoUrl: d.photoUrl,
                      bio: d.bio,
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

  Widget _buildBranchesSection(bool isDark) {
    if (!_branchLoaded) return const SizedBox.shrink();
    if (_branchErr || _branches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Our Branch', onSeeAll: () => context.pushNamed('/branches')),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _branches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final b = _branches[i];
                return BranchCard(
                  name: b.name,
                  address: b.address,
                  imageUrl: b.imageUrl,
                  leadingGradient: b.leadingGradient,
                  leadingLabel: 'Branch',
                  variant: BranchCardVariant.vertical,
                  onTap: () => context.pushNamed(
                    '/branch-detail',
                    queryParameters: {'branchName': b.name},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection(bool isDark) {
    if (!_articleLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Health Articles', onSeeAll: () => context.pushNamed('/articlesList')),
            const SizedBox(height: 12),
            AppSkeleton.articleCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppSkeleton.articleCard()),
                const SizedBox(width: 12),
                Expanded(child: AppSkeleton.articleCard()),
                const SizedBox(width: 12),
                Expanded(child: AppSkeleton.articleCard()),
              ],
            ),
          ],
        ),
      );
    }
    if (_articleErr || _articles.isEmpty) return const SizedBox.shrink();

    final featured = _articles.firstWhere(
      (a) => a.isFeatured,
      orElse: () => _articles.first,
    );
    final rest = _articles.where((a) => a.slug != featured.slug).take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Health Articles', onSeeAll: () => context.pushNamed('/articlesList')),
          const SizedBox(height: 12),
          FeaturedArticleBanner(
            imageUrl: featured.featuredImage ?? '',
            placeholderGradient: featured.placeholderGradient,
            title: featured.title,
            excerpt: featured.excerpt,
            category: featured.category,
            author: featured.authorName,
            date: featured.dateDisplay,
            onTap: () => context.pushNamed(
              '/articleDetail',
              queryParameters: {'articleSlug': featured.slug},
            ),
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rest
                  .map((a) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: a == rest.last ? 0 : AppSpacing.space8,
                          ),
                          child: MiniArticleCard(
                            imageUrl: a.featuredImage ?? '',
                            placeholderGradient: a.placeholderGradient,
                            title: a.title,
                            category: a.category,
                            onTap: () => context.pushNamed(
                              '/articleDetail',
                              queryParameters: {'articleSlug': a.slug},
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideosSection(bool isDark) {
    final itemWidth = (MediaQuery.sizeOf(context).width - 32) * 0.55;
    final itemHeight = itemWidth * (16 / 9) + 84;

    if (!_videoLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Featured Videos', onSeeAll: () => context.pushNamed('/videosList')),
            const SizedBox(height: 12),
            SizedBox(
              height: itemHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: itemWidth,
                  child: AppSkeleton.card(
                    height: itemHeight,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.radiusLG),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_videoErr || _videos.isEmpty) return const SizedBox.shrink();

    final items = _videos.take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Featured Videos', onSeeAll: () => context.pushNamed('/videosList')),
          const SizedBox(height: 12),
          SizedBox(
            height: itemHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final v = items[i];
                return SizedBox(
                  width: itemWidth,
                  child: VideoCard(
                    thumbnailUrl: v.thumbnailUrl ?? '',
                    placeholderGradient: v.placeholderGradient,
                    title: v.title,
                    author: v.author,
                    videoAspectRatio: 9 / 16,
                    platformLabel: 'TikTok',
                    durationLabel: '0:30',
                    onTap: () => context.pushNamed('/videosList'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicInfoSection(bool isDark) {
    final itemWidth = (MediaQuery.sizeOf(context).width - 32) * 0.45;
    final itemHeight = itemWidth * 1.1;

    if (!_clinicInfoLoaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'He Clinic Info',
              onSeeAll: () => context.pushNamed(HemedInfoWidget.routeName),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: itemHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: itemWidth,
                  child: AppSkeleton.card(
                    height: itemHeight,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.radiusLG),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_clinicInfoErr || _clinicInfos.isEmpty) return const SizedBox.shrink();

    final items = _clinicInfos.take(6).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'He Clinic Info',
            onSeeAll: () => context.pushNamed(HemedInfoWidget.routeName),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: itemHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final item = items[i];
                return SizedBox(
                  width: itemWidth,
                  child: GestureDetector(
                    onTap: item.imageUrl.isEmpty
                        ? null
                        : () => context.pushNamed(HemedInfoWidget.routeName),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                      child: item.imageUrl.isEmpty
                          ? Container(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surface,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
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
}

/// A treatment package shown on the home screen with its session balance.
class _PatientPackage {
  const _PatientPackage({
    required this.name,
    required this.total,
    required this.remaining,
  });

  final String name;
  final int total;
  final int remaining;
}
