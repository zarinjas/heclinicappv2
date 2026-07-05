import 'package:flutter/material.dart';

import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/doctor_card.dart';
import '../../core/widgets/step_indicator.dart';

class BookingDoctorScreen extends StatefulWidget {
  const BookingDoctorScreen({super.key});

  @override
  State<BookingDoctorScreen> createState() => _BookingDoctorScreenState();
}

class _BookingDoctorScreenState extends State<BookingDoctorScreen> {
  List<DoctorItem> _doctors = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedIndex = -1;
  bool _isNoPreference = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoctors());
  }

  Future<void> _loadDoctors() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await GetDoctorsCall.call(visible: true);

      if (response.succeeded) {
        final ids = GetDoctorsCall.id(response.jsonBody) ?? [];
        final names = GetDoctorsCall.name(response.jsonBody) ?? [];
        final specialties =
            GetDoctorsCall.specialty(response.jsonBody) ?? [];

        final doctors = <DoctorItem>[];
        for (int i = 0; i < names.length; i++) {
          doctors.add(DoctorItem(
            id: i < ids.length ? ids[i] : '',
            name: names[i],
            specialty:
                i < specialties.length ? specialties[i] : '',
          ));
        }

        if (mounted) {
          setState(() {
            _doctors = doctors;
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

  void _onSelectDoctor(int index) {
    setState(() {
      _selectedIndex = index;
      _isNoPreference = false;
    });
  }

  void _onSelectNoPreference() {
    setState(() {
      _isNoPreference = true;
      _selectedIndex = -1;
    });
  }

  void _onContinue() {
    if (!_isNoPreference && _selectedIndex < 0) return;
    final result = _isNoPreference
        ? {'no_preference': true}
        : {'doctor': _doctors[_selectedIndex].toMap()};
    Navigator.of(context).pop(result);
  }

  bool get _hasSelection => _isNoPreference || _selectedIndex >= 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Select Doctor',
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
              currentStep: 1,
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
        itemBuilder: (_, i) => const DoctorCardSkeleton(
          variant: DoctorCardVariant.vertical,
        ),
      );
    }

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load doctors',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadDoctors,
      );
    }

    if (_doctors.isEmpty) {
      return const AppEmptyState(
        icon: Icons.person_outline,
        title: 'No doctors available',
        subtitle: 'Please contact the clinic directly',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      itemCount: _doctors.length + 1,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.space8),
      itemBuilder: (_, i) {
        if (i == 0) {
          return _buildNoPreferenceCard();
        }
        final doctor = _doctors[i - 1];
        return DoctorCard(
          photoUrl: null,
          name: doctor.name,
          specialty: doctor.specialty,
          variant: DoctorCardVariant.vertical,
          isSelected: _selectedIndex == (i - 1),
          onTap: () => _onSelectDoctor(i - 1),
        );
      },
    );
  }

  Widget _buildNoPreferenceCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _isNoPreference
        ? AppColors.accent
        : (isDark ? AppColors.dividerDark : AppColors.divider);
    final borderWidth = _isNoPreference ? 1.5 : 1.0;
    final bgColor = _isNoPreference
        ? AppColors.accent.withOpacity(isDark ? 0.10 : 0.05)
        : null;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      borderRadius: _isNoPreference
          ? BorderRadius.circular(AppRadius.radiusLG)
          : null,
      onTap: _onSelectNoPreference,
      child: Container(
        decoration: bgColor != null
            ? BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(AppRadius.radiusLG),
              )
            : null,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.divider,
                borderRadius:
                    BorderRadius.circular(AppRadius.radiusFull),
              ),
              child: Icon(
                Icons.people,
                size: 36,
                color: secondaryText,
              ),
            ),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Preference',
                    style: AppTextStyles.heading3
                        .copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'We will find the earliest available slot for you',
                    style: AppTextStyles.body2
                        .copyWith(color: secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        onPressed: _hasSelection ? _onContinue : null,
        isFullWidth: true,
      ),
    );
  }
}

class DoctorItem {
  final String id;
  final String name;
  final String specialty;

  const DoctorItem({
    required this.id,
    required this.name,
    required this.specialty,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'specialty': specialty,
      };
}
