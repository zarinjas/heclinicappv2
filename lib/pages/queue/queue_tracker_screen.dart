import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';

class QueueTrackerScreenWidget extends StatefulWidget {
  const QueueTrackerScreenWidget({super.key});

  static String routeName = 'QueueTrackerScreen';
  static String routePath = '/queue-tracker';

  @override
  State<QueueTrackerScreenWidget> createState() =>
      _QueueTrackerScreenWidgetState();
}

class _QueueTrackerScreenWidgetState extends State<QueueTrackerScreenWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  String? _queueNumber;
  String? _patientName;
  String? _status;
  String? _estimatedWait;
  String? _currentServing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQueueStatus());
  }

  Future<void> _loadQueueStatus() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await GetQueueStatusCall.call();

      if (result.succeeded) {
        final body = result.jsonBody;
        _queueNumber = GetQueueStatusCall.queueNumber(body);
        _patientName = GetQueueStatusCall.patientName(body);
        _status = GetQueueStatusCall.status(body);
        _estimatedWait = GetQueueStatusCall.estimatedWait(body);
        _currentServing = GetQueueStatusCall.currentServing(body);

        safeSetState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        safeSetState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = result.statusCode == 404
              ? 'No active queue found.'
              : 'Failed to fetch queue status.';
        });
      }
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textInverse),
        title: Text(
          'Queue Tracker',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError) {
      return ErrorStateWidget(
        message: _errorMessage ?? 'Something went wrong',
        onRetry: _loadQueueStatus,
      );
    }

    if (_queueNumber == null || _queueNumber!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.queue_outlined,
        title: 'No Active Queue',
        subtitle:
            'You don\'t have an active queue at the moment.\nYour queue status will appear here when you check in at the clinic.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQueueStatus,
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQueueHeroCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildQueueDetails(),
            const SizedBox(height: AppSpacing.xl),
            _buildPullHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppShadows.mid],
            ),
            child: const Center(child: SkeletonListTile()),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppShadows.low],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueHeroCard() {
    final isCurrentlyServing = _currentServing == _queueNumber;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentlyServing
              ? [AppColors.accent, AppColors.accent.withAlpha(200)]
              : [AppColors.primary, AppColors.primary.withAlpha(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.mid],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Queue Number',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textInverse.withAlpha(200),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _queueNumber ?? '—',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.textInverse.withAlpha(30),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              isCurrentlyServing ? 'Now Serving' : 'Waiting',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textInverse,
              ),
            ),
          ),
          if (_patientName != null && _patientName!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _patientName!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textInverse.withAlpha(220),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueueDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.low],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Estimated Wait',
            value: _estimatedWait ?? '—',
          ),
          const Divider(height: AppSpacing.lg),
          _buildDetailRow(
            icon: Icons.people_outline,
            label: 'Currently Serving',
            value: _currentServing ?? '—',
            valueColor: _currentServing != null
                ? AppColors.accent
                : AppColors.textSecondary,
          ),
          const Divider(height: AppSpacing.lg),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: _status != null
                ? _status![0].toUpperCase() + _status!.substring(1)
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22.0, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPullHint() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.swipe_rounded, size: 20.0, color: AppColors.textSecondary.withAlpha(150)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pull down to refresh',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.0,
              color: AppColors.textSecondary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
