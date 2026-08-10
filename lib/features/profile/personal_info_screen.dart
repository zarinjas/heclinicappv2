import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';

/// Personal Information.
///
/// Replaces the FlutterFlow `ProfileEditPageWidget`, which rendered blank: it
/// took its data from query parameters the caller never supplied and then
/// force-unwrapped a null avatar (`_model.img!`) during build. It also saved to
/// `/update`, a route that no longer exists on the backend, and treated the
/// resulting 404 as success.
///
/// This version loads from `GET /v2/auth/me` and saves with `PATCH /v2/auth/me`.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  static String routeName = 'PersonalInfoScreen';
  static String routePath = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _foodAllergiesController = TextEditingController();

  // Read-only identity fields, shown for reference.
  String _email = '';
  String _phone = '';
  String _nric = '';
  String? _sex;

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  static const _sexOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _allergiesController.dispose();
    _foodAllergiesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final response =
          await HeclinicAuthApi.meCall.call(token: FFAppState().tokenauth);

      if (!mounted) return;

      if (!response.succeeded) {
        setState(() {
          _loading = false;
          _loadError = response.statusCode == 401
              ? 'Your session has expired. Please sign in again.'
              : 'Could not load your details. Please try again.';
        });
        return;
      }

      final body = response.jsonBody;
      _nameController.text = MeCall.name(body) ?? '';
      _addressController.text = MeCall.address(body) ?? '';
      _dobController.text = _dateOnly(MeCall.dob(body));
      _nationalityController.text = MeCall.nationality(body) ?? '';
      _allergiesController.text = MeCall.allergies(body) ?? '';
      _foodAllergiesController.text = MeCall.foodAllergies(body) ?? '';

      final sex = MeCall.sex(body);

      setState(() {
        _email = MeCall.email(body) ?? '';
        _phone = MeCall.telephone(body) ?? '';
        _nric = MeCall.nric(body) ?? '';
        _sex = _sexOptions.contains(sex) ? sex : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Network error. Please check your connection.';
      });
    }
  }

  /// The API may return `2001-02-03` or a full timestamp; the field only ever
  /// shows the date part.
  static String _dateOnly(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final t = raw.indexOf('T');
    if (t > 0) return raw.substring(0, t);
    if (raw.length >= 10 && raw[4] == '-') return raw.substring(0, 10);
    return raw;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 25);
    final existing = DateTime.tryParse(_dobController.text);
    if (existing != null) initial = existing;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );

    if (picked != null) {
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() => _dobController.text = '${picked.year}-$m-$d');
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      final response = await HeclinicAuthApi.updateMeCall.call(
        token: FFAppState().tokenauth,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        dob: _dobController.text.trim().isEmpty
            ? null
            : _dobController.text.trim(),
        sex: _sex,
        nationality: _nationalityController.text.trim(),
        allergies: _allergiesController.text.trim(),
        foodAllergies: _foodAllergiesController.text.trim(),
      );

      if (!mounted) return;

      // Unlike the old screen, a failed request is reported as a failure
      // instead of showing "Profile Updated" regardless of the outcome.
      if (!response.succeeded || UpdateMeCall.status(response.jsonBody) != true) {
        final message = UpdateMeCall.message(response.jsonBody);
        _snack(
          (message == null || message.trim().isEmpty)
              ? 'Could not save your details. Please try again.'
              : message.trim(),
          isError: true,
        );
        return;
      }

      // Keep the name shown around the app in sync.
      final appState = FFAppState();
      appState.name = _nameController.text.trim();
      appState.update(() {});

      _snack('Your details have been saved.');
      if (mounted) Navigator.of(context).maybePop();
    } catch (_) {
      if (mounted) {
        _snack('Network error. Please check your connection.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Personal Information'),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? _buildError(isDark)
                : _buildForm(isDark),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: secondary),
            const SizedBox(height: AppSpacing.space16),
            Text(
              _loadError!,
              style: AppTextStyles.body1.copyWith(color: secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.secondary(
              label: 'Try Again',
              onPressed: _load,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space16,
          AppSpacing.space16,
          0,
        ),
        children: [
          _sectionLabel('About You', textColor),
          AppInput(
            controller: _nameController,
            label: 'Full Name',
            placeholder: 'As per your IC or passport',
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: AppSpacing.space16),
          _dobField(isDark),
          const SizedBox(height: AppSpacing.space16),
          _sexField(isDark),
          const SizedBox(height: AppSpacing.space16),
          AppInput(
            controller: _nationalityController,
            label: 'Nationality',
            placeholder: 'e.g. Malaysian',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.space16),
          AppInput(
            controller: _addressController,
            label: 'Address',
            placeholder: 'Your mailing address',
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),

          const SizedBox(height: AppSpacing.space24),
          _sectionLabel('Medical', textColor),
          AppInput(
            controller: _allergiesController,
            label: 'Drug Allergies',
            placeholder: 'Leave blank if none',
            maxLines: 2,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: AppSpacing.space16),
          AppInput(
            controller: _foodAllergiesController,
            label: 'Food Allergies',
            placeholder: 'Leave blank if none',
            maxLines: 2,
            textInputAction: TextInputAction.newline,
          ),

          const SizedBox(height: AppSpacing.space24),
          _sectionLabel('Account', textColor),
          _readOnlyRow('Phone', _phone, Icons.phone_outlined, isDark),
          _readOnlyRow('Email', _email, Icons.mail_outline_rounded, isDark),
          _readOnlyRow('IC / Passport', _nric, Icons.badge_outlined, isDark),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Contact the clinic to change your phone or IC. '
            'Your email can be updated from the profile screen.',
            style: AppTextStyles.body2.copyWith(
              color:
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.space32),
          AppButton.primary(
            label: 'Save Changes',
            onPressed: _saving ? null : _save,
            isLoading: _saving,
          ),
          // Clear the floating bottom nav drawn over this screen.
          SizedBox(
            height:
                AppSpacing.space32 + 80 + MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Text(text, style: AppTextStyles.heading3.copyWith(color: color)),
    );
  }

  Widget _dobField(bool isDark) {
    // AbsorbPointer keeps the AppInput look while routing taps to the picker.
    return GestureDetector(
      onTap: _pickDob,
      child: AbsorbPointer(
        child: AppInput(
          controller: _dobController,
          label: 'Date of Birth',
          placeholder: 'YYYY-MM-DD',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            return DateTime.tryParse(v.trim()) == null
                ? 'Use the date picker to set this'
                : null;
          },
        ),
      ),
    );
  }

  Widget _sexField(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.inputBorder;
    final fillColor = isDark ? AppColors.inputBgDark : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sex',
          style: AppTextStyles.label.copyWith(color: textColor),
        ),
        const SizedBox(height: AppSpacing.space8),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sex,
              isExpanded: true,
              hint: Text(
                'Select',
                style: AppTextStyles.body1.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              dropdownColor: fillColor,
              style: AppTextStyles.body1.copyWith(color: textColor),
              items: _sexOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sex = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final shown = value.trim().isEmpty ? 'Not set' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondary),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body2.copyWith(color: secondary)),
                const SizedBox(height: 2),
                Text(
                  shown,
                  style: AppTextStyles.body1.copyWith(color: textColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 18, color: secondary),
            tooltip: 'Copy $label',
            onPressed: shown == 'Not set'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: value));
                    _snack('$label copied');
                  },
          ),
        ],
      ),
    );
  }
}
