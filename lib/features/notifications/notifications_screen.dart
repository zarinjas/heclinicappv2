import 'package:flutter/material.dart';
import '/core/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/services/notification_inbox_service.dart';
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
  bool _isLoading = true;
  bool _hasError = false;
  bool _markingAllRead = false;
  List<InboxNotification> _notifications = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final page = await NotificationInboxService.instance.fetch();
      if (!mounted) return;
      setState(() {
        _notifications = page.notifications;
        _isLoading = false;
      });
      _syncBadge(page.unreadCount);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  /// Keep the global unread badge in step with the server's count.
  void _syncBadge(int unreadCount) {
    if (unreadCount <= 0) {
      FFAppState().resetNotifCount();
    } else {
      FFAppState().coutnnotif = unreadCount.toString();
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAllRead) return;
    setState(() => _markingAllRead = true);

    final ok = await NotificationInboxService.instance.markAllRead();
    if (!mounted) return;

    setState(() {
      _markingAllRead = false;
      if (ok) {
        _notifications = _notifications
            .map((n) => n.isRead ? n : n.copyWith(isRead: true))
            .toList();
      }
    });

    if (ok) {
      _syncBadge(0);
    } else {
      AppToast.error(context, message: 'Could not mark all as read.');
    }
  }

  Future<void> _markRead(InboxNotification notification) async {
    if (notification.isRead) return;

    // Update locally first so the UI responds immediately.
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == notification.id ? n.copyWith(isRead: true) : n)
          .toList();
    });

    final remaining = await NotificationInboxService.instance.markRead(notification.id);
    if (remaining != null && mounted) _syncBadge(remaining);
  }

  Future<void> _handleTap(InboxNotification notification) async {
    await _markRead(notification);
    if (!mounted) return;

    final deepLink = notification.deepLink;
    if (deepLink.isEmpty) return;

    switch (deepLink) {
      case 'appointments':
        context.push('/myBookingPage');
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

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeleton();

    if (_hasError) {
      return AppErrorState(
        title: 'Could not load notifications',
        subtitle: 'Check your connection and try again',
        onRetry: _load,
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.accent,
        child: ListView(children: [
          const SizedBox(height: AppSpacing.space48),
          _buildEmpty(),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: AppSpacing.space16,
          endIndent: AppSpacing.space16,
        ),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return NotificationItem(
            key: ValueKey('notification_${notif.id}'),
            title: notif.title,
            body: notif.body,
            createdAt: notif.createdAt,
            isRead: notif.isRead,
            type: notif.type,
            deepLink: notif.deepLink,
            onTap: () => _handleTap(notif),
            onDismiss: () => _markRead(notif),
          );
        },
      ),
    );
  }
}
