import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/step_indicator.dart';
import '../../core/widgets/time_slot_chip.dart';

class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({super.key});

  @override
  State<BookingDateTimeScreen> createState() =>
      _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  final DateTime _today = DateTime.now();
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _firstAllowedDay;

  List<String> _timeSlots = [];
  bool _isLoadingSlots = false;
  bool _hasSlotsError = false;
  int _selectedSlotIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedDay = _today;
    _focusedDay = _today;
    _firstAllowedDay = DateTime(_today.year, _today.month, _today.day);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchTimeSlots(_selectedDay));
  }

  Future<void> _fetchTimeSlots(DateTime day) async {
    if (!mounted) return;
    setState(() {
      _isLoadingSlots = true;
      _hasSlotsError = false;
      _selectedSlotIndex = -1;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      setState(() {
        _timeSlots = _generateSlots(day);
        _isLoadingSlots = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingSlots = false;
        _hasSlotsError = true;
      });
    }
  }

  List<String> _generateSlots(DateTime day) {
    return <String>[
      '9:00 AM',
      '9:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '2:00 PM',
      '2:30 PM',
      '3:00 PM',
      '3:30 PM',
      '4:00 PM',
      '4:30 PM',
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedSlotIndex = -1;
    });
    _fetchTimeSlots(selectedDay);
  }

  void _onMonthPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onContinue() {
    if (_selectedSlotIndex < 0 ||
        _selectedSlotIndex >= _timeSlots.length) return;
    final result = {
      'date': _selectedDay,
      'time': _timeSlots[_selectedSlotIndex],
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Select Date & Time',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: StepIndicator(
              currentStep: 2,
              totalSteps: 4,
              labels: const [
                'Branch',
                'Doctor',
                'Date & Time',
                'Confirm',
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendar(),
                  const SizedBox(height: AppSpacing.space16),
                  _buildMonthLabel(),
                  const SizedBox(height: AppSpacing.space8),
                  _buildSlotsSection(),
                  const SizedBox(height: AppSpacing.space16),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendarSurface =
        isDark ? AppColors.surfaceDark : AppColors.surface;
    final calendarBorder =
        isDark ? AppColors.dividerDark : AppColors.divider;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        0,
      ),
      decoration: BoxDecoration(
        color: calendarSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: calendarBorder),
      ),
      child: TableCalendar(
        firstDay: _firstAllowedDay,
        lastDay: DateTime(_today.year + 1),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onPageChanged: _onMonthPageChanged,
        headerVisible: false,
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.horizontalSwipe,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          defaultTextStyle:
              AppTextStyles.body1.copyWith(color: textColor),
          weekendTextStyle:
              AppTextStyles.body1.copyWith(color: secondaryText),
          outsideTextStyle:
              AppTextStyles.body1.copyWith(color: secondaryText.withOpacity(0.4)),
          todayTextStyle:
              AppTextStyles.body1.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
          selectedTextStyle: AppTextStyles.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              AppTextStyles.caption.copyWith(color: secondaryText),
          weekendStyle:
              AppTextStyles.caption.copyWith(color: secondaryText),
        ),
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (_, day) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildMonthLabel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final monthLabel = '${months[_focusedDay.month - 1]} ${_focusedDay.year}';

    final isAtCurrentMonth = _focusedDay.year == _firstAllowedDay.year &&
        _focusedDay.month == _firstAllowedDay.month;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isAtCurrentMonth
                ? null
                : () {
                    DateTime previous = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      1,
                    );
                    if (previous.isBefore(_firstAllowedDay)) {
                      previous = _firstAllowedDay;
                    }
                    _onMonthPageChanged(previous);
                  },
            child: Icon(
              Icons.chevron_left,
              size: 24,
              color: isAtCurrentMonth
                  ? secondaryText.withOpacity(0.3)
                  : secondaryText,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Text(
            monthLabel,
            style: AppTextStyles.heading3.copyWith(color: textColor),
          ),
          const SizedBox(width: AppSpacing.space12),
          GestureDetector(
            onTap: () {
              final next = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
                1,
              );
              _onMonthPageChanged(next);
            },
            child: Icon(
              Icons.chevron_right,
              size: 24,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsSection() {
    if (_isLoadingSlots) {
      return _buildSlotSkeleton();
    }

    if (_hasSlotsError) {
      return AppErrorState(
        title: 'Failed to load time slots',
        subtitle: 'Please check your connection and try again',
        onRetry: () => _fetchTimeSlots(_selectedDay),
      );
    }

    if (_timeSlots.isEmpty) {
      return const AppEmptyState(
        icon: Icons.schedule,
        title: 'No slots available',
        subtitle: 'Try selecting a different date',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
      ),
      child: Wrap(
        spacing: AppSpacing.space8,
        runSpacing: AppSpacing.space8,
        children: List.generate(_timeSlots.length, (i) {
          return TimeSlotChip(
            time: _timeSlots[i],
            isSelected: _selectedSlotIndex == i,
            onTap: () => setState(() => _selectedSlotIndex = i),
          );
        }),
      ),
    );
  }

  Widget _buildSlotSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
      ),
      child: Wrap(
        spacing: AppSpacing.space8,
        runSpacing: AppSpacing.space8,
        children: List.generate(8, (i) {
          return Container(
            height: 40,
            width: 90 + (i % 3) * 10.0,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius:
                  BorderRadius.circular(AppRadius.radiusSM),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomBg =
        isDark ? AppColors.surfaceDark : AppColors.surface;
    final topBorder =
        isDark ? AppColors.dividerDark : AppColors.divider;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        top: AppSpacing.space12,
        bottom: AppSpacing.space16 +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bottomBg,
        border: Border(top: BorderSide(color: topBorder)),
      ),
      child: AppButton(
        label: 'Continue',
        variant: AppButtonVariant.primary,
        onPressed:
            _selectedSlotIndex >= 0 ? _onContinue : null,
        isFullWidth: true,
      ),
    );
  }
}
