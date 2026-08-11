import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/backend/api_requests/api_calls.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_radius.dart';
import '/core/widgets/app_button.dart';
import '/app_state.dart';
import '/core/services/doctor_service.dart';
import 'booking_flow_model.dart';

class DoctorSelectionScreenWidget extends StatefulWidget {
  const DoctorSelectionScreenWidget({super.key});

  static const String routeName = 'doctorSelectionScreen';
  static const String routePath = '/doctorSelectionScreen';

  @override
  State<DoctorSelectionScreenWidget> createState() =>
      _DoctorSelectionScreenWidgetState();
}

class _DoctorSelectionScreenWidgetState
    extends State<DoctorSelectionScreenWidget> {
  final BookingFlowModel _bookingModel = BookingFlowModel();

  List<DoctorItem> _doctors = [];
  String? _selectedDoctorId;
  bool _isNoPreference = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final service = DoctorService.instance;
      final wasInitialised = service.isInitialised;
      await service.init();
      // Re-fetch once the service has loaded before so newly toggled
      // "Visible in App" doctors appear without an app restart.
      if (wasInitialised) {
        await service.refresh();
      }

      final selectedBranch = _bookingModel.selectedBranchName;
      final doctors = <DoctorItem>[];
      for (final d in service.doctors) {
        // Prefer doctors assigned to the selected branch, but keep doctors
        // without a branch mapping so the list is never empty.
        if (d.branchName != null &&
            d.branchName!.isNotEmpty &&
            d.branchName != selectedBranch) {
          continue;
        }
        doctors.add(DoctorItem(
          id: d.id.toString(),
          name: d.name,
          specialty: d.specialty,
          photoUrl: d.photoUrl ?? '',
        ));
      }

      String? lastConsultedName;
      if (FFAppState().idplato.isNotEmpty) {
        lastConsultedName = await _findLastConsultedDoctor();
      }

      DoctorItem? preselected;
      if (lastConsultedName != null && lastConsultedName.isNotEmpty) {
        final needle = lastConsultedName!.trim().toLowerCase();
        for (final d in doctors) {
          if (d.name.trim().toLowerCase() == needle) {
            preselected = d;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _doctors = doctors;
          if (preselected != null) {
            _isNoPreference = false;
            _selectedDoctorId = preselected!.id;
            _bookingModel.selectDoctor(
              id: preselected!.id,
              name: preselected!.name,
              isNoPreference: false,
            );
          }
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

  /// Returns the name of the doctor from the most recent PAST appointment,
  /// used to pre-select the doctor the patient last consulted.
  Future<String?> _findLastConsultedDoctor() async {
    try {
      final response = await GetAppointmentCall.call(
        patientId: FFAppState().idplato,
        forceRefresh: true,
      );
      if (!response.succeeded) return null;

      final names = GetAppointmentCall.doctorname(response.jsonBody) ?? [];
      final starts = GetAppointmentCall.start(response.jsonBody) ?? [];
      final now = DateTime.now();

      String? lastDoctor;
      DateTime? lastDate;
      for (var i = 0; i < names.length; i++) {
        final dt = DateTime.tryParse(starts.length > i ? starts[i] : '');
        if (dt == null || !dt.isBefore(now)) continue;
        if (lastDate == null || dt.isAfter(lastDate)) {
          lastDate = dt;
          lastDoctor = names[i];
        }
      }
      return lastDoctor;
    } catch (_) {
      return null;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    return error?.toString() ?? 'An unexpected error occurred';
  }

  void _onNoPreferenceSelected() {
    setState(() {
      _isNoPreference = true;
      _selectedDoctorId = null;
    });
    _bookingModel.selectDoctor(
      id: '',
      name: 'No Preference',
      isNoPreference: true,
    );
  }

  void _onDoctorSelected(DoctorItem doctor) {
    setState(() {
      _isNoPreference = false;
      _selectedDoctorId = doctor.id;
    });
    _bookingModel.selectDoctor(
      id: doctor.id,
      name: doctor.name,
      isNoPreference: false,
    );
  }

  void _onNextPressed() {
    if (_isNoPreference || _selectedDoctorId != null) {
      context.push('/dateTimeSlotSelection');
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
      _StepData(1, 'Branch', false),
      _StepData(2, 'Doctor', true),
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
    if (_doctors.isEmpty) {
      return _buildEmptyState(isDark);
    }
    return _buildDoctorList(isDark, accentColor);
  }

  Widget _buildSkeletonLoader(bool isDark) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final skeleton = isDark ? AppColors.dividerDark : AppColors.divider;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, __) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: skeleton,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: skeleton,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusXS),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      width: 100,
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
              onPressed: _loadDoctors,
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
              Icons.person_off,
              size: 64,
              color: secondaryText,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'No doctors available for this branch',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 18,
                color: textColor,
              ),
              textAlign: TextAlign.center,
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

  Widget _buildDoctorList(bool isDark, Color accentColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 1 + _doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, index) {
        if (index == 0) {
          return _buildNoPreferenceCard(isDark, accentColor);
        }
        final doctor = _doctors[index - 1];
        final isSelected = _selectedDoctorId == doctor.id;
        return _buildDoctorCard(doctor, isSelected, isDark, accentColor);
      },
    );
  }

  Widget _buildNoPreferenceCard(bool isDark, Color accentColor) {
    final isSelected = _isNoPreference;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    final iconBg = isDark ? AppColors.dividerDark : AppColors.chipFilterDefaultBg;
    return GestureDetector(
      onTap: _onNoPreferenceSelected,
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
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppRadius.radiusLG),
              ),
              child: Icon(
                Icons.groups,
                size: 28,
                color: secondaryText,
              ),
            ),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No Preference',
                    style: AppTextStyles.heading3.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'We will find the earliest available slot for you',
                    style: AppTextStyles.body2.copyWith(color: secondaryText),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    DoctorItem doctor,
    bool isSelected,
    bool isDark,
    Color accentColor,
  ) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    final avatarBg = isDark ? AppColors.dividerDark : AppColors.divider;
    return GestureDetector(
      onTap: () => _onDoctorSelected(doctor),
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
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: avatarBg,
              backgroundImage: doctor.photoUrl.isNotEmpty
                  ? NetworkImage(doctor.photoUrl)
                  : null,
              child: doctor.photoUrl.isNotEmpty
                  ? null
                  : Text(
                      doctor.name.isNotEmpty
                          ? doctor.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: AppTextStyles.heading3.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doctor.specialty.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      doctor.specialty,
                      style: AppTextStyles.body2.copyWith(color: secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isDark, Color accentColor) {
    final isEnabled = _isNoPreference || _selectedDoctorId != null;
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

class DoctorItem {
  final String id;
  final String name;
  final String specialty;
  final String photoUrl;

  DoctorItem({
    required this.id,
    required this.name,
    required this.specialty,
    this.photoUrl = '',
  });
}
