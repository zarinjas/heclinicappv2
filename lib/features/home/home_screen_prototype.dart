// Home Screen Prototype
//
// Standalone visual prototype for the new He Clinic V2 Home experience.
// Purpose: validate visual design only. No API, no providers, no repositories,
// no business logic. All data is hardcoded. All images are colored gradient
// containers.
//
// Run with:
//   flutter run -t lib/features/home/home_prototype_runner.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_shadows.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

// ============================================================================
// HARDCODED DUMMY DATA
// ============================================================================

const _kUserName = 'Alia Rahman';
const _kUserInitials = 'AR';

final _kUpcomingAt = DateTime.now().add(
  const Duration(days: 2, hours: 14, minutes: 32),
);

const _kAppointment = _AppointmentData(
  doctorName: 'Dr. Ahmad Rizal',
  specialty: 'General Practitioner',
  branch: 'TTDI Branch',
  status: 'Confirmed',
  initials: 'AR',
);

const _kLoyalty = _LoyaltyData(
  balance: 2450,
  tier: 'Gold Member',
  nextTierAt: 3000,
);

const _kHeroSlides = <_HeroSlide>[
  _HeroSlide(
    title: 'Book your annual\nhealth check today',
    subtitle: 'Comprehensive screening from RM 199',
    cta: 'Book Now',
    gradient: [Color(0xFF131C3C), Color(0xFF3B8DFF)],
  ),
  _HeroSlide(
    title: 'Telehealth consultation\nin minutes',
    subtitle: 'Connect with a doctor from home',
    cta: 'Start Now',
    gradient: [Color(0xFF2868F5), Color(0xFF27F5A3)],
  ),
  _HeroSlide(
    title: 'Earn points on every\nclinic visit',
    subtitle: 'Redeem for discounts and rewards',
    cta: 'Learn More',
    gradient: [Color(0xFF1D2B5F), Color(0xFFF5A623)],
  ),
];

const _kQuickActions = <_QuickAction>[
  _QuickAction(
    icon: Icons.event_available_outlined,
    label: 'Book Visit',
    tint: Color(0xFF3B8DFF),
  ),
  _QuickAction(
    icon: Icons.folder_open_outlined,
    label: 'Records',
    tint: Color(0xFF27F5A3),
  ),
  _QuickAction(
    icon: Icons.video_call_outlined,
    label: 'Telehealth',
    tint: Color(0xFFF5A623),
  ),
  _QuickAction(
    icon: Icons.medical_information_outlined,
    label: 'Packages',
    tint: Color(0xFF2868F5),
  ),
];

const _kArticles = <_ArticleData>[
  _ArticleData(
    category: 'Wellness',
    title: '10 habits for a healthier heart',
    excerpt: 'Small daily changes that protect your cardiovascular system.',
    author: 'Dr. Sarah Lim',
    readTime: '4 min read',
    gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
  ),
  _ArticleData(
    category: 'Nutrition',
    title: 'Mediterranean diet, simplified',
    excerpt: 'A practical starter guide for busy adults living in KL.',
    author: 'Chef Aina Yusof',
    readTime: '6 min read',
    gradient: [Color(0xFFF5A623), Color(0xFFF54636)],
  ),
  _ArticleData(
    category: 'Mental Health',
    title: 'Sleep and stress: the loop',
    excerpt: 'Why poor sleep amplifies anxiety and how to break the cycle.',
    author: 'Dr. Kavita Menon',
    readTime: '5 min read',
    gradient: [Color(0xFF2868F5), Color(0xFF131C3C)],
  ),
];

