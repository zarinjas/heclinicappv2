import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_radius.dart';
import '/core/widgets/app_button.dart';
import '/core/services/branch_service.dart';
import 'booking_flow_model.dart';

class BranchSelectionScreenWidget extends StatefulWidget {
  const BranchSelectionScreenWidget({super.key});

  static const String routeName = 'branchSelectionScreen';
  static const String routePath = '/branchSelectionScreen';

  @override
  State<BranchSelectionScreenWidget> createState() =>
      _BranchSelectionScreenWidgetState();
}

class _BranchSelectionScreenWidgetState
    extends State<BranchSelectionScreenWidget> {
  final BookingFlowModel _bookingModel = BookingFlowModel();

  List<BranchItem> _branches = [];
  String? _selectedBranchId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (_bookingModel.selectedBranchId.isNotEmpty) {
      _selectedBranchId = _bookingModel.selectedBranchId;
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = BranchService.instance;
      final wasInitialised = service.isInitialised;
      await service.init();
      // Re-fetch once the service has loaded before so newly toggled
      // "Visible in App" branches appear without an app restart.
      if (wasInitialised) {
        await service.refresh();
      }

      final branches = <BranchItem>[];
      for (final b in service.branches) {
        branches.add(BranchItem(
          id: b.platoFacilityId ?? b.id.toString(),
          name: b.name,
          address: b.address,
          image: b.imageUrl ?? '',
          hours: b.operatingHours != null
              ? _hoursForToday(b.operatingHours!)
              : '',
          phone: b.whatsappNumber ?? b.phone ?? '',
        ));
      }

      if (mounted) {
        setState(() {
          _branches = branches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _hoursForToday(Map<String, String> hours) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final today = days[DateTime.now().weekday - 1];
    return hours[today] ?? '';
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    return error?.toString() ?? 'An unexpected error occurred';
  }

  void _onBranchSelected(BranchItem branch) {
    setState(() {
      _selectedBranchId = branch.id;
    });
    _bookingModel.selectBranch(
      id: branch.id,
      name: branch.name,
      image: branch.image,
      address: branch.address,
      hours: branch.hours,
      whatsApp: branch.phone,
    );
  }

  void _onNextPressed() {
    if (_selectedBranchId != null) {
      context.push('/doctorSelectionScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = AppColors.accent;
    final stepIndicator = _buildStepIndicator(accentColor);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Appointment',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              0,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            child: stepIndicator,
          ),
          Expanded(
            child: _buildBody(isDark, accentColor),
          ),
          _buildNextButton(isDark, accentColor),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color accentColor) {
    final steps = [
      _StepData(1, 'Branch', true),
      _StepData(2, 'Doctor', false),
      _StepData(3, 'Date & Time', false),
      _StepData(4, 'Confirm', false),
    ];

    return Row(
      children: steps.map((step) {
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isActive ? accentColor : Colors.white,
                  border: Border.all(
                    color: step.isActive ? accentColor : Colors.white54,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${step.number}',
                  style: AppTextStyles.caption.copyWith(
                    color: step.isActive ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: AppTextStyles.caption.copyWith(
                  color: step.isActive ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: step.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBody(bool isDark, Color accentColor) {
    if (_isLoading) {
      return _buildSkeletonLoader(isDark);
    }
    if (_hasError) {
      return _buildErrorState(isDark, accentColor);
    }
    if (_branches.isEmpty) {
      return _buildEmptyState(isDark);
    }
    return _buildBranchList(isDark, accentColor);
  }

  Widget _buildSkeletonLoader(bool isDark) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final skeleton = isDark ? AppColors.dividerDark : AppColors.divider;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: ListView.separated(
        itemCount: 4,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space16),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: skeleton,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.radiusLG)),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: skeleton,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radiusXS),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Container(
                        width: 200,
                        height: 10,
                        decoration: BoxDecoration(
                          color: skeleton,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radiusXS),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: skeleton,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radiusXS),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Color accentColor) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Something went wrong',
              style: AppTextStyles.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              _errorMessage,
              style: AppTextStyles.body1.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            TextButton.icon(
              onPressed: _loadBranches,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: secondaryText,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'No branches available',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Please check back later or contact the clinic.',
              style: AppTextStyles.body1.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchList(bool isDark, Color accentColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: _branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, index) {
        final branch = _branches[index];
        final isSelected = _selectedBranchId == branch.id;
        return _buildBranchCard(branch, isSelected, isDark, accentColor);
      },
    );
  }

  Widget _buildBranchCard(
    BranchItem branch,
    bool isSelected,
    bool isDark,
    Color accentColor,
  ) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    return GestureDetector(
      onTap: () => _onBranchSelected(branch),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: SizedBox(
                width: 100,
                height: 120,
                child: branch.image.isNotEmpty
                    ? Image.network(
                        branch.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage(isDark),
                      )
                    : _buildPlaceholderImage(isDark),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch.name,
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 18,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (branch.address.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: secondaryText,
                          ),
                          const SizedBox(width: AppSpacing.space4),
                          Expanded(
                            child: Text(
                              branch.address,
                              style: AppTextStyles.body1
                                  .copyWith(color: secondaryText),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (branch.hours.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: secondaryText,
                          ),
                          const SizedBox(width: AppSpacing.space4),
                          Text(
                            branch.hours,
                            style: AppTextStyles.body2
                                .copyWith(color: secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space12),
                child: Icon(
                  Icons.check_circle,
                  color: accentColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    final bg = isDark ? AppColors.dividerDark : AppColors.divider;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Container(
      color: bg,
      child: Center(
        child: Icon(
          Icons.store,
          size: 32,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isDark, Color accentColor) {
    final isEnabled = _selectedBranchId != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton.primary(
          label: 'Next',
          onPressed: isEnabled ? _onNextPressed : null,
          backgroundColor: accentColor,
        ),
      ),
    );
  }
}

class _StepData {
  final int number;
  final String label;
  final bool isActive;

  _StepData(this.number, this.label, this.isActive);
}

class BranchItem {
  final String id;
  final String name;
  final String address;
  final String image;
  final String hours;
  final String phone;

  BranchItem({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.hours,
    this.phone = '',
  });
}
