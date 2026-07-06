import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../core/widgets/time_slot_chip.dart';

class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({super.key});

  @override
  State<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  int _selectedDate = -1;
  int _selectedSlot = -1;

  static const _availableDates = {8, 9, 14, 15, 16, 20, 21, 22, 28, 29};

  static const _timeSlots = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '2:00 PM', '2:30 PM',
    '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
  ];

  static const _dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<int?> _buildCalendarDays() {
    final days = List<int?>.filled(35, null);
    int day = 1;
    for (int i = 3; i < 34 && day <= 31; i++) {
      days[i] = day++;
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final calDays = _buildCalendarDays();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Date & Time'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space24,
              AppSpacing.space16,
              AppSpacing.space24,
              AppSpacing.space16,
            ),
            child: const StepIndicator(
              currentStep: 3,
              totalSteps: 4,
              labels: ['Branch', 'Doctor', 'Time', 'Confirm'],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 28),
                    Text(
                      'July 2026',
                      style: AppTextStyles.heading3,
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 28),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: _dayHeaders.map((d) => Expanded(
                          child: Center(
                            child: Text(d, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      ...List.generate(5, (row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                          child: Row(
                            children: List.generate(7, (col) {
                              final idx = row * 7 + col;
                              final day = calDays[idx];
                              if (day == null) return const Expanded(child: SizedBox.shrink());

                              final isAvailable = _availableDates.contains(day);
                              final isSelected = _selectedDate == day;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: isAvailable
                                      ? () => setState(() => _selectedDate = day)
                                      : null,
                                  child: Container(
                                    height: 36,
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.accent
                                          : (isAvailable ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$day',
                                      style: AppTextStyles.body2.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : (isAvailable ? AppColors.accent : AppColors.textSecondary),
                                        fontWeight: isAvailable ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                const SectionHeader(title: 'Available Slots'),
                const SizedBox(height: AppSpacing.space12),
                Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space8,
                  children: List.generate(_timeSlots.length, (index) {
                    return TimeSlotChip(
                      time: _timeSlots[index],
                      isSelected: _selectedSlot == index,
                      onTap: () => setState(() => _selectedSlot = index),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: AppButton.primary(
            label: 'Continue',
            onPressed: _selectedSlot >= 0
                ? () => Navigator.pushNamed(context, '/booking-confirm')
                : null,
          ),
        ),
      ),
    );
  }
}
