import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../backend/backend.dart';
import '../../backend/schema/historynotif_record.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static String routeName = 'NotificationsScreen';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _markingAllRead = false;
  Stream<List<HistorynotifRecord>>? _notificationStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _notificationStream = queryHistorynotifRecord(
      queryBuilder: (q) => q
          .where('id_patient', isEqualTo: FFAppState().idplato)
          .orderBy('created_at', descending: true),
    );
  }

  Future<void> _markAllRead() async {
    if (_markingAllRead) return;
    setState(() => _markingAllRead = true);
    try {
      final unread = await queryHistorynotifRecordOnce(
        queryBuilder: (q) => q
            .where('id_patient', isEqualTo: FFAppState().idplato)
            .where('read', isEqualTo: 'no'),
      );
      for (final notif in unread) {
        await notif.reference
            .update(createHistorynotifRecordData(readBool: true));
      }
      if (mounted) {
        FFAppState().resetNotifCount();
        setState(() => _markingAllRead = false);
      }
    } catch (_) {
      if (mounted) setState(() => _markingAllRead = false);
    }
  }

  Future<void> _handleNotificationTap(HistorynotifRecord notif) async {
    if (!notif.readBool) {
      await notif.reference
          .update(createHistorynotifRecordData(readBool: true));
      _updateUnreadCount();
    }
    if (!mounted) return;

    final deepLink = notif.deepLink;
    if (deepLink.isNotEmpty) {
      switch (deepLink) {
        case 'appointments':
          context.pushNamed('MyBookingPage');
          break;
        case 'health/records':
        case 'health/vitals':
        case 'health/documents':
          context.pushNamed('Reports',
              queryParameters: {'id': FFAppState().idplato});
          break;
        case 'profile':
          context.pushNamed('HomepageNew');
          break;
        default:
          context.pushNamed('Reports',
              queryParameters: {'id': FFAppState().idplato});
      }
    }
  }

  Future<void> _handleDismiss(HistorynotifRecord notif) async {
    if (!notif.readBool) {
      await notif.reference
          .update(createHistorynotifRecordData(readBool: true));
      _updateUnreadCount();
    }
  }

  void _updateUnreadCount() {
    final current =
        int.tryParse(FFAppState().coutnnotif) ?? 1;
    final updated = current > 0 ? current - 1 : 0;
    if (updated == 0) {
      FFAppState().resetNotifCount();
    } else {
      FFAppState().coutnnotif = updated.toString();
    }
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space4,
        ),
        child: AppSkeleton.listItem(),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: AppEmptyState(
        icon: Icons.notifications_none,
        title: "You're all caught up!",
        subtitle: "We'll let you know when there's something new",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Notifications',
        onBack: () {},
        trailing: _markingAllRead
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : GestureDetector(
                onTap: _markAllRead,
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      body: StreamBuilder<List<HistorynotifRecord>>(
        stream: _notificationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return _buildSkeleton();
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Could not load notifications',
              subtitle: 'Check your connection and try again',
              onRetry: () {
                setState(() {
                  _initStream();
                });
              },
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _initStream();
                });
              },
              child: ListView(children: [_buildEmpty()]),
            );
          }

          return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _initStream();
                  });
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: AppSpacing.space16,
                    endIndent: AppSpacing.space16,
                  ),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return NotificationItem(
                      key: ValueKey(
                          'notification_${notif.reference.id}'),
                      title: notif.title.isNotEmpty
                          ? notif.title
                          : notif.tittle,
                      body: notif.body.isNotEmpty
                          ? notif.body
                          : notif.message,
                      createdAt: notif.createdAt,
                      isRead: notif.readBool,
                      type: notif.type,
                      deepLink: notif.deepLink,
                      reference: notif.reference,
                      onTap: () => _handleNotificationTap(notif),
                      onDismiss: () =>
                          _handleDismiss(notif),
                    );
                  },
                ),
              );
        },
      ),
    );
  }
}
