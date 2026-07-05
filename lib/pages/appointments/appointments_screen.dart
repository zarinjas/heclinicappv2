import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/pages/queue/queue_tracker_screen.dart';
import '/app_state.dart';

class AppointmentsScreenWidget extends StatefulWidget {
  const AppointmentsScreenWidget({super.key});

  static String routeName = 'AppointmentsScreen';
  static String routePath = '/myBookingPage';

  @override
  State<AppointmentsScreenWidget> createState() =>
      _AppointmentsScreenWidgetState();
}

class _AppointmentsScreenWidgetState extends State<AppointmentsScreenWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  List<String> _locationCodes = [];
  List<String> _locationNames = [];
  bool _codesLoaded = false;

  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
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
          safeSetState(() {});
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
        final upcoming = <Map<String, dynamic>>[];
        final past = <Map<String, dynamic>>[];

        for (int i = 0; i < starts.length; i++) {
          final startStr = starts[i];
          final startDt = DateTime.tryParse(startStr);
          final endDt = DateTime.tryParse(
            ends.length > i ? ends[i] : '',
          );

          final doctorCode =
              doctorCodes.length > i ? doctorCodes[i] : '';
          final locationCodeVal =
              locationCodes.length > i ? locationCodes[i] : '';
          final title = titles.length > i ? titles[i] : '';

          final doctorName = _getDoctorName(doctorCode);
          final locationName = _getLocationName(locationCodeVal);

          final appointment = {
            'index': i,
            'title': title,
            'start': startDt,
            'end': endDt,
            'doctorCode': doctorCode,
            'doctorName': doctorName,
            'locationCode': locationCodeVal,
            'locationName': locationName,
            'color': _getColorForCode(doctorCode),
            'isUpcoming': startDt != null && startDt.isAfter(now),
          };

          if (startDt != null && startDt.isAfter(now)) {
            upcoming.add(appointment);
          } else {
            past.add(appointment);
          }
        }

        past.sort(
          (a, b) => (b['start'] as DateTime?)
              .compareTo(a['start'] as DateTime? ?? DateTime(0)),
        );

        setState(() {
          _upcomingAppointments = upcoming;
          _pastAppointments = past;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Could not load appointments';
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Could not load appointments';
      });
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

  Color _getColorForCode(String code) {
    if (code.isEmpty) return AppColors.accent;
    final colorIndex = code.hashCode.abs();
    const colors = [
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    return colors[colorIndex % colors.length];
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
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

  String _statusLabel(Map<String, dynamic> appointment) {
    return appointment['isUpcoming'] == true ? 'Confirmed' : 'Completed';
  }

  Color _statusColor(Map<String, dynamic> appointment) {
    return appointment['isUpcoming'] == true
        ? AppColors.success
        : AppColors.textSecondary;
  }

  void _showAppointmentDetail(Map<String, dynamic> appointment) {
    final start = appointment['start'] as DateTime?;
    final end = appointment['end'] as DateTime?;
    final doctorName = appointment['doctorName'] as String? ?? 'Not Set';
    final locationName = appointment['locationName'] as String? ?? '';
    final color = appointment['color'] as Color;
    final statusLabel = _statusLabel(appointment);
    final statusColor = _statusColor(appointment);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.calendar_today,
                color: color,
                size: 28.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Appointment Detail',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _detailRow(Icons.access_time, 'Date & Time',
                      '${_formatDate(start)} at ${_formatTime(start)}'),
                  if (end != null)
                    _detailRow(Icons.timer_outlined, 'Ends at',
                        _formatTime(end)),
                  if (locationName.isNotEmpty)
                    _detailRow(Icons.location_on_outlined, 'Branch',
                        locationName),
                  _detailRow(Icons.person_outline, 'Doctor', doctorName),
                  _detailRow(Icons.info_outline, 'Status', statusLabel,
                      valueColor: statusColor),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 80.0,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textInverse
                        : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: InkWell(
          onTap: () => context.safePop(),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textInverse,
            size: 24.0,
          ),
        ),
        title: Text(
          'My Appointments',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.queue_outlined,
              color: AppColors.textInverse,
              size: 24.0,
            ),
            tooltip: 'Queue Tracker',
            onPressed: () {
              context.pushNamed(QueueTrackerScreenWidget.routeName);
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _hasError
              ? ErrorStateWidget(
                  message: _errorMessage ?? 'Something went wrong',
                  onRetry: _loadAppointments,
                )
              : _buildContent(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildTabSkeleton(),
          const SizedBox(height: AppSpacing.lg),
          _buildCardSkeleton(),
          const SizedBox(height: AppSpacing.md),
          _buildCardSkeleton(),
          const SizedBox(height: AppSpacing.md),
          _buildCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildTabSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : AppColors.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 4.0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.bgLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.textInverse,
            unselectedLabelColor: AppColors.textSecondary,
            indicator: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(_upcomingAppointments, true),
              _buildAppointmentList(_pastAppointments, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentList(
    List<Map<String, dynamic>> appointments,
    bool isUpcoming,
  ) {
    if (appointments.isEmpty) {
      return _pullToRefresh(
        isUpcoming,
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyStateWidget(
              icon: Icons.event_busy,
              title: isUpcoming
                  ? 'No upcoming appointments'
                  : 'No past appointments',
              subtitle: isUpcoming
                  ? 'Book your first visit today'
                  : 'Your completed appointments will appear here',
              actionLabel: isUpcoming ? 'Book Now' : null,
              onAction: isUpcoming
                  ? () => context.pushNamed('/branchSelectionScreen')
                  : null,
            ),
        ),
      ),
    ),
    );
  }

    return _pullToRefresh(
      isUpcoming,
      ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (_, index) => _buildAppointmentCard(appointments[index]),
      ),
    );
  }

  Widget _pullToRefresh(bool isUpcoming, Widget child) {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: child,
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final color = appointment['color'] as Color;
    final start = appointment['start'] as DateTime?;
    final end = appointment['end'] as DateTime?;
    final doctorName = appointment['doctorName'] as String? ?? 'Not Set';
    final locationName = appointment['locationName'] as String? ?? '';
    final statusLabel = _statusLabel(appointment);
    final statusColor = _statusColor(appointment);

    return GestureDetector(
      onTap: () => _showAppointmentDetail(appointment),
      child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1F2937)
                  : AppColors.divider,
            ),
            boxShadow: const [AppShadows.low],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4.0,
                  color: color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(start),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textInverse
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(start),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (end != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              'Until ${_formatTime(end)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        if (locationName.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16.0,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                locationName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16.0,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              doctorName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
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
          ),
        ),
      ),
    );
  }
}
