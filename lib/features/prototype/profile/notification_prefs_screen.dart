import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  final _prefs = <_NotificationPref>[
    const _NotificationPref(
      title: 'Appointment Updates',
      subtitle: 'Booking confirmations and reminders',
      enabled: true,
    ),
    const _NotificationPref(
      title: 'New Documents',
      subtitle: 'When test results are uploaded',
      enabled: true,
    ),
    const _NotificationPref(
      title: 'Promotions & Offers',
      subtitle: 'Health packages and promotions',
      enabled: true,
    ),
    const _NotificationPref(
      title: 'Reminders',
      subtitle: 'Appointment and checkup reminders',
      enabled: false,
    ),
  ];

  void _handleToggle(int index, bool value) {
    setState(() {
      _prefs[index] = _NotificationPref(
        title: _prefs[index].title,
        subtitle: _prefs[index].subtitle,
        enabled: value,
      );
    });
    final status = value ? 'enabled' : 'disabled';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_prefs[index].title} $status')),
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
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        children: List.generate(_prefs.length, (index) {
          final pref = _prefs[index];
          return SwitchListTile(
            title: Text(
              pref.title,
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              pref.subtitle,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            value: pref.enabled,
            activeColor: AppColors.accent,
            onChanged: (value) => _handleToggle(index, value),
          );
        }),
      ),
    );
  }
}

class _NotificationPref {
  final String title;
  final String subtitle;
  final bool enabled;

  const _NotificationPref({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });
}
