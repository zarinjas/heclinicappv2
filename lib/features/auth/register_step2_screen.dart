import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/step_indicator.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});

  static String routeName = 'RegisterStep2Screen';
  static String routePath = '/registerStep2';

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedDOB;
  String _selectedSex = 'Male';

  @override
  void initState() {
    super.initState();
    final appState = FFAppState();
    _nameController.text = appState.registerName;
    _emailController.text = appState.registerEmail;
    _selectedSex = appState.registerSex.isNotEmpty ? appState.registerSex : 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDOB =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    final appState = FFAppState();
    appState.registerName = _nameController.text.trim();
    appState.registerEmail = _emailController.text.trim();
    appState.registerDob = _selectedDOB ?? '';
    appState.registerSex = _selectedSex;
    appState.registerAllergies = _allergiesController.text.trim();
    appState.update(() {});

    context.go('/registerStep3');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.space16),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                  onPressed: () => context.go('/registerStep1'),
                ),
                const SizedBox(height: AppSpacing.space8),
                const StepIndicator(
                  currentStep: 1,
                  totalSteps: 3,
                  labels: ['Identity', 'Details', 'Password'],
                ),
                const SizedBox(height: AppSpacing.space32),
                Text(
                  'Personal Details',
                  style: AppTextStyles.heading1.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Tell us a little about yourself.',
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space32),

                AppInput(
                  controller: _nameController,
                  label: 'Full Name',
                  placeholder: 'Alia Rahman',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space16),

                AppInput(
                  controller: _emailController,
                  label: 'Email',
                  placeholder: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space16),

                // --- Date of Birth ---
                Text(
                  'Date of Birth',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.inputBgDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                      border: Border.all(
                        color: isDark ? AppColors.dividerDark : AppColors.inputBorder,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.space12),
                        Text(
                          _selectedDOB ?? 'Select date of birth',
                          style: AppTextStyles.body1.copyWith(
                            color: _selectedDOB != null
                                ? (isDark ? AppColors.textPrimaryDark : AppColors.primary)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),

                // --- Sex ---
                Text(
                  'Sex',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: ['Male', 'Female'].map((sex) {
                    final isSelected = _selectedSex == sex;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: sex == 'Male' ? AppSpacing.space8 : 0,
                          left: sex == 'Female' ? AppSpacing.space8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSex = sex),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : (isDark ? AppColors.inputBgDark : AppColors.surface),
                              borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : (isDark ? AppColors.dividerDark : AppColors.inputBorder),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              sex,
                              style: AppTextStyles.button.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.space16),

                AppInput(
                  controller: _allergiesController,
                  label: 'Known Allergies',
                  placeholder: 'e.g., peanuts, penicillin',
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: AppSpacing.space32),
                AppButton.primary(
                  label: 'Next',
                  onPressed: _onNext,
                ),
                const SizedBox(height: AppSpacing.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.body2.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Login',
                        style: AppTextStyles.label.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
