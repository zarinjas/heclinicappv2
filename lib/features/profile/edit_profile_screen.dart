import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_input.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/app_toast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static String routeName = 'EditProfileScreen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _avatarUrl;
  String? _fetchError;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _dobController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      final appState = FFAppState();

      _nameController.text = appState.name ?? '';
      _phoneController.text = appState.phonenumber ?? '';
      _addressController.text = appState.address ?? '';

      try {
        final response = await MedicalAppsApiGroup.profileCall.call(
          authorization: 'Bearer ${appState.tokenauth}',
          accept: 'application/json',
        );
        if (response.statusCode == 200) {
          final avatar =
              MedicalAppsApiGroup.profileCall.avatar(response.jsonBody);
          if (avatar != null && avatar.isNotEmpty) {
            _avatarUrl = 'https://hemedicalapps.com/$avatar';
          }
        }
      } catch (_) {}

      _hasChanges = false;
    } catch (e) {
      if (mounted) {
        setState(() {
          _fetchError = 'Failed to load profile. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = _getMonthAbbr(picked.month);
      final year = picked.year.toString();
      setState(() {
        _dobController.text = '$day $month $year';
        _hasChanges = true;
      });
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final file = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null && mounted) {
      setState(() {
        _hasChanges = true;
      });
      AppToast.showInfo(context, 'Photo selected. Save to upload.');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final appState = FFAppState();
      final result =
          await MedicalAppsApiGroup.updateProfileCall.call(
        authorization: 'Bearer ${appState.tokenauth}',
        fullname: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        accept: 'application/json',
      );

      if (!mounted) return;

      if (result.succeeded) {
        appState.setName(_nameController.text);
        appState.setPhonenumber(_phoneController.text);
        appState.setAddress(_addressController.text);

        setState(() => _hasChanges = false);

        if (mounted) {
          AppToast.showSuccess(context, 'Profile updated successfully');
          context.pop();
        }
      } else {
        if (mounted) {
          AppToast.showError(context, 'Failed to update profile. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await AppDialog.confirmation(
      context,
      title: 'Unsaved Changes',
      message: 'You have unsaved changes. Are you sure you want to go back?',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Editing',
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.primary;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppAppBar.sub(
          title: 'Edit Profile',
          onBack: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              context.pop();
            }
          },
        ),
        body: _isLoading
            ? _buildSkeleton()
            : _fetchError != null
                ? AppErrorState(
                    message: _fetchError!,
                    onRetry: _loadProfile,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.space16),
                          _buildPhotoSection(surfaceColor),
                          const SizedBox(height: AppSpacing.space24),
                          AppInput(
                            controller: _nameController,
                            label: 'Full Name *',
                            hint: 'Enter your full name',
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          AppInput(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          AppInput(
                            controller: _dobController,
                            label: 'Date of Birth',
                            hint: 'dd MMM yyyy',
                            readOnly: true,
                            onTap: _selectDob,
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          AppInput(
                            controller: _addressController,
                            label: 'Address',
                            hint: 'Enter your address',
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppSpacing.space32),
                          AppButton.primary(
                            label: 'Save Changes',
                            onPressed: _isSaving ? null : _saveProfile,
                            isLoading: _isSaving,
                          ),
                          const SizedBox(height: AppSpacing.space24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space16),
          Center(child: AppSkeleton.circle(size: 100)),
          const SizedBox(height: AppSpacing.space24),
          AppSkeleton.card(height: 52),
          const SizedBox(height: AppSpacing.space16),
          AppSkeleton.card(height: 52),
          const SizedBox(height: AppSpacing.space16),
          AppSkeleton.card(height: 52),
          const SizedBox(height: AppSpacing.space16),
          AppSkeleton.card(height: 80),
          const SizedBox(height: AppSpacing.space32),
          AppSkeleton.card(height: 52, borderRadius: AppRadius.radiusXL),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(Color surfaceColor) {
    final initials = _nameController.text.isNotEmpty
        ? _nameController.text
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : '?';

    return GestureDetector(
      onTap: _changePhoto,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withAlpha(76),
                    width: 2,
                  ),
                ),
                child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _avatarUrl!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              initials,
                              style: AppTextStyles.heading1.copyWith(
                                color: AppColors.accent,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.accent,
                            fontSize: 32,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: surfaceColor, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Change Photo',
            style: AppTextStyles.body2.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
