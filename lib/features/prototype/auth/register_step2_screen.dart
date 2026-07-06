import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/step_indicator.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _nricController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedDOB;
  String? _selectedNationality;

  static const _nationalities = [
    'Malaysian',
    'Singaporean',
    'Indonesian',
    'Thai',
    'Other',
  ];

  @override
  void dispose() {
    _nricController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDOB =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _pickNationality() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.radiusXL),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.space12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              ..._nationalities.map((nationality) {
                return ListTile(
                  title: Text(
                    nationality,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedNationality = nationality;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppSpacing.space12),
            ],
          ),
        );
      },
    );
  }

  void _onCreateAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          ),
          title: Text(
            'Account created!',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Please log in.',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            AppButton.primary(
              label: 'OK',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Medical Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIndicator(currentStep: 2, totalSteps: 2),
            const SizedBox(height: AppSpacing.space24),
            AppInput(
              controller: _nricController,
              label: 'NRIC / Passport No',
              placeholder: '900101-14-1234',
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Date of Birth',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1.5,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedDOB ?? 'Select date of birth',
                  style: AppTextStyles.body1.copyWith(
                    color: _selectedDOB != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Nationality',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            GestureDetector(
              onTap: _pickNationality,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1.5,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedNationality ?? 'Select nationality',
                        style: AppTextStyles.body1.copyWith(
                          color: _selectedNationality != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _allergiesController,
              label: 'Known Allergies',
              placeholder: 'e.g., peanuts, penicillin',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              label: 'Create Account',
              onPressed: _onCreateAccount,
            ),
          ],
        ),
      ),
    );
  }
}
