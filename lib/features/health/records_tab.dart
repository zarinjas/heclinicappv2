import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/health_record_card.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  bool _isLoading = true;
  bool _hasError = false;
  String _activeFilter = 'All';

  static const _filters = ['All', 'Notes', 'Letters', 'Lab', 'MC'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  Future<void> _loadRecords() async {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();
    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load records',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadRecords,
      );
    }
    return _buildContent();
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) => const AppSkeleton.listItem(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildFilterRow(),
        Expanded(
          child: AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No records found',
            subtitle: 'Your clinical notes will appear here',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space8),
              child: AppChip(
                label: filter,
                type: AppChipType.filter,
                isSelected: _activeFilter == filter,
                onTap: () {
                  if (_activeFilter != filter) {
                    setState(() => _activeFilter = filter);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
