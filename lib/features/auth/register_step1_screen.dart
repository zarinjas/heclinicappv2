import 'dart:async';
import 'package:flutter/material.dart';
import '/core/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/step_indicator.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  static String routeName = 'RegisterStep1Screen';
  static String routePath = '/registerStep1';

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nricController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedNationality;
  bool _isLookingUp = false;
  bool _isLookingUpPhone = false;
  Timer? _nricDebounce;
  Timer? _phoneDebounce;

  bool _nricFound = false;
  String? _nricName;
  String? _foundIdplato;

  bool _phoneFound = false;
  String? _phoneName;
  String? _phoneNric;

  static const _nationalities = [
    'Malaysian',
    'Singaporean',
    'Indonesian',
    'Thai',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nricController.addListener(_onNricTextChanged);
    _phoneController.addListener(_onPhoneTextChanged);
  }

  @override
  void dispose() {
    _nricDebounce?.cancel();
    _phoneDebounce?.cancel();
    _nricController.removeListener(_onNricTextChanged);
    _phoneController.removeListener(_onPhoneTextChanged);
    _nricController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNricTextChanged() => _onNricChanged(_nricController.text);
  void _onPhoneTextChanged() => _onPhoneChanged(_phoneController.text);

  void _onNricChanged(String value) {
    _nricDebounce?.cancel();
    _nricFound = false;
    _nricName = null;
    _foundIdplato = null;

    final trimmed = value.trim();
    if (trimmed.length < 4) return;

    _nricDebounce = Timer(const Duration(milliseconds: 600), () {
      _lookupNric(trimmed);
    });
  }

  void _onPhoneChanged(String value) {
    _phoneDebounce?.cancel();
    _phoneFound = false;
    _phoneName = null;
    _phoneNric = null;

    final trimmed = value.trim();
    if (trimmed.length < 8) return;

    _phoneDebounce = Timer(const Duration(milliseconds: 600), () {
      _lookupPhone(trimmed);
    });
  }

  Future<void> _lookupNric(String nric) async {
    if (!mounted) return;
    setState(() => _isLookingUp = true);

    try {
      final response = await HeclinicAuthApi.checkNricCall.call(nric: nric);

      if (!mounted) return;

      if (response.succeeded && (CheckNricCall.exists(response.jsonBody) == true)) {
        final name = CheckNricCall.name(response.jsonBody);
        final idplato = CheckNricCall.idplato(response.jsonBody);

        setState(() {
          _nricFound = true;
          _nricName = name;
          _foundIdplato = idplato;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  Future<void> _lookupPhone(String phone) async {
    if (!mounted) return;
    setState(() => _isLookingUpPhone = true);

    try {
      final response = await HeclinicAuthApi.checkPhoneCall.call(telephone: phone);

      if (!mounted) return;

      if (response.succeeded && (CheckPhoneCall.exists(response.jsonBody) == true)) {
        final name = CheckPhoneCall.name(response.jsonBody);
        final platoNric = CheckPhoneCall.nric(response.jsonBody);
        final idplato = CheckPhoneCall.idplato(response.jsonBody);

        setState(() {
          _phoneFound = true;
          _phoneName = name;
          _phoneNric = platoNric;

          // If NRIC not yet found but phone lookup found a match, use it
          if (!_nricFound && idplato != null && idplato.isNotEmpty) {
            _foundIdplato = idplato;
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLookingUpPhone = false);
    }
  }

  bool get _phoneAndNricConflict =>
      _nricFound && _phoneFound && _phoneNric != null &&
      _phoneNric!.isNotEmpty &&
      _nricController.text.trim() != _phoneNric;

  void _pickNationality() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXL)),
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
              ..._nationalities.map((n) => ListTile(
                    title: Text(
                      n,
                      style: AppTextStyles.body1.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedNationality = n);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: AppSpacing.space12),
            ],
          ),
        );
      },
    );
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNationality == null) {
      AppToast.warning(context, message: 'Please select your nationality.');
      return;
    }

    final appState = FFAppState();
    appState.registerNric = _nricController.text.trim();
    appState.registerPhone = _phoneController.text.trim();
    appState.registerNationality = _selectedNationality!;
    appState.registerIdplato = _foundIdplato ?? '';
    appState.registerNricType = '';
    appState.registerAnonymous = false;
    appState.phonefield = _phoneController.text.trim();
    appState.update(() {});

    context.go('/registerStep2');
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
                  onPressed: () => context.go('/welcome'),
                ),
                const SizedBox(height: AppSpacing.space8),
                const StepIndicator(
                  currentStep: 0,
                  totalSteps: 3,
                  labels: ['Identity', 'Details', 'Password'],
                ),
                const SizedBox(height: AppSpacing.space32),
                Text(
                  'Verify Your Identity',
                  style: AppTextStyles.heading1.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'We\'ll check if you already have records with us.',
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space32),

                // --- NRIC / Passport ---
                AppInput(
                  controller: _nricController,
                  label: 'NRIC / Passport No',
                  placeholder: '900101-14-1234',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your NRIC or passport number';
                    }
                    return null;
                  },
                ),
                if (_isLookingUp) ...[
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        'Checking records...',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_nricFound && _nricName != null) ...[
                  const SizedBox(height: AppSpacing.space8),
                  _buildFoundBanner(
                    isDark: isDark,
                    icon: Icons.check_circle_outline,
                    title: 'Existing record found',
                    subtitle: _nricName!,
                    color: AppColors.success,
                  ),
                ],

                const SizedBox(height: AppSpacing.space16),

                // --- Phone ---
                AppInput(
                  controller: _phoneController,
                  label: 'Phone Number',
                  placeholder: '+60 12 345 6789',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _onNext(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                if (_isLookingUpPhone) ...[
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        'Checking records...',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_phoneAndNricConflict) ...[
                  const SizedBox(height: AppSpacing.space8),
                  _buildFoundBanner(
                    isDark: isDark,
                    icon: Icons.warning_amber_rounded,
                    title: 'Phone registered to different patient',
                    subtitle: '${_phoneName ?? "Unknown"} (NRIC: ${_phoneNric ?? "N/A"})',
                    color: AppColors.warning,
                  ),
                ],

                const SizedBox(height: AppSpacing.space16),

                // --- Nationality ---
                Text(
                  'Nationality',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                GestureDetector(
                  onTap: _pickNationality,
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
                        Expanded(
                          child: Text(
                            _selectedNationality ?? 'Select nationality',
                            style: AppTextStyles.body1.copyWith(
                              color: _selectedNationality != null
                                  ? (isDark ? AppColors.textPrimaryDark : AppColors.primary)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildFoundBanner({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
