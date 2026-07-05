import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';

class RecordDetailScreen extends StatefulWidget {
  final String recordType;
  final String doctorName;
  final String recordDate;

  const RecordDetailScreen({
    super.key,
    required this.recordType,
    required this.doctorName,
    required this.recordDate,
  });

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecordDetail());
  }

  Future<void> _loadRecordDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
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

  StatusChipVariant _recordTypeToChipVariant() {
    switch (widget.recordType.toLowerCase()) {
      case 'note':
        return StatusChipVariant.completed;
      case 'letter':
        return StatusChipVariant.confirmed;
      case 'lab':
        return StatusChipVariant.pending;
      case 'mc':
        return StatusChipVariant.cancelled;
      default:
        return StatusChipVariant.confirmed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Record Detail',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _hasError
              ? AppErrorState(
                  title: 'Failed to load record',
                  subtitle: 'Please check your connection and try again',
                  onRetry: _loadRecordDetail,
                )
              : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: const [
        AppSkeleton.card(),
        SizedBox(height: AppSpacing.space16),
        AppSkeleton.card(),
      ],
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: AppChip(
            label: widget.recordType,
            type: AppChipType.status,
            statusVariant: _recordTypeToChipVariant(),
          ),
        ),
        Text(
          widget.doctorName,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          widget.recordDate,
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),
        AppCard(
          child: AppEmptyState(
            icon: Icons.article_outlined,
            title: 'Record content',
            subtitle: 'Full record details will load here',
          ),
        ),
      ],
    );
  }
}
