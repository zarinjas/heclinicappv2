import 'package:flutter/material.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_manager.dart';
import '/env_config.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_shadows.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/modern_toast.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
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
          final codes = GetAppointmentCodeCall.codes(codesResult.jsonBody) ?? [];
          final names = GetAppointmentCodeCall.names(codesResult.jsonBody) ?? [];
          final locCodes = GetAppointmentCodeCall.codelocation(codesResult.jsonBody) ?? [];
          final locNames = GetAppointmentCodeCall.namelocation(codesResult.jsonBody) ?? [];

          if (codes.isNotEmpty) {
            FFAppState().Listcode = codes;
            FFAppState().ListDoctorName = names;
            _locationCodes = locCodes;
            _locationNames = locNames;
            _codesLoaded = true;
          } else if (FFAppState().Listcode.isNotEmpty) {
            _codesLoaded = true;
          }
          safeSetState(() {});
        }
      }

      final patientId = FFAppState().idplato;
      if (patientId.isEmpty) {
        setState(() {
          _upcomingAppointments = [];
          _pastAppointments = [];
          _isLoading = false;
          _hasError = false;
        });
        return;
      }

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
        final appointmentIds = GetAppointmentCall.appointmentId(jsonBody) ?? [];

        final now = DateTime.now();
        final upcoming = <Map<String, dynamic>>[];
        final past = <Map<String, dynamic>>[];

        for (int i = 0; i < starts.length; i++) {
          final startStr = starts[i];
          final startDt = DateTime.tryParse(startStr);
          final endDt = DateTime.tryParse(ends.length > i ? ends[i] : '');

          final doctorCode = doctorCodes.length > i ? doctorCodes[i] : '';
          final locationCodeVal = locationCodes.length > i ? locationCodes[i] : '';
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
            'appointmentId': appointmentIds.length > i ? appointmentIds[i] : '',
          };

          if (startDt != null && startDt.isAfter(now)) {
            upcoming.add(appointment);
          } else {
            past.add(appointment);
          }
        }

        past.sort((a, b) => (b['start'] as DateTime?)?.compareTo(a['start'] as DateTime? ?? DateTime(0)) ?? 0);

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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final diff = dt.difference(DateTime.now()).inDays;
    
    if (diff >= 0 && diff <= 6) {
      return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
    }
    
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getShortDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[dt.month - 1];
  }

  int _getDateNum(DateTime? dt) {
    if (dt == null) return 0;
    return dt.day;
  }

  String _statusLabel(Map<String, dynamic> appointment) {
    return appointment['isUpcoming'] == true ? 'Confirmed' : 'Completed';
  }

  Color _statusColor(Map<String, dynamic> appointment) {
    return appointment['isUpcoming'] == true ? AppColors.success : AppColors.textSecondary;
  }

  void _showAppointmentDetail(Map<String, dynamic> appointment) {
    final start = appointment['start'] as DateTime?;
    final end = appointment['end'] as DateTime?;
    final doctorName = appointment['doctorName'] as String? ?? 'Not Set';
    final locationName = appointment['locationName'] as String? ?? '';
    final color = appointment['color'] as Color;
    final statusLabel = _statusLabel(appointment);
    final statusColor = _statusColor(appointment);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXL)),
      ),
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXL)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Icon(Icons.calendar_month, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            Text(
              'Appointment Details',
              style: AppTextStyles.heading2.copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.space16),
            Container(
              width: 64,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, Colors.transparent]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoCard(icon: Icons.access_time, title: 'Date & Time', value: start != null ? '${_formatDate(start)} at ${_formatTime(start)}' : '', color: color, context: context),
                    if (end != null) _InfoCard(icon: Icons.timer_outlined, title: 'Ends At', value: _formatTime(end), color: color, context: context),
                    if (locationName.isNotEmpty) _InfoCard(icon: Icons.location_on_outlined, title: 'Branch Location', value: locationName, color: color, context: context),
                    _InfoCard(icon: Icons.person_outline, title: 'Doctor', value: doctorName, color: color, context: context),
                    _InfoCard(
                      icon: statusLabel == 'Confirmed' ? Icons.check_circle_outline : Icons.event_busy,
                      title: 'Status',
                      value: statusLabel,
                      color: statusColor,
                      context: context,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    if (appointment['isUpcoming'] == true && (appointment['appointmentId'] as String? ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.space16),
                        child: Material(
                          elevation: 4,
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                          child: InkWell(
                            onTap: () => _onCancelAppointment(appointment),
                            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Cancel Appointment', textAlign: TextAlign.center, style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.space16 + AppSpacing.space8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Optional callback after dismiss
    });
  }

  Future<void> _onCancelAppointment(Map<String, dynamic> appointment) async {
    final appointmentId = appointment['appointmentId'] as String? ?? '';
    if (appointmentId.isEmpty || !mounted) return;

    final reason = await _showCancelReasonDialog();
    if (reason == null || !mounted) return;

    final cancelled = await _cancelAppointment(appointmentId, reason);
    if (!mounted) return;

    if (cancelled) {
      Navigator.of(context).pop();
      ToastManager.success(context, message: 'Appointment cancelled');
      _loadAppointments();
    } else {
      ToastManager.error(context, message: 'Failed to cancel appointment');
    }
  }

  Future<String?> _showCancelReasonDialog() {
    const reasons = [
      'Change of plans',
      'Cannot make it',
      'Feeling unwell',
      'Doctor not available',
      'Booking mistake',
      'Other',
    ];
    final controller = TextEditingController();
    String selected = '';

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => Dialog(
            backgroundColor: surface,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusXL)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why are you cancelling?', style: AppTextStyles.heading3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) {
                      final isSelected = selected == reason;
                      return ChoiceChip(
                        label: Text(reason),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (_) => setDialogState(() => selected = reason),
                        labelStyle: AppTextStyles.body2.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary),
                        selectedColor: AppColors.error,
                        backgroundColor: surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                          side: BorderSide(color: isSelected ? AppColors.error : AppColors.divider),
                        ),
                      );
                    }).toList(),
                  ),
                  if (selected == 'Other') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 2,
                      style: AppTextStyles.body1.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary),
                      decoration: InputDecoration(
                        hintText: 'Tell us the reason…',
                        hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.radiusMD), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.radiusMD), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.radiusMD), borderSide: const BorderSide(color: AppColors.inputBorderFocus)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.ghost(label: 'Keep', onPressed: () => Navigator.of(dialogContext).pop()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.destructive(
                          label: 'Cancel Visit',
                          onPressed: selected.isEmpty
                              ? null
                              : () {
                                  final reason = selected == 'Other' ? (controller.text.trim().isNotEmpty ? controller.text.trim() : selected) : selected;
                                  Navigator.of(dialogContext).pop(reason);
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _cancelAppointment(String appointmentId, String reason) async {
    try {
      final response = await ApiManager.instance.makeApiCall(
        callName: 'Cancel Appointment',
        apiUrl: '${EnvConfig.platomBaseUrl}/appointment/$appointmentId/cancel',
        callType: ApiCallType.POST,
        headers: {'Authorization': 'Bearer ${FFAppState().tokenauth}', 'db': 'hemedclinic'},
        params: {'reason': reason},
        bodyType: BodyType.JSON,
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false,
        isStreamingApi: false,
        alwaysAllowBody: false,
      );
      return response.succeeded;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(onTap: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24)),
        title: Text('My Appointments', style: AppTextStyles.heading1.copyWith(fontSize: 22, color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingSkeleton() : _hasError ? ErrorStateWidget(message: _errorMessage ?? 'Something went wrong', onRetry: _loadAppointments) : _buildContent(),
    );
  }

  Widget _buildLoadingSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Gradient header skeleton
        Container(
          width: double.infinity,
          height: 80,
          margin: const EdgeInsets.fromLTRB(16, 16 + MediaQuery.of(context).padding.top, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.9), AppColors.primary.withValues(alpha: 0.75)]),
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SkeletonTab(isDark: isDark),
                const SizedBox(width: 12),
                _SkeletonTab(isDark: isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => _ModernSkeletonCard(isDark: isDark)),
      ],
    );
  }

  Widget _SkeletonTab({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.black12,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
    );
  }

  Widget _ModernSkeletonCard({required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM))),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 14, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM))),
          const SizedBox(height: 16),
          Container(height: 14, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.radiusSM))),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Modern Gradient Header Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.of(context).padding.top, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.9), AppColors.primary.withValues(alpha: 0.75)]),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ModernTabButton(icon: Icons.event_available, label: 'Upcoming', isSelected: _tabController.index == 0, onTap: () => _tabController.animateTo(0), context: context),
              _ModernTabButton(icon: Icons.history, label: 'Past', isSelected: _tabController.index == 1, onTap: () => _tabController.animateTo(1), context: context),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [_buildAppointmentList(_upcomingAppointments, true), _buildAppointmentList(_pastAppointments, false)]),
        ),
      ],
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments, bool isUpcoming) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: EmptyStateWidget(icon: Icons.event_busy, title: isUpcoming ? 'No upcoming appointments' : 'No past appointments', subtitle: isUpcoming ? 'Book your first visit today' : 'Your completed appointments will appear here', actionLabel: isUpcoming ? 'Book Now' : null, onAction: isUpcoming ? () {} : null))),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (_, index) => _buildAppointmentCard(appointments[index]),
      ),
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
    final isUpcoming = appointment['isUpcoming'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.3) : color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showAppointmentDetail(appointment),
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.radiusSM)),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(_getShortDate(start), style: AppTextStyles.label.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          Text(_getDateNum(start).toString(), style: AppTextStyles.heading1.copyWith(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(start), style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(Icons.schedule, size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(_formatTime(start), style: AppTextStyles.heading3.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                              if (end != null) ...[
                                Text(' → ${_formatTime(end)}', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ])
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(statusLabel, style: AppTextStyles.label.copyWith(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)]))),
              const SizedBox(height: 16),
              if (locationName.isNotEmpty)
                _CardInfoRow(icon: Icons.location_on_outlined, text: locationName, color: color),
              if (locationName.isNotEmpty) const SizedBox(height: 8),
              _CardInfoRow(icon: Icons.person_outline, text: doctorName, color: color),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CardInfoRow extends StatelessWidget {
  const _CardInfoRow({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.body2.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _ModernTabButton extends StatelessWidget {
  const _ModernTabButton({required this.icon, required this.label, required this.isSelected, required this.onTap, required this.context});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isSelected ? AppColors.primary : Colors.white),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.label.copyWith(color: isSelected ? AppColors.primary : Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.value, required this.color, required this.context});

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [isDark ? AppColors.surfaceDark.withValues(alpha: 0.85) : AppColors.scaffoldBg.withValues(alpha: 0.7), isDark ? AppColors.surfaceDark.withValues(alpha: 0.7) : AppColors.scaffoldBg.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.radiusSM)), child: Icon(icon, size: 20, color: color)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.label.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
      ]),
    );
  }
}
