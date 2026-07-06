import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Alia Rahman');
  final _phoneController = TextEditingController(text: '+60 12 345 6789');
  final _dobController = TextEditingController(text: '15 Mar 1990');
  final _addressController = TextEditingController(
    text: 'No. 12, Jalan Burhanuddin Helmi, TTDI',
  );

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 3, 15),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = AppTextStyles.body1.fontSize != null
          ? [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ][picked.month - 1]
          : picked.month.toString().padLeft(2, '0');
      setState(() {
        _dobController.text = '$day $month ${picked.year}';
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accentBlue],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AR',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -4,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change photo')),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            AppInput(
              controller: _nameController,
              label: 'Full Name',
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _dobController,
              label: 'Date of Birth',
              enabled: false,
            ),
            GestureDetector(
              onTap: _pickDateOfBirth,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 0,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppInput(
              controller: _addressController,
              label: 'Address',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Save Changes',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
