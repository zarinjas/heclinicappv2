import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/api_requests/api_manager.dart';
import '../../env_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_error_state.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    this.appointmentId,
    this.doctorName,
    this.branch,
    this.date,
    this.time,
    this.status,
  });

  final String? appointmentId;
  final String? doctorName;
  final String? branch;
  final String? date;
  final String? time;
  final String? status;

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isCancelling = false;

  String _doctorName = '';
  String _specialty = '';
  String _branch = '';
  String _date = '';
  String _time = '';
  String _appointmentType = '';
  String _notes = '';
  String _status = '';

  bool get _showCancelButton {
    final s = _status.toLowerCase();
    return s != 'cancelled' && s != 'canceled' && s != 'completed';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await GetAppointmentDetailsCall.call(
        appointmentId: widget.appointmentId,
        patientId: FFAppState().idplato,
      );

      if (response.succeeded) {
        final body = response.jsonBody;

        if (body is List && body.isNotEmpty) {
          final data = body.first as Map<String, dynamic>;
          final starts = GetAppointmentDetailsCall.start(response.jsonBody) ?? [];
          final ends = GetAppointmentDetailsCall.end(response.jsonBody) ?? [];

          if (mounted) {
            setState(() {
              _doctorName = _extractString(data, 'doctorname') ??
                  widget.doctorName ??
                  '';
              _specialty = _extractString(data, 'specialty') ?? '';
              _branch = _extractString(data, 'branch_name') ??
                  widget.branch ??
                  '';
              _date = starts.isNotEmpty
                  ? starts.first
                  : (widget.date ?? '');
              _time = starts.isNotEmpty && ends.isNotEmpty
                  ? '${starts.first} - ${ends.first}'
                  : (widget.time ?? '');
              _appointmentType =
                  _extractString(data, 'appointment_type') ?? '';
              _notes = _extractString(data, 'notes') ?? '';
              _status = _extractString(data, 'status') ??
                  widget.status ??
                  '';
              _isLoading = false;
            });
          }
        } else if (body is Map<String, dynamic>) {
          if (mounted) {
            setState(() {
              _doctorName = _extractString(body, 'doctorname') ??
                  widget.doctorName ??
                  '';
              _specialty = _extractString(body, 'specialty') ?? '';
              _branch = _extractString(body, 'branch_name') ??
                  widget.branch ??
                  '';
              _date = widget.date ?? '';
              _time = widget.time ?? '';
              _appointmentType =
                  _extractString(body, 'appointment_type') ?? '';
              _notes = _extractString(body, 'notes') ?? '';
              _status = _extractString(body, 'status') ??
                  widget.status ??
                  '';
              _isLoading = false;
            });
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
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

  String? _extractString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    return value.toString();
  }

  Future<void> _onCancelAppointment() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Cancel Appointment',
      message: 'Are you sure you want to cancel this appointment? '
          'This action cannot be undone.',
      confirmLabel: 'Yes, Cancel',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      final response = await ApiManager.instance.makeApiCall(
        callName: 'Cancel Appointment',
        apiUrl:
            '${EnvConfig.platomBaseUrl}/appointment/${widget.appointmentId}/cancel',
        callType: ApiCallType.POST,
        headers: {
          'Authorization': 'Bearer ${FFAppState().tokenauth}',
          'db': 'hemedclinic',
        },
        params: {},
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false,
        isStreamingApi: false,
        alwaysAllowBody: false,
      );

      if (!mounted) return;

      if (response.succeeded) {
        setState(() {
          _status = 'cancelled';
          _isCancelling = false;
        });

        await AppDialog.success(
          context,
          title: 'Appointment Cancelled',
          message: 'Your appointment has been cancelled.',
          buttonLabel: 'OK',
          onDone: () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          },
        );
      } else {
        setState(() => _isCancelling = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel appointment')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel appointment')),
        );
      }
    }
  }

  StatusChipVariant _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusChipVariant.confirmed;
      case 'pending':
        return StatusChipVariant.pending;
      case 'cancelled':
      case 'canceled':
        return StatusChipVariant.cancelled;
      case 'completed':
        return StatusChipVariant.completed;
      default:
        return StatusChipVariant.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Appointment Details',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load appointment',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadDetail,
      );
    }

    final statusVariant = _parseStatus(_status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(statusVariant),
          const SizedBox(height: AppSpacing.space16),
          _buildDetailCard(),
          const SizedBox(height: AppSpacing.space24),
          if (_showCancelButton && !_isCancelling)
            AppButton.destructive(
              label: 'Cancel Appointment',
              onPressed: _onCancelAppointment,
              isFullWidth: true,
            ),
          if (_isCancelling)
            const SizedBox(
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.space24),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          AppCard(
            child: _shimmerWrap(
              Row(
                children: [
                  const _ShimmerCircle(size: 64),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ShimmerBox(width: 160, height: 16),
                        const SizedBox(height: AppSpacing.space8),
                        const _ShimmerBox(width: 120, height: 14),
                        const SizedBox(height: AppSpacing.space8),
                        const _ShimmerBox(width: 80, height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: AppCard(
                child: _shimmerWrap(
                  Row(
                    children: [
                      const _ShimmerCircle(size: 32),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _ShimmerBox(width: 80, height: 12),
                            const SizedBox(height: AppSpacing.space4),
                            const _ShimmerBox(width: 200, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerWrap(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final shimmer =
        isDark ? AppColors.skeletonShimmerDark : AppColors.skeletonShimmer;

    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [base, shimmer, base],
        );
  }

  Widget _buildHeader(StatusChipVariant statusVariant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                _doctorName.isNotEmpty
                    ? _doctorName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.accent,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _doctorName.isNotEmpty ? _doctorName : 'Appointment',
                  style:
                      AppTextStyles.heading3.copyWith(color: textColor),
                ),
                if (_specialty.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    _specialty,
                    style: AppTextStyles.body2
                        .copyWith(color: secondaryText),
                  ),
                ],
                const SizedBox(height: AppSpacing.space8),
                AppChip(
                  label: _status.isNotEmpty
                      ? _status[0].toUpperCase() + _status.substring(1)
                      : 'Pending',
                  type: AppChipType.status,
                  statusVariant: statusVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: AppTextStyles.heading3.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.space16),
          _detailRow(
            Icons.location_on,
            'Branch',
            _branch,
            textColor,
            secondaryText,
          ),
          const SizedBox(height: AppSpacing.space12),
          _detailRow(
            Icons.calendar_today,
            'Date',
            _date,
            textColor,
            secondaryText,
          ),
          const SizedBox(height: AppSpacing.space12),
          _detailRow(
            Icons.access_time,
            'Time',
            _time,
            textColor,
            secondaryText,
          ),
          if (_appointmentType.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            _detailRow(
              Icons.category,
              'Appointment Type',
              _appointmentType,
              textColor,
              secondaryText,
            ),
          ],
          if (_notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            _detailRow(
              Icons.notes,
              'Notes',
              _notes,
              textColor,
              secondaryText,
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color secondaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                value.isNotEmpty ? value : '—',
                style: AppTextStyles.body1.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    this.height,
  });

  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Container(
      width: width,
      height: height ?? 14,
      decoration: BoxDecoration(
        color: base,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: base,
        shape: BoxShape.circle,
      ),
    );
  }
}