const _kVideos = <_VideoData>[
  _VideoData(
    title: 'Understanding your blood pressure numbers',
    handle: '@heclinic',
    duration: '2:14',
    gradient: [Color(0xFF3B8DFF), Color(0xFF131C3C)],
  ),
  _VideoData(
    title: '5-minute morning stretch routine',
    handle: '@heclinic',
    duration: '4:52',
    gradient: [Color(0xFF27F5A3), Color(0xFF2868F5)],
  ),
  _VideoData(
    title: 'What to expect at your first visit',
    handle: '@heclinic',
    duration: '1:48',
    gradient: [Color(0xFFF5A623), Color(0xFFF54636)],
  ),
  _VideoData(
    title: 'Healthy meal prep, KL edition',
    handle: '@heclinic',
    duration: '3:21',
    gradient: [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
  ),
];

// ============================================================================
// DATA MODELS
// ============================================================================

class _AppointmentData {
  final String doctorName;
  final String specialty;
  final String branch;
  final String status;
  final String initials;
  const _AppointmentData({
    required this.doctorName,
    required this.specialty,
    required this.branch,
    required this.status,
    required this.initials,
  });
}

class _LoyaltyData {
  final int balance;
  final String tier;
  final int nextTierAt;
  const _LoyaltyData({
    required this.balance,
    required this.tier,
    required this.nextTierAt,
  });
}

class _HeroSlide {
  final String title;
  final String subtitle;
  final String cta;
  final List<Color> gradient;
  const _HeroSlide({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.gradient,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color tint;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tint,
  });
}

class _ArticleData {
  final String category;
  final String title;
  final String excerpt;
  final String author;
  final String readTime;
  final List<Color> gradient;
  const _ArticleData({
    required this.category,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.readTime,
    required this.gradient,
  });
}

class _VideoData {
  final String title;
  final String handle;
  final String duration;
  final List<Color> gradient;
  const _VideoData({
    required this.title,
    required this.handle,
    required this.duration,
    required this.gradient,
  });
}

// ============================================================================
// PROTOTYPE SCREEN
// ============================================================================

class HomeScreenPrototype extends StatefulWidget {
  const HomeScreenPrototype({super.key});

  @override
  State<HomeScreenPrototype> createState() => _HomeScreenPrototypeState();
}

class _HomeScreenPrototypeState extends State<HomeScreenPrototype> {
  int _navIndex = 0;

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
                const _TopHeader(),
                const SizedBox(height: AppSpacing.space24),
                const _HeroBannerSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space24),
                const _QuickActionsSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                _UpcomingAppointmentSection(dueAt: _kUpcomingAt)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                const _LoyaltySection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                const _ArticlesSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.space32),
                const _VideosSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms)
                    .slideY(begin: 0.05, end: 0),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _FloatingBottomNav(
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
}

