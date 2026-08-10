import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/loyalty_api.dart';
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
import '/core/services/notification_inbox_service.dart';
import '/core/services/models/article.dart';
import '/core/services/models/doctor.dart';
import '/core/services/models/branch.dart';
import '/core/services/models/hero_banner.dart';
import '/core/services/models/video.dart';
import '/core/services/models/promotion.dart';
import '/core/widgets/app_app_bar.dart';
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
import '/core/widgets/section_header.dart';
import '/core/widgets/video_card.dart';
import '/components/doctor_detail_sheet.dart';
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
  bool _loyaltyLoaded = false;

  bool _heroErr = false;
  bool _apptErr = false;
  bool _docErr = false;
  bool _branchErr = false;
  bool _articleErr = false;
  bool _videoErr = false;
  bool _loyaltyErr = false;

  List<HeroBanner> _heroes = HeroBanner.fallbackList;
  List<Doctor> _doctors = Doctor.fallbackList;
  List<Branch> _branches = Branch.fallbackList;
  List<Article> _articles = Article.fallbackList;
  List<Video> _videos = Video.fallbackList;
  List<Promotion> _promos = Promotion.fallbackList;

  int _loyaltyBalance = 0;

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
      _loadLoyalty(),
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
      _apptResponse = await GetAppointmentUpcomingCall.call(patientId: id);
      if (mounted) setState(() {
        _apptLoaded = true;
        _apptErr = !(_apptResponse?.succeeded ?? false);
      });
    } catch (_) {
      if (mounted) setState(() { _apptLoaded = true; _apptErr = true; });
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
      await PromotionService.instance.init();
      if (mounted) setState(() {
        _promos = PromotionService.instance.promotions;
        _promoLoaded = true;
      });
    } catch (_) {
      _promoLoaded = true;
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
                _buildVouchersSection(isDark),
                _buildDoctorsSection(isDark),
                _buildBranchesSection(isDark),
                _buildArticlesSection(isDark),
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
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = items[i];
                final gradient = p.placeholderGradient;
                final discount = p.ctaText ?? p.promoCode ?? p.title;
                final isLimited = i.isEven;
                final expiry = isLimited ? '3 days left' : '7 days left';
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLimited)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                                    const SizedBox(width: 3),
                                    const Text('Limited', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            Text(
                              discount,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body2.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(expiry, style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
          SectionHeader(title: 'Our Branch', onSeeAll: () => context.pushNamed('/branch-detail')),
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
                  onTap: () => context.pushNamed('/branch-detail'),
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
}
