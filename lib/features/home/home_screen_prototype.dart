import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
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
import '/core/widgets/floating_bottom_nav.dart';
import '/core/widgets/gradient_hero_slider.dart';
import '/core/widgets/home_header.dart';
import '/core/widgets/loyalty_card.dart';
import '/core/widgets/section_header.dart';
import '/core/widgets/video_card.dart';
import 'home_mock_data.dart';

class HomeScreenPrototype extends StatefulWidget {
  const HomeScreenPrototype({super.key});

  @override
  State<HomeScreenPrototype> createState() => _HomeScreenPrototypeState();
}

class _HomeScreenPrototypeState extends State<HomeScreenPrototype> {
  int _navIndex = 0;

  List<HeroBanner> _heroBanners = HeroBanner.fallbackList;
  List<Doctor> _doctors = Doctor.fallbackList;
  List<Branch> _branches = Branch.fallbackList;
  List<Article> _articles = Article.fallbackList;
  List<Video> _videos = Video.fallbackList;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await Future.wait([
      HeroService.instance.init(),
      DoctorService.instance.init(),
      BranchService.instance.init(),
      ArticleService.instance.init(),
      VideoService.instance.init(),
    ]);

    if (mounted) {
      setState(() {
        _heroBanners = HeroService.instance.banners;
        _doctors = DoctorService.instance.doctors;
        _branches = BranchService.instance.branches;
        _articles = ArticleService.instance.articles;
        _videos = VideoService.instance.videos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  userInitials: kUserInitials,
                  userName: kUserName,
                  notificationCount: 3,
                ),
                const SizedBox(height: AppSpacing.space24),
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
                const CompactQuickActions(actions: [
                  CompactQuickAction(
                    icon: Icons.event_available_outlined,
                    label: 'Book Visit',
                    tint: Color(0xFF3B8DFF),
                  ),
                  CompactQuickAction(
                    icon: Icons.folder_open_outlined,
                    label: 'Records',
                    tint: Color(0xFF27F5A3),
                  ),
                  CompactQuickAction(
                    icon: Icons.video_call_outlined,
                    label: 'Telehealth',
                    tint: Color(0xFFF5A623),
                  ),
                  CompactQuickAction(
                    icon: Icons.medical_information_outlined,
                    label: 'Packages',
                    tint: Color(0xFF2868F5),
                  ),
                ])
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Upcoming Appointment'),
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
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space20),
                  child: LoyaltyCard(
                    pointsBalance: 2450,
                    tier: LoyaltyTier.gold,
                    showProgress: true,
                    progressValue: 2450 / 3000,
                    progressLabel: '550 pts to Platinum tier',
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                _buildDoctorsSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space24),
                _buildBranchesSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                _buildArticlesSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 700.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                _buildVideosSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 800.ms)
                    .slideY(begin: 0.05, end: 0),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingBottomNav(
                  currentIndex: _navIndex,
                  onTap: (i) => setState(() => _navIndex = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    final doctors = _doctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: const SectionHeader(title: 'Our Doctors'),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 200,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBranchesSection() {
    final branches = _branches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: const SectionHeader(title: 'Our Clinics'),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection() {
    final articles = _articles.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: const SectionHeader(title: 'Health Articles'),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideosSection() {
    final videos = _videos.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Featured Videos'),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

