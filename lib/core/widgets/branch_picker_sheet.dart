import 'package:flutter/material.dart';

import '../../core/services/branch_service.dart';
import '../../core/services/models/branch.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';

/// Result returned when the patient confirms their branch selection.
class BranchPickerResult {
  final int branchId;
  final String branchName;

  const BranchPickerResult({
    required this.branchId,
    required this.branchName,
  });
}

/// A bottom sheet that lets the patient pick which branch they received
/// treatment at before uploading a document.
///
/// Usage:
/// ```dart
/// final result = await BranchPickerSheet.show(context);
/// if (result != null) {
///   // use result.branchId, result.branchName
/// }
/// ```
class BranchPickerSheet extends StatefulWidget {
  const BranchPickerSheet({super.key});

  /// Shows the sheet and returns [BranchPickerResult] when the patient
  /// confirms, or `null` if they dismiss without selecting.
  static Future<BranchPickerResult?> show(BuildContext context) {
    return AppBottomSheet.show<BranchPickerResult>(
      context,
      title: 'Which branch are you from?',
      child: const BranchPickerSheet(),
    );
  }

  @override
  State<BranchPickerSheet> createState() => _BranchPickerSheetState();
}

class _BranchPickerSheetState extends State<BranchPickerSheet> {
  List<Branch> _branches = const [];
  int? _selectedId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    // BranchService is a singleton already initialised at app start.
    // If not yet initialised, init() is fast (reads cache).
    if (!BranchService.instance.isInitialised) {
      await BranchService.instance.init();
    }
    if (!mounted) return;
    setState(() {
      _branches = BranchService.instance.branches;
      _isLoading = false;
    });
  }

  void _onConfirm() {
    if (_selectedId == null) return;
    final branch = _branches.firstWhere((b) => b.id == _selectedId);
    Navigator.pop(context, BranchPickerResult(
      branchId: branch.id,
      branchName: branch.name,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Text(
            'Please select the branch where you received your treatment. '
            'Your document will be sent to that branch\'s team.',
            style: AppTextStyles.body2.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        ..._branches.map((branch) {
          final isSelected = _selectedId == branch.id;
          return _BranchTile(
            branch: branch,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => setState(() => _selectedId = branch.id),
          );
        }),
        const SizedBox(height: AppSpacing.space16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: FilledButton(
            onPressed: _selectedId != null ? _onConfirm : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.accent.withAlpha(80),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
      ],
    );
  }
}

class _BranchTile extends StatelessWidget {
  final Branch branch;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _BranchTile({
    required this.branch,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accent;
    final bgColor = isSelected
        ? accentColor.withAlpha(isDark ? 40 : 20)
        : Colors.transparent;
    final borderColor = isSelected ? accentColor : (isDark ? AppColors.dividerDark : AppColors.divider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          ),
          child: Row(
            children: [
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accentColor : (isDark ? AppColors.dividerDark : AppColors.divider),
                    width: isSelected ? 6 : 2,
                  ),
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? accentColor
                            : (isDark ? AppColors.textPrimaryDark : AppColors.primary),
                      ),
                    ),
                    if (branch.address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        branch.address,
                        style: AppTextStyles.body2.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
