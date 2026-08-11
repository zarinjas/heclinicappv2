import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '/backend/api_requests/api_calls.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_radius.dart';
import '/core/widgets/app_button.dart';
import 'booking_flow_model.dart';

class DateTimeSlotSelectionScreenWidget extends StatefulWidget {
  const DateTimeSlotSelectionScreenWidget({super.key});

  static const String routeName = 'dateTimeSlotSelectionScreen';
  static const String routePath = '/dateTimeSlotSelection';

  @override
  State<DateTimeSlotSelectionScreenWidget> createState() =>
      _DateTimeSlotSelectionScreenWidgetState();
}

class _DateTimeSlotSelectionScreenWidgetState
    extends State<DateTimeSlotSelectionScreenWidget> {
  final BookingFlowModel _bookingModel = BookingFlowModel();

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<String> _availableSlots = [];
  String? _selectedSlot;
  Set<DateTime> _daysWithSlots = {};

  bool _isLoadingSlots = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _bookingModel.selectedDate;
  }

  bool _isFutureMonth(DateTime month) {
    final now = DateTime.now();
    final firstOfFocus = DateTime(month.year, month.month);
    final firstOfCurrent = DateTime(now.year, now.month);
    return !firstOfFocus.isBefore(firstOfCurrent);
  }

  void _onPageChanged(DateTime focusedDay) {
    if (!_isFutureMonth(focusedDay)) {
      return;
    }
    if (focusedDay.year != _focusedDay.year ||
        focusedDay.month != _focusedDay.month) {
      setState(() {
        _focusedDay = focusedDay;
        _availableSlots = [];
        _selectedSlot = null;
        _daysWithSlots = {};
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _availableSlots = [];
        _selectedSlot = null;
      });
      _fetchSlots(selectedDay);
    }
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _fetchSlots(DateTime day) async {
    setState(() {
      _isLoadingSlots = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final monthStr = _formatMonth(day);
      final calendarColors = await _getCalendarColors();

      final response = await PostAppointmentSlotsCall.call(
        month: monthStr,
        checkForConflicts: calendarColors,
        simultaneous: 1,
        interval: 15,
        starttime: '08:00',
        endtime: '18:00',
      );

      if (response.succeeded) {
        final slots = PostAppointmentSlotsCall.slots(response.jsonBody) ?? [];

        final slotsForDay = <String>[];
        final targetDateStr =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

        for (final slot in slots) {
          if (slot.startsWith(targetDateStr)) {
            final timePart = slot.contains('T')
                ? slot.split('T').last.substring(0, 5)
                : slot;
            slotsForDay.add(timePart);
          }
        }

        setState(() {
          _availableSlots = slotsForDay;
          if (slotsForDay.isNotEmpty) {
            _daysWithSlots = {..._daysWithSlots, _normalizeDay(day)};
          }
          _isLoadingSlots = false;
        });
      } else {
        setState(() {
          _isLoadingSlots = false;
          _hasError = true;
          _errorMessage =
              'Error ${response.statusCode}: Failed to load time slots';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  Future<List<String>> _getCalendarColors() async {
    try {
      final response = await GetAppointmentCodeCall.call();
      if (response.succeeded) {
        return GetAppointmentCodeCall.codes(response.jsonBody) ?? [];
      }
    } catch (_) {}
    return [];
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    return error?.toString() ?? 'An unexpected error occurred';
  }

  void _onContinuePressed() {
    if (_selectedSlot != null && _selectedDay != null) {
      _bookingModel.selectDateTime(
        date: _selectedDay!,
        time: _selectedSlot!,
        slotId: _selectedSlot!,
      );
      context.push('/bookingConfirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = AppColors.accent;
    final stepIndicator = _buildStepIndicator(accentColor);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Appointment',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              0,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            child: stepIndicator,
          ),
          Expanded(
            child: _buildBody(isDark, accentColor),
          ),
          _buildContinueButton(isDark, accentColor),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color accentColor) {
    final steps = [
      _StepData(1, 'Branch', false),
      _StepData(2, 'Doctor', false),
      _StepData(3, 'Date & Time', true),
      _StepData(4, 'Confirm', false),
    ];

    return Row(
      children: steps.map((step) {
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isActive ? accentColor : Colors.white,
                  border: Border.all(
                    color: step.isActive ? accentColor : Colors.white54,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${step.number}',
                  style: AppTextStyles.caption.copyWith(
                    color: step.isActive ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: AppTextStyles.caption.copyWith(
                  color: step.isActive ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: step.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBody(bool isDark, Color accentColor) {
    return Column(
      children: [
        _buildMonthHeader(isDark, accentColor),
        _buildCalendar(isDark, accentColor),
        const SizedBox(height: AppSpacing.space16),
        if (_selectedDay != null) _buildSelectedDateLabel(isDark),
        const SizedBox(height: AppSpacing.space8),
        Expanded(child: _buildSlotSection(isDark, accentColor)),
      ],
    );
  }

  Widget _buildMonthHeader(bool isDark, Color accentColor) {
    final canGoBack = _canGoToPreviousMonth();
    final canGoForward = _canGoToNextMonth();
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final disabledColor =
        isDark ? AppColors.dividerDark : const Color(0xFFD1D5DB);

    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: canGoBack ? textColor : disabledColor,
            ),
            onPressed: canGoBack
                ? () {
                    final prev = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    onPageChanged(prev);
                  }
                : null,
          ),
          Text(
            _formatMonth(_focusedDay),
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              color: textColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: textColor),
            onPressed: canGoForward
                ? () {
                    final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    onPageChanged(next);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  bool _canGoToPreviousMonth() {
    final now = DateTime.now();
    final firstOfFocus = DateTime(_focusedDay.year, _focusedDay.month);
    final firstOfCurrent = DateTime(now.year, now.month);
    return firstOfFocus.isAfter(firstOfCurrent);
  }

  bool _canGoToNextMonth() {
    return true;
  }

  void onPageChanged(DateTime focusedDay) {
    if (_focusedDay.year != focusedDay.year ||
        _focusedDay.month != focusedDay.month) {
      _onPageChanged(focusedDay);
    }
  }

  Widget _buildCalendar(bool isDark, Color accentColor) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Container(
      color: surface,
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            _availableSlots = [];
            _selectedSlot = null;
            _daysWithSlots = {};
          });
        },
        headerVisible: false,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(
            color: textColor,
          ),
          defaultTextStyle: TextStyle(
            color: textColor,
          ),
          outsideDaysVisible: false,
          markerDecoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.body2.copyWith(
            color: secondaryText,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: AppTextStyles.body2.copyWith(
            color: secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final normalized = _normalizeDay(date);
            if (_daysWithSlots.contains(normalized)) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDateLabel(bool isDark) {
    final hasSlots = _availableSlots.isNotEmpty;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final activeColor = hasSlots ? textColor : secondaryText;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: activeColor,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDate(_selectedDay!),
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSection(bool isDark, Color accentColor) {
    if (_isLoadingSlots) {
      return _buildSkeletonLoader(isDark);
    }
    if (_hasError) {
      return _buildErrorState(isDark, accentColor);
    }
    if (_selectedDay == null) {
      return _buildSelectDayPrompt(isDark);
    }
    if (_availableSlots.isEmpty) {
      return _buildEmptySlots(isDark, accentColor);
    }
    return _buildSlotChips(isDark, accentColor);
  }

  Widget _buildSelectDayPrompt(bool isDark) {
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              size: 48,
              color: secondaryText,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Select a date to view available time slots',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark) {
    final skeleton = isDark ? AppColors.dividerDark : AppColors.divider;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(8, (_) {
          return Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: skeleton,
              borderRadius: BorderRadius.circular(AppRadius.radiusSM),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Color accentColor) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Failed to load time slots',
              style: AppTextStyles.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              _errorMessage,
              style: AppTextStyles.body1.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            TextButton.icon(
              onPressed: () {
                if (_selectedDay != null) _fetchSlots(_selectedDay!);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlots(bool isDark, Color accentColor) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: secondaryText,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'No available slots this month',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 18,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Try selecting a different date or contact the clinic for assistance.',
              style: AppTextStyles.body1.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            TextButton.icon(
              onPressed: () {
                if (_selectedDay != null) _fetchSlots(_selectedDay!);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotChips(bool isDark, Color accentColor) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _availableSlots.map((slot) {
          final isSelected = _selectedSlot == slot;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSlot = slot;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : surface,
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                border: Border.all(
                  color: isSelected ? accentColor : borderColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                slot,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark, Color accentColor) {
    final isEnabled = _selectedSlot != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton.primary(
          label: 'Continue',
          onPressed: isEnabled ? _onContinuePressed : null,
          backgroundColor: accentColor,
        ),
      ),
    );
  }
}

class _StepData {
  final int number;
  final String label;
  final bool isActive;

  _StepData(this.number, this.label, this.isActive);
}
