import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/services/hero_service.dart';
import '/core/services/doctor_service.dart';
import '/core/services/branch_service.dart';
import '/core/services/article_service.dart';
import '/core/services/video_service.dart';
import '/core/services/models/hero_banner.dart';
import '/core/services/models/doctor.dart';
import '/core/services/models/branch.dart';
import '/core/services/models/article.dart';
import '/core/services/models/video.dart';
import '/core/widgets/appointment_card.dart';
import '/core/widgets/app_chip.dart';
import '/core/widgets/article_card.dart';
import '/core/widgets/branch_card.dart';
import '/core/widgets/compact_quick_actions.dart';
import '/core/widgets/doctor_card.dart';
import '/core/widgets/gradient_hero_slider.dart';
import '/core/widgets/loyalty_card.dart';
import '/core/widgets/section_header.dart';
import '/core/widgets/video_card.dart';

class HomeScreenContent extends StatefulWidget {
  final void Function(String route) onNavigate;
  const HomeScreenContent({super.key, required this.onNavigate});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  List<HeroBanner> _heroBanners = HeroBanner.fallbackList;
  List<Doctor> _doctors = Doctor.fallbackList;
  List<Branch> _branches = Branch.fallbackList;
  List<Article> _articles = Article.fallbackList;
  List<Video> _videos = Video.fallbackList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (!mounted) return;
    setState(() {
      _heroBanners = HeroService.instance.banners;
      _doctors = DoctorService.instance.doctors;
      _branches = BranchService.instance.branches;
      _articles = ArticleService.instance.articles;
      _videos = VideoService.instance.videos;
    });
    debugPrint('[HomeScreen] loaded ${_doctors.length} doctors, ${_branches.length} branches');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientHeroSlider(
          slides: _heroBanners.map((b) => GradientHeroSlide(
            title: b.title,
            subtitle: b.subtitle,
            cta: b.cta,
            gradient: b.gradient,
          )).toList(),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space24),
        CompactQuickActions(actions: [
          CompactQuickAction(
            icon: Icons.event_available_outlined,
            label: 'Book Visit',
            tint: const Color(0xFF3B8DFF),
            onTap: () => widget.onNavigate('/booking-branch'),
          ),
          CompactQuickAction(
            icon: Icons.folder_open_outlined,
            label: 'Records',
            tint: const Color(0xFF27F5A3),
            onTap: () => widget.onNavigate('/my-bookings'),
          ),
          CompactQuickAction(
            icon: Icons.video_call_outlined,
            label: 'Telehealth',
            tint: const Color(0xFFF5A623),
            onTap: () => widget.onNavigate('/telehealth'),
          ),
          CompactQuickAction(
            icon: Icons.medical_information_outlined,
            label: 'Packages',
            tint: const Color(0xFF2868F5),
            onTap: () => widget.onNavigate('/packages'),
          ),
        ])
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Upcoming Appointment',
                onSeeAll: () => widget.onNavigate('/my-bookings'),
              ),
              const SizedBox(height: AppSpacing.space12),
              AppointmentCard(
                doctorPhotoUrl: _doctors.isNotEmpty ? _doctors.first.photoUrl : null,
                doctorInitials: _doctors.isNotEmpty ? _doctors.first.initials : '?',
                doctorGradient: _doctors.isNotEmpty ? _doctors.first.avatarGradient : const [AppColors.accent, AppColors.primary],
                doctorName: _doctors.isNotEmpty ? _doctors.first.name : 'No doctor available',
                specialty: _doctors.isNotEmpty ? _doctors.first.specialty : '',
                branchName: _branches.isNotEmpty ? _branches.first.name : 'No branch',
                date: '${DateTime.now().add(const Duration(days: 2)).day} Jul ${DateTime.now().year}',
                time: '10:30 AM',
                status: StatusChipVariant.confirmed,
                countdownDueAt: DateTime.now().add(const Duration(days: 2, hours: 14, minutes: 32)),
                onTap: () => widget.onNavigate('/appointment-detail'),
                onDetailsTap: () => widget.onNavigate('/appointment-detail'),
                onAddToCalendar: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to calendar'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: LoyaltyCard(
            pointsBalance: 2450,
            tier: LoyaltyTier.gold,
            showProgress: true,
            progressValue: 2450 / 3000,
            progressLabel: '550 pts to Platinum tier',
            onRedeem: () => widget.onNavigate('/my-points'),
            onViewHistory: () => widget.onNavigate('/my-points'),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildVouchersSection(context, widget.onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 450.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildDoctorsSection(widget.onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space24),
        _buildBranchesSection(widget.onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 600.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildArticlesSection(widget.onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 700.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildVideosSection(widget.onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideY(begin: 0.05, end: 0),
      ],
    );
  }

  Widget _buildDoctorsSection(void Function(String) nav) {
    final doctors = _doctors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: SectionHeader(title: 'Our Doctors', onSeeAll: () => nav('/doctors-list')),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space12),
            itemBuilder: (_, i) {
              final d = doctors[i];
              return SizedBox(
                width: 120,
                child: DoctorCard(
                  photoUrl: d.photoUrl,
                  initials: d.initials,
                  avatarGradient: d.avatarGradient,
                  name: d.name,
                  specialty: d.specialty,
                  variant: DoctorCardVariant.horizontal,
                  onTap: () => nav('/doctor-detail'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBranchesSection(void Function(String) nav) {
    final branches = _branches;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: SectionHeader(title: 'Our Clinics', onSeeAll: () => nav('/branch-detail')),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
            itemCount: branches.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space12),
            itemBuilder: (_, i) {
              final b = branches[i];
              return SizedBox(
                width: 240,
                child: BranchCard(
                  name: b.name,
                  address: b.address,
                  imageUrl: b.imageUrl,
                  leadingGradient: b.leadingGradient,
                  leadingLabel: 'Clinic',
                  onTap: () => nav('/branch-detail'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection(void Function(String) nav) {
    final articles = _articles.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: SectionHeader(title: 'Health Articles', onSeeAll: () => nav('/articles-list')),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 296,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space12),
            itemBuilder: (_, i) {
              final a = articles[i];
              return SizedBox(
                width: 220,
                child: ArticleCard(
                  imageUrl: a.featuredImage ?? '',
                  placeholderGradient: a.placeholderGradient,
                  title: a.title,
                  excerpt: a.excerpt,
                  author: a.authorName ?? '',
                  date: a.dateDisplay,
                  categoryLabel: a.category,
                  onTap: () => nav('/article-detail'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideosSection(void Function(String) nav) {
    final videos = _videos.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Featured Videos', onSeeAll: () => nav('/videos-list')),
          const SizedBox(height: AppSpacing.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.space12,
              mainAxisSpacing: AppSpacing.space12,
              childAspectRatio: 0.45,
            ),
            itemBuilder: (_, i) {
              final v = videos[i];
              return VideoCard(
                thumbnailUrl: v.thumbnailUrl ?? '',
                placeholderGradient: v.placeholderGradient,
                title: v.title,
                author: v.author,
                videoAspectRatio: 9 / 16,
                platformLabel: 'TikTok',
                onTap: () => nav('/videos-list'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVouchersSection(BuildContext context, void Function(String) nav) {
    const vouchers = [
      (discount: 'RM 30 OFF', title: 'Basic Health Screening', expiry: '3 days left',
       gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)], isLimited: true),
      (discount: '20% OFF', title: 'GP Consultation', expiry: '7 days left',
       gradient: [Color(0xFF131C3C), Color(0xFF3B8DFF)], isLimited: false),
      (discount: 'FREE', title: 'Blood Pressure Check', expiry: '14 days left',
       gradient: [Color(0xFF27F5A3), Color(0xFF2868F5)], isLimited: false),
      (discount: 'RM 50 OFF', title: 'Comprehensive Health Check', expiry: '5 days left',
       gradient: [Color(0xFFF5A623), Color(0xFFF54636)], isLimited: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: SectionHeader(title: 'Deals & Vouchers', onSeeAll: () => nav('/vouchers')),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space12),
            itemBuilder: (_, i) {
              final v = vouchers[i];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Voucher claimed: ${v.title}'),
                      backgroundColor: AppColors.primary,
                      action: SnackBarAction(
                        label: 'My Vouchers',
                        textColor: AppColors.accent,
                        onPressed: () => nav('/my-vouchers'),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: v.gradient,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -10,
                        bottom: -10,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (v.isLimited)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Limited',
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  v.discount,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    fontFamilyFallback: ['sans-serif'],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 12, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  v.expiry,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                                  ),
                                  child: Text(
                                    'Claim',
                                    style: AppTextStyles.caption.copyWith(
                                      color: v.gradient[0],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
