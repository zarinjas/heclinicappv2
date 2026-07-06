import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifications = <_NotificationData>[
    const _NotificationData(
      title: 'Appointment Confirmed',
      body: 'Your appointment with Dr. Ahmad Rizal on 14 Jul 2025 has been confirmed.',
      isRead: false,
      type: 'appointment_confirmed',
    ),
    const _NotificationData(
      title: 'New Document Available',
      body: 'Your blood test results from 05 Jul 2025 are now available.',
      isRead: false,
      type: 'new_document',
    ),
    const _NotificationData(
      title: 'Appointment Reminder',
      body: 'You have an appointment with Dr. Sarah Lim tomorrow at 2:00 PM.',
      isRead: false,
      type: 'reminder',
    ),
    const _NotificationData(
      title: 'Checkup Completed',
      body: 'Your annual checkup with Dr. Tan Wei Ming is complete. View your records.',
      isRead: true,
      type: 'general',
    ),
    const _NotificationData(
      title: 'System Update',
      body: 'He Medical Clinic app has been updated with new features.',
      isRead: true,
      type: 'general',
    ),
    const _NotificationData(
      title: 'Seasonal Flu Shot Available',
      body: 'Book your flu vaccination at any He Clinic branch. Walk-ins welcome.',
      isRead: true,
      type: 'general',
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _NotificationData(
          title: _notifications[i].title,
          body: _notifications[i].body,
          isRead: true,
          type: _notifications[i].type,
        );
      }
    });
  }

  void _dismiss(int index) {
    setState(() => _notifications.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification dismissed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _notifications.length - 1
                  ? AppSpacing.space8
                  : 0,
            ),
            child: NotificationItem(
              title: n.title,
              body: n.body,
              isRead: n.isRead,
              type: n.type,
              onDismiss: () => _dismiss(index),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationData {
  final String title;
  final String body;
  final bool isRead;
  final String type;

  const _NotificationData({
    required this.title,
    required this.body,
    required this.isRead,
    required this.type,
  });
}
