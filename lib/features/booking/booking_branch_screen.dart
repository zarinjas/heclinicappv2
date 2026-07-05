import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app_state.dart';
import '../../env_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/branch_card.dart';
import '../../core/widgets/step_indicator.dart';

class BookingBranchScreen extends StatefulWidget {
  const BookingBranchScreen({super.key});

  @override
  State<BookingBranchScreen> createState() => _BookingBranchScreenState();
}

class _BookingBranchScreenState extends State<BookingBranchScreen> {
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBranches());
  }

  Future<void> _loadBranches() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final uri = Uri.parse('${EnvConfig.laravelBaseUrl}/v2/config/branches');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${FFAppState().tokenauth}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as List<dynamic>;
        if (mounted) {
          setState(() {
            _branches = decoded.cast<Map<String, dynamic>>();
            _isLoading = false;
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

  void _onBranchSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onContinue() {
    if (_selectedIndex < 0 || _selectedIndex >= _branches.length) return;
    final branch = _branches[_selectedIndex];
    Navigator.of(context).pop(branch);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Select Branch',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: StepIndicator(
              currentStep: 0,
              totalSteps: 4,
              labels: const [
                'Branch',
                'Doctor',
                'Date & Time',
                'Confirm',
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Expanded(
            child: _buildBody(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, i) => const BranchCardSkeleton(),
      );
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load branches',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadBranches,
      );
    }

    if (_branches.isEmpty) {
      return const AppEmptyState(
        icon: Icons.location_city,
        title: 'No branches available',
        subtitle: 'Please contact the clinic directly',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      itemCount: _branches.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) {
        final branch = _branches[i];
        return BranchCard(
          name: branch['name']?.toString() ?? '',
          address: branch['address']?.toString() ?? '',
          operatingHours:
              branch['operating_hours']?.toString() ?? '',
          isSelected: _selectedIndex == i,
          onTap: () => _onBranchSelected(i),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomBg =
        isDark ? AppColors.surfaceDark : AppColors.surface;
    final topBorder =
        isDark ? AppColors.dividerDark : AppColors.divider;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        top: AppSpacing.space12,
        bottom: AppSpacing.space16 +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bottomBg,
        border: Border(top: BorderSide(color: topBorder)),
      ),
      child: AppButton(
        label: 'Continue',
        variant: AppButtonVariant.primary,
        onPressed:
            _selectedIndex >= 0 ? _onContinue : null,
        isFullWidth: true,
      ),
    );
  }
}
