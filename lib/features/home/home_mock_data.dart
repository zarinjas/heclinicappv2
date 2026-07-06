import 'package:flutter/material.dart';

import '/core/widgets/gradient_hero_slider.dart';

const kUserName = 'Alia Rahman';
const kUserInitials = 'AR';

final kUpcomingAt = DateTime.now().add(const Duration(days: 2, hours: 14, minutes: 32));

const kHeroSlides = <GradientHeroSlide>[
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

const kDoctorInitials = 'AR';
const kDoctorGradient = [Color(0xFF2868F5), Color(0xFF131C3C)];
