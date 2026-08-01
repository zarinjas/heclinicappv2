import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  final _prefs = <_NP>[
    _NP('Appointment Updates', 'Booking confirmations and reminders', true),
    _NP('New Documents', 'When test results are uploaded', true),
    _NP('Promotions & Offers', 'Health packages and promotions', true),
    _NP('Reminders', 'Appointment and checkup reminders', false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Notification Preferences'),
      body: ListView(
        children: List.generate(_prefs.length, (i) {
          final p = _prefs[i];
          return SwitchListTile(
            title: Text(p.title, style: AppTextStyles.body1.copyWith(color: tc)),
            subtitle: Text(p.subtitle, style: AppTextStyles.body2.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            value: p.enabled, activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _prefs[i] = _NP(p.title, p.subtitle, v));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.title} ${v ? "enabled" : "disabled"}')));
            },
          );
        }),
      ),
    );
  }
}

class _NP {
  final String title, subtitle;
  final bool enabled;
  const _NP(this.title, this.subtitle, this.enabled);
}
