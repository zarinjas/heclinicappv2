import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/vitals_chart.dart';

class VitalsTab extends StatefulWidget {
  const VitalsTab({super.key});

  @override
  State<VitalsTab> createState() => _VitalsTabState();
}

class _VitalsTabState extends State<VitalsTab> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVitals());
  }

  Future<void> _loadVitals() async {
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
        title: 'Failed to load vitals',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadVitals,
      );
    }
    return _buildContent();
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space16),
      itemBuilder: (_, i) => const AppSkeleton.card(),
    );
  }

  Widget _buildContent() {
    return AppEmptyState(
      icon: Icons.favorite_outline,
      title: 'No vitals recorded yet',
      subtitle: 'Your health trends will appear here',
    );
  }
}
