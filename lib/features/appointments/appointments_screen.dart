import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isUpcomingTab = true;

  List<String> _locationCodes = [];
  List<String> _locationNames = [];
  bool _codesLoaded = false;

  List<AppointmentData> _upcomingAppointments = [];
  List<AppointmentData> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (!_codesLoaded) {
        final codesResult = await GetAppointmentCodeCall.call();
        if (codesResult.succeeded) {
          FFAppState().Listcode = GetAppointmentCodeCall.codes(
                codesResult.jsonBody,
              )!
              .toList()
              .cast<String>();
          FFAppState().ListDoctorName = GetAppointmentCodeCall.names(
                codesResult.jsonBody,
              )!
              .toList()
              .cast<String>();
          _locationCodes = GetAppointmentCodeCall.codelocation(
                codesResult.jsonBody,
              )!
              .toList()
              .cast<String>();
          _locationNames = GetAppointmentCodeCall.namelocation(
                codesResult.jsonBody,
              )!
              .toList()
              .cast<String>();
          _codesLoaded = true;
        }
      }

      final patientId = FFAppState().idplato;
      final result = await GetAppointmentCall.call(
        patientId: patientId,
        forceRefresh: true,
      );

      if (result.succeeded) {
        final jsonBody = result.jsonBody;
        final starts = GetAppointmentCall.start(jsonBody) ?? [];
        final ends = GetAppointmentCall.end(jsonBody) ?? [];
        final titles = GetAppointmentCall.title(jsonBody) ?? [];
        final doctorCodes = GetAppointmentCall.doctorCode(jsonBody) ?? [];
        final locationCodes = GetAppointmentCall.locationCode(jsonBody) ?? [];
        final now = DateTime.now();
        final upcoming = <AppointmentData>[];
        final past = <AppointmentData>[];

        for (int i = 0; i < starts.length; i++) {
          final startStr = starts[i];
          final startDt = DateTime.tryParse(startStr);
          final endDt = DateTime.tryParse(
            ends.length > i ? ends[i] : '',
          );
          final doctorCode = doctorCodes.length > i ? doctorCodes[i] : '';
          final locationCodeVal = locationCodes.length > i ? locationCodes[i] : '';
          final title = titles.length > i ? titles[i] : '';

          final doctorName = _getDoctorName(doctorCode);
          final locationName = _getLocationName(locationCodeVal);

          final appointment = AppointmentData(
            title: title,
            start: startDt,
            end: endDt,
            doctorCode: doctorCode,
            doctorName: doctorName,
            locationName: locationName,
          );

          if (startDt != null && startDt.isAfter(now)) {
            upcoming.add(appointment);
          } else {
            past.add(appointment);
          }
        }

        past.sort((a, b) => (b.start ?? DateTime(0)).compareTo(a.start ?? DateTime(0)));

        if (mounted) {
          setState(() {
            _upcomingAppointments = upcoming;
            _pastAppointments = past;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        throw Exception('HTTP ${result.statusCode}');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  String _getDoctorName(String code) {
    if (code.isEmpty) return 'No Preference';
    final codes = FFAppState().Listcode;
    final names = FFAppState().ListDoctorName;
    final index = codes.indexOf(code);
    return index >= 0 && index < names.length ? names[index] : 'Doctor';
  }

  String _getLocationName(String code) {
    if (code.isEmpty) return '';
    final index = _locationCodes.indexOf(code);
    return index >= 0 && index < _locationNames.length
        ? _locationNames[index]
        : code;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final displayHour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  int _daysToGo(DateTime? start) {
    if (start == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(start.year, start.month, start.day);
    return appointmentDate.difference(today).inDays;
  }

  StatusChipVariant _parseStatus(bool isUpcoming) {
    return isUpcoming ? StatusChipVariant.confirmed : StatusChipVariant.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Appointments',
        onBack: () {},
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _hasError
              ? AppErrorState(
                  title: 'Failed to load appointments',
                  subtitle: 'Please check your connection and try again',
                  onRetry: _loadAppointments,
                )
              : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) => const AppSkeleton.appointmentCard(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTabSwitcher(),
        Expanded(
          child: _isUpcomingTab ? _buildUpcomingTab() : _buildPastTab(),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppChip(
              label: 'Upcoming',
              type: AppChipType.filter,
              isSelected: _isUpcomingTab,
              onTap: () {
                if (!_isUpcomingTab) {
                  setState(() => _isUpcomingTab = true);
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: AppChip(
              label: 'Past',
              type: AppChipType.filter,
              isSelected: !_isUpcomingTab,
              onTap: () {
                if (_isUpcomingTab) {
                  setState(() => _isUpcomingTab = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingAppointments.isEmpty) {
      return AppEmptyState(
        icon: Icons.calendar_today,
        title: 'No upcoming appointments',
        subtitle: 'Book your first visit today',
        ctaLabel: 'Book Now',
        onCtaTap: () {},
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        itemCount: _upcomingAppointments.length,
        itemBuilder: (_, i) => _buildUpcomingCard(_upcomingAppointments[i]),
      ),
    );
  }

  Widget _buildPastTab() {
    if (_pastAppointments.isEmpty) {
      return AppEmptyState(
        icon: Icons.event_busy,
        title: 'No past appointments',
        subtitle: 'Your completed appointments will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        itemCount: _pastAppointments.length,
        itemBuilder: (_, i) => _buildPastCard(_pastAppointments[i]),
      ),
    );
  }

  Widget _buildUpcomingCard(AppointmentData appointment) {
    final days = _daysToGo(appointment.start);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: AppointmentCard(
        doctorName: appointment.doctorName,
        specialty: '',
        branchName: appointment.locationName,
        date: _formatDate(appointment.start),
        time: _formatTime(appointment.start),
        status: _parseStatus(true),
        daysToGo: days > 0 ? days : null,
        onTap: () {},
      ),
    );
  }

  Widget _buildPastCard(AppointmentData appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: AppointmentCard(
        doctorName: appointment.doctorName,
        specialty: '',
        branchName: appointment.locationName,
        date: _formatDate(appointment.start),
        time: _formatTime(appointment.start),
        status: _parseStatus(false),
        onTap: () {},
      ),
    );
  }
}

class AppointmentData {
  final String title;
  final DateTime? start;
  final DateTime? end;
  final String doctorCode;
  final String doctorName;
  final String locationName;

  const AppointmentData({
    required this.title,
    required this.start,
    required this.end,
    required this.doctorCode,
    required this.doctorName,
    required this.locationName,
  });
}
