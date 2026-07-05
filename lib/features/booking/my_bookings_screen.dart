import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/appointment_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 10;

  List<AppointmentItem> _appointments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadAppointments());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMoreAppointments();
      }
    }
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
      _hasMorePages = true;
    });

    try {
      final response = await GetAppointmentUpcomingCall.call(
        patientId: FFAppState().idplato,
      );

      if (response.succeeded) {
        final titles =
            GetAppointmentUpcomingCall.title(response.jsonBody)
                    ?.toList() ??
                [];
        final starts =
            GetAppointmentUpcomingCall.start(response.jsonBody)
                    ?.toList() ??
                [];
        final statuss =
            GetAppointmentUpcomingCall.status(response.jsonBody)
                    ?.toList() ??
                [];
        final dpnames = GetAppointmentUpcomingCall.doctorname(
                response.jsonBody)
            ?.toList() ??
            [];
        final dpbranches =
            GetAppointmentUpcomingCall.branch(response.jsonBody)
                    ?.toList() ??
                [];

        final items = <AppointmentItem>[];
        for (int i = 0; i < titles.length; i++) {
          items.add(AppointmentItem(
            title: titles[i],
            doctorName:
                dpnames.length > i ? dpnames[i] : '',
            branch:
                dpbranches.length > i ? dpbranches[i] : '',
            date: starts.length > i ? starts[i] : '',
            status:
                statuss.length > i ? statuss[i] : '',
          ));
        }

        if (mounted) {
          setState(() {
            _appointments = items;
            _isLoading = false;
            _hasMorePages = items.length >= _pageSize;
          });
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

  Future<void> _loadMoreAppointments() async {
    if (_isLoadingMore || !_hasMorePages) return;
    if (!mounted) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await GetAppointmentUpcomingCall.call(
        patientId: FFAppState().idplato,
      );

      if (response.succeeded) {
        final titles =
            GetAppointmentUpcomingCall.title(response.jsonBody)
                    ?.toList() ??
                [];
        final starts =
            GetAppointmentUpcomingCall.start(response.jsonBody)
                    ?.toList() ??
                [];
        final statuss =
            GetAppointmentUpcomingCall.status(response.jsonBody)
                    ?.toList() ??
                [];
        final dpnames = GetAppointmentUpcomingCall.doctorname(
                response.jsonBody)
            ?.toList() ??
            [];
        final dpbranches =
            GetAppointmentUpcomingCall.branch(response.jsonBody)
                    ?.toList() ??
                [];

        final newItems = <AppointmentItem>[];
        for (int i = 0; i < titles.length; i++) {
          newItems.add(AppointmentItem(
            title: titles[i],
            doctorName:
                dpnames.length > i ? dpnames[i] : '',
            branch:
                dpbranches.length > i ? dpbranches[i] : '',
            date: starts.length > i ? starts[i] : '',
            status:
                statuss.length > i ? statuss[i] : '',
          ));
        }

        if (mounted) {
          setState(() {
            _appointments.addAll(newItems);
            _currentPage = nextPage;
            _hasMorePages = newItems.length >= _pageSize;
            _isLoadingMore = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  StatusChipVariant _parseStatus(String? status) {
    if (status == null) return StatusChipVariant.pending;
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
        title: 'My Bookings',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, i) => const AppSkeleton.appointmentCard(),
      );
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load appointments',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadAppointments,
      );
    }

    if (_appointments.isEmpty) {
      return AppEmptyState(
        icon: Icons.calendar_today,
        title: 'No appointments yet',
        subtitle: 'Book your first visit today',
        ctaLabel: 'Book Now',
        onCtaTap: () => Navigator.of(context).pop('book'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      itemCount:
          _appointments.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= _appointments.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space12,
            ),
            child: const Center(
              child: AppSkeleton.appointmentCard(),
            ),
          );
        }

        final appointment = _appointments[i];
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.space12,
          ),
          child: AppointmentCard(
            doctorName: appointment.doctorName,
            specialty: '',
            branchName: appointment.branch,
            date: appointment.date,
            time: '',
            status: _parseStatus(appointment.status),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class AppointmentItem {
  final String title;
  final String doctorName;
  final String branch;
  final String date;
  final String status;

  const AppointmentItem({
    required this.title,
    required this.doctorName,
    required this.branch,
    required this.date,
    required this.status,
  });
}