// ============================================================================
// TOP HEADER (curved primary panel with avatar, greeting, notification bell)
// ============================================================================

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radius2XL),
          bottomRight: Radius.circular(AppRadius.radius2XL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space20,
            AppSpacing.space16,
            AppSpacing.space20,
            AppSpacing.space24,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentBlue],
                  ),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  _kUserInitials,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _kUserName,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const _NotificationBell(count: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  const _NotificationBell({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// HERO BANNER (auto-scroll 4s, dot indicator)
// ============================================================================

class _HeroBannerSection extends StatefulWidget {
  const _HeroBannerSection();

  @override
  State<_HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<_HeroBannerSection> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_current + 1) % _kHeroSlides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _kHeroSlides.length,
            itemBuilder: (_, i) {
              final slide = _kHeroSlides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _HeroCard(slide: slide),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kHeroSlides.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent
                    : AppColors.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _HeroSlide slide;
  const _HeroCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
        boxShadow: AppShadows.shadowMid,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      slide.subtitle,
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppRadius.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slide.cta,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACTIONS (row of 4 tiles)
// ============================================================================

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: Row(
        children: [
          for (int i = 0; i < _kQuickActions.length; i++) ...[
            Expanded(child: _QuickActionTile(action: _kQuickActions[i])),
            if (i < _kQuickActions.length - 1)
              const SizedBox(width: AppSpacing.space12),
          ]
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space16,
            horizontal: AppSpacing.space8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppShadows.shadowLow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.action.tint.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppRadius.radiusFull),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.action.icon,
                  color: widget.action.tint,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// UPCOMING APPOINTMENT with live countdown
// ============================================================================

class _UpcomingAppointmentSection extends StatelessWidget {
  final DateTime dueAt;
  const _UpcomingAppointmentSection({required this.dueAt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Upcoming Appointment',
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.space12),
          _AppointmentCard(data: _kAppointment, dueAt: dueAt),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final _AppointmentData data;
  final DateTime dueAt;
  const _AppointmentCard({required this.data, required this.dueAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  data.initials,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.doctorName,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.specialty,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.branch,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusChip(label: data.status),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEFF6FF),
                  Color(0xFFECFDF5),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.space8),
                Text(
                  'Starts in',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                _Countdown(dueAt: dueAt),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Details',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  final DateTime dueAt;
  const _Countdown({required this.dueAt});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.dueAt.difference(DateTime.now());
    final d = diff.inDays;
    final h = diff.inHours.remainder(24);
    final m = diff.inMinutes.remainder(60);
    final label = d > 0
        ? '${d}d ${h}h ${m}m'
        : h > 0
            ? '${h}h ${m}m'
            : '${m}m';
    return Text(
      label,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipConfirmedBg,
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.chipConfirmedText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.chipConfirmedText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOYALTY CARD (gradient premium card)
// ============================================================================

class _LoyaltySection extends StatelessWidget {
  const _LoyaltySection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: _LoyaltyCard(data: _kLoyalty),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  final _LoyaltyData data;
  const _LoyaltyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final progress = data.balance / data.nextTierAt;
    final remaining = data.nextTierAt - data.balance;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pointsGradientStart,
            AppColors.pointsGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
        boxShadow: AppShadows.shadowMid,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tierGold.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppRadius.radiusFull),
                      border: Border.all(
                        color: AppColors.tierGold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.tierGold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.tier,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.tierGold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatNumber(data.balance),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'pts',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Patient Appreciation Points',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.tierGold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                '$remaining pts to Platinum tier',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              const Row(
                children: [
                  Expanded(
                    child: _GhostWhiteButton(
                      label: 'Redeem',
                      icon: Icons.redeem_outlined,
                      solid: true,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: _GhostWhiteButton(
                      label: 'History',
                      icon: Icons.history_rounded,
                      solid: false,
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
}

String _formatNumber(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _GhostWhiteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool solid;
  const _GhostWhiteButton({
    required this.label,
    required this.icon,
    required this.solid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: solid ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        border: Border.all(
          color: solid ? Colors.white : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: solid ? AppColors.primary : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: solid ? AppColors.primary : Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// ARTICLES SECTION (horizontal scroll)
// ============================================================================

class _ArticlesSection extends StatelessWidget {
  const _ArticlesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          child: _SectionHeader(
            title: 'Health Articles',
            onSeeAll: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          height: 296,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space20),
            itemCount: _kArticles.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.space12),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: _ArticleCard(data: _kArticles[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _ArticleData data;
  const _ArticleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradient,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radiusLG),
                    topRight: Radius.circular(AppRadius.radiusLG),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.space12,
                left: AppSpacing.space12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppRadius.radiusSM),
                  ),
                  child: Text(
                    data.category,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    data.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: data.gradient),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        '· ${data.readTime}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VIDEOS SECTION (2 column grid)
// ============================================================================

class _VideosSection extends StatelessWidget {
  const _VideosSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Featured Videos', onSeeAll: () {}),
          const SizedBox(height: AppSpacing.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kVideos.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.space12,
              mainAxisSpacing: AppSpacing.space12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) => _VideoCard(data: _kVideos[i]),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _VideoData data;
  const _VideoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: data.gradient,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.radiusLG),
                      topRight: Radius.circular(AppRadius.radiusLG),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.shadowMid,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius:
                        BorderRadius.circular(AppRadius.radiusXS),
                  ),
                  child: Text(
                    data.duration,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.handle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FLOATING PILL BOTTOM NAV
// ============================================================================

class _NavItem {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool showBadge;
  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    this.showBadge = false,
  });
}

const _kNavItems = <_NavItem>[
  _NavItem(
    icon: Icons.home_outlined,
    iconActive: Icons.home_rounded,
    label: 'Home',
  ),
  _NavItem(
    icon: Icons.calendar_today_outlined,
    iconActive: Icons.calendar_today_rounded,
    label: 'Visits',
  ),
  _NavItem(
    icon: Icons.favorite_border_rounded,
    iconActive: Icons.favorite_rounded,
    label: 'Health',
  ),
  _NavItem(
    icon: Icons.notifications_outlined,
    iconActive: Icons.notifications_rounded,
    label: 'Alerts',
    showBadge: true,
  ),
  _NavItem(
    icon: Icons.person_outline_rounded,
    iconActive: Icons.person_rounded,
    label: 'Profile',
  ),
];

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33131C3C),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_kNavItems.length, (i) {
          final item = _kNavItems[i];
          final active = i == currentIndex;
          return _NavButton(
            item: item,
            active: active,
            onTap: () => onTap(i),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? item.iconActive : item.icon,
                  color: active
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
                if (item.showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

