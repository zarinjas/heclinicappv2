import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../backend/api_requests/heclinic_auth_api.dart';
import '../../core/services/branding_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class TroubleSigningInScreen extends StatefulWidget {
  const TroubleSigningInScreen({super.key});

  static String routeName = 'TroubleSigningInScreen';
  static String routePath = '/troubleSigningIn';

  @override
  State<TroubleSigningInScreen> createState() => _TroubleSigningInScreenState();
}

class _TroubleSigningInScreenState extends State<TroubleSigningInScreen> {
  bool _isSending = false;
  bool? _fcmSuccess;
  String? _fcmMessage;
  late final String _identifier;
  late final String _countryCode;

  @override
  void initState() {
    super.initState();
    final appState = FFAppState();
    _identifier = appState.resetIdentifier;
    _countryCode = appState.resetCountryCode;
  }

  Future<void> _sendFcmOtp() async {
    if (_identifier.isEmpty) {
      setState(() {
        _fcmSuccess = false;
        _fcmMessage = 'Please enter your details first on the previous screen.';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _fcmSuccess = null;
      _fcmMessage = null;
    });

    try {
      final result = await HeclinicAuthApi.sendFcmOtpCall.call(
        identifier: _identifier,
        countryCode: _countryCode,
      );

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _fcmSuccess =
            result.succeeded && (SendFcmOtpCall.status(result.jsonBody) == true);
        _fcmMessage = _fcmSuccess == true
            ? 'Check your device notifications! The code should arrive shortly.'
            : (SendFcmOtpCall.message(result.jsonBody) ?? 'Unable to send notification. Please try a different method.');
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _fcmSuccess = false;
          _fcmMessage = 'Network error. Please check your connection.';
        });
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final number = BrandingService.instance.clinicWhatsapp;
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.space16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                  onPressed: () => context.go('/forgotEmail'),
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
              const Icon(
                Icons.support_agent_outlined,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                'Trouble Signing In?',
                style: AppTextStyles.heading1.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Try one of these options to receive your verification code.',
                style: AppTextStyles.body1.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space32),

              // Option 1: Send code as app notification
              _OptionCard(
                icon: Icons.notifications_active_outlined,
                title: 'Send Code as App Notification',
                subtitle:
                    'If you have logged into this app before with the same device, we can send the code directly as a push notification.',
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.space8),
              if (_isSending)
                AppButton.primary(
                  label: 'Sending...',
                  onPressed: null,
                  isLoading: true,
                )
              else if (_fcmSuccess == null)
                AppButton.primary(
                  label: 'Send Code via App Notification',
                  onPressed: _sendFcmOtp,
                )
              else if (_fcmSuccess == true)
                Column(
                  children: [
                    const Icon(Icons.check_circle, size: 24, color: Colors.green),
                    const SizedBox(height: AppSpacing.space8),
                    AppButton.ghost(
                      label: 'Enter Code Now',
                      onPressed: () => context.go('/forgotOtp'),
                      isFullWidth: true,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      _fcmMessage ?? '',
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    AppButton.ghost(
                      label: 'Try Again',
                      onPressed: _sendFcmOtp,
                      isFullWidth: true,
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.space24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    child: Text(
                      'or',
                      style: AppTextStyles.body2.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),

              const SizedBox(height: AppSpacing.space24),

              // Option 2: Contact clinic via WhatsApp
              _OptionCard(
                icon: Icons.chat_outlined,
                title: 'Contact Clinic on WhatsApp',
                subtitle:
                    'Message our clinic team directly. They can help verify your identity and assist with accessing your account.',
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.space8),
              AppButton.secondary(
                label: 'Chat with Clinic on WhatsApp',
                onPressed: _openWhatsApp,
              ),

              const SizedBox(height: AppSpacing.space32),

              // Option 3: Go back and try another method
              GestureDetector(
                onTap: () => context.go('/forgotEmail'),
                child: Text(
                  'Try another phone number or email',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBgDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.inputBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.radiusSM),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.space12),
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
                const SizedBox(height: AppSpacing.space4),
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
