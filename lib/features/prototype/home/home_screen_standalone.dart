import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/core/theme/app_spacing.dart';
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

class HomeScreenContent extends StatelessWidget {
  final void Function(String route) onNavigate;
  const HomeScreenContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientHeroSlider(slides: kHeroSlides)
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space24),
        CompactQuickActions(actions: [
          CompactQuickAction(
            icon: Icons.event_available_outlined,
            label: 'Book Visit',
            tint: const Color(0xFF3B8DFF),
            onTap: () => onNavigate('/booking-branch'),
          ),
          CompactQuickAction(
            icon: Icons.folder_open_outlined,
            label: 'Records',
            tint: const Color(0xFF27F5A3),
            onTap: () => onNavigate('/my-bookings'),
          ),
          CompactQuickAction(
            icon: Icons.video_call_outlined,
            label: 'Telehealth',
            tint: const Color(0xFFF5A623),
            onTap: () => onNavigate('/telehealth'),
          ),
          CompactQuickAction(
            icon: Icons.medical_information_outlined,
            label: 'Packages',
            tint: const Color(0xFF2868F5),
            onTap: () => onNavigate('/packages'),
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
                onSeeAll: () => onNavigate('/my-bookings'),
              ),
              const SizedBox(height: AppSpacing.space12),
              AppointmentCard(
                doctorInitials: 'AR',
                doctorGradient: const [Color(0xFF2868F5), Color(0xFF131C3C)],
                doctorName: 'Dr. Ahmad Rizal',
                specialty: 'General Practitioner',
                branchName: 'TTDI Branch',
                date: '14 Jul 2025',
                time: '10:30 AM',
                status: StatusChipVariant.confirmed,
                countdownDueAt: DateTime.now().add(const Duration(days: 2, hours: 14, minutes: 32)),
                onTap: () => onNavigate('/appointment-detail'),
                onDetailsTap: () => onNavigate('/appointment-detail'),
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
            onRedeem: () => onNavigate('/my-points'),
            onViewHistory: () => onNavigate('/my-points'),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildDoctorsSection(onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space24),
        _buildBranchesSection(onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 600.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildArticlesSection(onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 700.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: AppSpacing.space32),
        _buildVideosSection(onNavigate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideY(begin: 0.05, end: 0),
      ],
    );
  }

  static const kHeroSlides = <GradientHeroSlide>[
    GradientHeroSlide(
      title: 'Book your annual\nhealth check today',
      subtitle: 'Comprehensive screening from RM 199',
      cta: 'Book Now',
      gradient: [Color(0xFF131C3C), Color(0xFF3B8DFF)],
    ),
    GradientHeroSlide(
      title: 'Telehealth consultation\nin minutes',
      subtitle: 'Connect with a doctor from home',
      cta: 'Start Now',
      gradient: [Color(0xFF2868F5), Color(0xFF27F5A3)],
    ),
    GradientHeroSlide(
      title: 'Earn points on every\nclinic visit',
      subtitle: 'Redeem for discounts and rewards',
      cta: 'Learn More',
      gradient: [Color(0xFF1D2B5F), Color(0xFFF5A623)],
    ),
  ];

  static Widget _buildDoctorsSection(void Function(String) nav) {
    const doctors = [
      (name: 'Dr. Sarah Lim', specialty: 'Cardiologist', initials: 'SL',
       gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)]),
      (name: 'Dr. Tan Wei Ming', specialty: 'Dermatologist', initials: 'TW',
       gradient: [Color(0xFFF5A623), Color(0xFFF54636)]),
      (name: 'Dr. Wong Mei Ling', specialty: 'Pediatrician', initials: 'WM',
       gradient: [Color(0xFF27F5A3), Color(0xFF2868F5)]),
      (name: 'Dr. Ahmad Rizal', specialty: 'GP', initials: 'AR',
       gradient: [Color(0xFF2868F5), Color(0xFF131C3C)]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: SectionHeader(title: 'Our Doctors', onSeeAll: () => nav('/doctors-list')),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 180,
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
                  initials: d.initials,
                  avatarGradient: d.gradient,
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

  static Widget _buildBranchesSection(void Function(String) nav) {
    const branches = [
      (name: 'TTDI Clinic', address: 'Jalan Burhanuddin Helmi', distance: '1.2 km',
       gradient: [Color(0xFF131C3C), Color(0xFF1D2B5F)]),
      (name: 'Bangsar Village', address: 'Jalan Telawi 3', distance: '4.8 km',
       gradient: [Color(0xFF3B8DFF), Color(0xFF2868F5)]),
      (name: 'Petaling Jaya', address: 'Jalan Sultan', distance: '6.5 km',
       gradient: [Color(0xFF1D2B5F), Color(0xFF3B8DFF)]),
    ];

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
                  distance: b.distance,
                  leadingGradient: b.gradient,
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

  static Widget _buildArticlesSection(void Function(String) nav) {
    const articles = [
      (category: 'Wellness', title: '10 habits for a healthier heart',
       excerpt: 'Small daily changes that protect your cardiovascular system.',
       author: 'Dr. Sarah Lim', readTime: '4 min read',
       gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)]),
      (category: 'Nutrition', title: 'Mediterranean diet, simplified',
       excerpt: 'A practical starter guide for busy adults living in KL.',
       author: 'Chef Aina Yusof', readTime: '6 min read',
       gradient: [Color(0xFFF5A623), Color(0xFFF54636)]),
      (category: 'Mental Health', title: 'Sleep and stress: the loop',
       excerpt: 'Why poor sleep amplifies anxiety and how to break the cycle.',
       author: 'Dr. Kavita Menon', readTime: '5 min read',
       gradient: [Color(0xFF2868F5), Color(0xFF131C3C)]),
    ];

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
                  imageUrl: '',
                  placeholderGradient: a.gradient,
                  title: a.title,
                  excerpt: a.excerpt,
                  author: a.author,
                  date: a.readTime,
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

  static Widget _buildVideosSection(void Function(String) nav) {
    const videos = [
      (title: 'Understanding your blood pressure', handle: '@heclinic', duration: '2:14',
       gradient: [Color(0xFF3B8DFF), Color(0xFF131C3C)]),
      (title: '5-minute morning stretch routine', handle: '@heclinic', duration: '4:52',
       gradient: [Color(0xFF27F5A3), Color(0xFF2868F5)]),
      (title: 'What to expect at your first visit', handle: '@heclinic', duration: '1:48',
       gradient: [Color(0xFFF5A623), Color(0xFFF54636)]),
      (title: 'Healthy meal prep, KL edition', handle: '@heclinic', duration: '3:21',
       gradient: [Color(0xFF1D2B5F), Color(0xFF3B8DFF)]),
    ];

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
                thumbnailUrl: '',
                placeholderGradient: v.gradient,
                title: v.title,
                author: v.handle,
                durationLabel: v.duration,
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
}
