import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/app_toast.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  static String routeName = 'NotificationPrefsScreen';

  @override
  State<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  bool _isLoading = true;
  String? _fetchError;

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _appointmentReminders = true;
  bool _healthUpdates = true;
  bool _promotionsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      final appState = FFAppState();
      final patientId = appState.platoID ?? appState.id_patient ?? '';

      if (patientId.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('notification_preferences')
            .doc(patientId)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _pushEnabled = data['push'] as bool? ?? true;
            _emailEnabled = data['email'] as bool? ?? true;
            _appointmentReminders =
                data['appointmentReminders'] as bool? ?? true;
            _healthUpdates = data['healthUpdates'] as bool? ?? true;
            _promotionsEnabled = data['promotions'] as bool? ?? false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = 'Failed to load preferences.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final appState = FFAppState();
      final patientId = appState.platoID ?? appState.id_patient ?? '';

      if (patientId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('notification_preferences')
            .doc(patientId)
            .set({key: value}, SetOptions(merge: true));
      }

      if (mounted) {
        AppToast.showInfo(context, 'Preferences updated');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to save preference.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.primary;
    final subtitleColor =
        isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Notification Preferences',
        onBack: () => context.pop(),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _fetchError != null
              ? AppErrorState(
                  message: _fetchError!,
                  onRetry: _loadPreferences,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        'Choose which notifications you want to receive.',
                        style: AppTextStyles.body1.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space20),
                      _buildSection(
                        surfaceColor,
                        textColor,
                        subtitleColor,
                        'Channels',
                        [
                          _buildToggleRow(
                            surfaceColor,
                            textColor,
                            subtitleColor,
                            icon: Icons.notifications_active_outlined,
                            label: 'Push Notifications',
                            subtitle: 'Receive notifications on your device',
                            value: _pushEnabled,
                            onChanged: (val) {
                              setState(() => _pushEnabled = val);
                              _savePreference('push', val);
                            },
                          ),
                          _buildToggleRow(
                            surfaceColor,
                            textColor,
                            subtitleColor,
                            icon: Icons.email_outlined,
                            label: 'Email Notifications',
                            subtitle: 'Receive notifications via email',
                            value: _emailEnabled,
                            onChanged: (val) {
                              setState(() => _emailEnabled = val);
                              _savePreference('email', val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      _buildSection(
                        surfaceColor,
                        textColor,
                        subtitleColor,
                        'Notification Types',
                        [
                          _buildToggleRow(
                            surfaceColor,
                            textColor,
                            subtitleColor,
                            icon: Icons.calendar_today_outlined,
                            label: 'Appointment Reminders',
                            subtitle: 'Reminders about upcoming appointments',
                            value: _appointmentReminders,
                            onChanged: (val) {
                              setState(() => _appointmentReminders = val);
                              _savePreference('appointmentReminders', val);
                            },
                          ),
                          _buildToggleRow(
                            surfaceColor,
                            textColor,
                            subtitleColor,
                            icon: Icons.favorite_outline,
                            label: 'Health Updates',
                            subtitle: 'Updates on new health records and results',
                            value: _healthUpdates,
                            onChanged: (val) {
                              setState(() => _healthUpdates = val);
                              _savePreference('healthUpdates', val);
                            },
                          ),
                          _buildToggleRow(
                            surfaceColor,
                            textColor,
                            subtitleColor,
                            icon: Icons.local_offer_outlined,
                            label: 'Promotions & Offers',
                            subtitle: 'Special offers and health packages',
                            value: _promotionsEnabled,
                            onChanged: (val) {
                              setState(() => _promotionsEnabled = val);
                              _savePreference('promotions', val);
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space8),
          AppSkeleton.text(width: 280),
          const SizedBox(height: AppSpacing.space20),
          AppSkeleton.card(height: 140),
          const SizedBox(height: AppSpacing.space16),
          AppSkeleton.card(height: 220),
        ],
      ),
    );
  }

  Widget _buildSection(
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark() ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space8,
            ),
            child: Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: textColor),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    Color surfaceColor,
    Color textColor,
    Color subtitleColor, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Divider(
          height: 1,
          color: isDark() ? AppColors.dividerDark : AppColors.divider,
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body1.copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      subtitle,
                      style: AppTextStyles.body2.copyWith(color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isDark() => Theme.of(context).brightness == Brightness.dark;
}
