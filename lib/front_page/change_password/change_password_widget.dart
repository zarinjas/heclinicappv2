import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_app_bar.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dialog.dart';
import '/core/widgets/app_input.dart';
import '/core/widgets/app_toast.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  static String routeName = 'ChangePassword';
  static String routePath = '/changePassword';

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please enter a new password';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include both letters and numbers';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      final response =
          await MedicalAppsApiGroup.firsttimechangepasswordCall.call(
        authorization: 'Bearer ${FFAppState().tokenauth}',
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      final ok = MedicalAppsApiGroup.firsttimechangepasswordCall
              .status(response.jsonBody ?? '') ??
          false;

      if (!ok) {
        AppToast.error(
          context,
          message: 'Could not change your password. Please try again.',
        );
        return;
      }

      FFAppState().passwordChanged = true;

      await AppDialog.success(
        context,
        title: 'Password changed',
        message:
            'Your password has been updated. Use it the next time you sign in.',
      );

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Network error. Please check your connection.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Change Password'),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space16,
              0,
            ),
            children: [
              Text(
                'To keep your account secure, create a new password that only '
                'you know. Use at least 8 characters with letters and numbers.',
                style: AppTextStyles.body1.copyWith(color: secondary),
              ),
              const SizedBox(height: AppSpacing.space24),
              AppInput(
                controller: _passwordController,
                label: 'New Password',
                placeholder: 'Enter a new password',
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppInput(
                controller: _confirmController,
                label: 'Confirm Password',
                placeholder: 'Re-enter the new password',
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                validator: _validateConfirm,
              ),
              const SizedBox(height: AppSpacing.space32),
              AppButton.primary(
                label: 'Save Password',
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
