import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '/backend/api_requests/api_calls.dart';
import '/env_config.dart';
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
    const accentColor = Color(0xFF00C9A7);
    final stepIndicator = _buildStepIndicator(accentColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B3D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0F1B3D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: stepIndicator,
          ),
          Expanded(
            child: _buildBody(accentColor),
          ),
          _buildContinueButton(accentColor),
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
                  style: TextStyle(
                    color: step.isActive ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: TextStyle(
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

  Widget _buildBody(Color accentColor) {
    return Column(
      children: [
        _buildMonthHeader(accentColor),
        _buildCalendar(),
        const SizedBox(height: 16),
        if (_selectedDay != null) _buildSelectedDateLabel(),
        const SizedBox(height: 8),
        Expanded(child: _buildSlotSection(accentColor)),
      ],
    );
  }

  Widget _buildMonthHeader(Color accentColor) {
    final canGoBack = _canGoToPreviousMonth();
    final canGoForward = _canGoToNextMonth();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: canGoBack ? const Color(0xFF0F1B3D) : const Color(0xFFD1D5DB),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F1B3D),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF0F1B3D)),
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

  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
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
            color: const Color(0xFF00C9A7).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF00C9A7),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(
            color: Color(0xFF0F1B3D),
          ),
          defaultTextStyle: const TextStyle(
            color: Color(0xFF0F1B3D),
          ),
          outsideDaysVisible: false,
          markerDecoration: const BoxDecoration(
            color: Color(0xFF00C9A7),
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C9A7),
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

  Widget _buildSelectedDateLabel() {
    final hasSlots = _availableSlots.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: hasSlots ? const Color(0xFF0F1B3D) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 6),
          Text(
            _formatDate(_selectedDay!),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: hasSlots ? const Color(0xFF0F1B3D) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSection(Color accentColor) {
    if (_isLoadingSlots) {
      return _buildSkeletonLoader();
    }
    if (_hasError) {
      return _buildErrorState(accentColor);
    }
    if (_selectedDay == null) {
      return _buildSelectDayPrompt();
    }
    if (_availableSlots.isEmpty) {
      return _buildEmptySlots(accentColor);
    }
    return _buildSlotChips(accentColor);
  }

  Widget _buildSelectDayPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a date to view available time slots',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(8, (_) {
          return Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load time slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F1B3D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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

  Widget _buildEmptySlots(Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No available slots this month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F1B3D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try selecting a different date or contact the clinic for assistance.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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

  Widget _buildSlotChips(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? accentColor : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                slot,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF0F1B3D),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContinueButton(Color accentColor) {
    final isEnabled = _selectedSlot != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isEnabled ? _onContinuePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? accentColor : const Color(0xFFE5E7EB),
              foregroundColor:
                  isEnabled ? Colors.white : const Color(0xFF9CA3AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
