import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/branch_service.dart';
import '../../core/services/models/branch.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/branch_card.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({super.key});

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Branch> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = BranchService.instance;
      await service.init();
      // Re-fetch when the service has already loaded so newly toggled
      // "Visible in App" branches appear without an app restart.
      if (service.isInitialised) {
        await service.refresh();
      }
      if (mounted) {
        setState(() {
          _branches = service.branches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _openBranch(Branch branch) {
    context.pushNamed(
      '/branch-detail',
      queryParameters: {'branchName': branch.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: 'Our Branches'),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: 4,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, __) => const BranchCardSkeleton(),
      );
    }

    if (_hasError && _branches.isEmpty) {
      return AppErrorState(
        title: 'Could not load branches',
        subtitle: _errorMessage,
        onRetry: _loadBranches,
      );
    }

    if (_branches.isEmpty) {
      return const AppEmptyState(
        icon: Icons.location_off_outlined,
        title: 'No branches available',
        subtitle: 'Please check back later or contact the clinic.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBranches,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _branches.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, i) {
          final branch = _branches[i];
          return BranchCard(
            name: branch.name,
            address: branch.address,
            imageUrl: branch.imageUrl,
            leadingGradient: branch.leadingGradient,
            variant: BranchCardVariant.horizontal,
            onTap: () => _openBranch(branch),
          );
        },
      ),
    );
  }
}
