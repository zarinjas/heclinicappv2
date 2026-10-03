import 'package:flutter/material.dart';
import '/core/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/services/notification_inbox_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
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

  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

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

  List<_NotificationGroup> _grouped() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <InboxNotification>[];
    final yesterdayItems = <InboxNotification>[];
    final earlierItems = <InboxNotification>[];

    for (final notification in _notifications) {
      final created = notification.createdAt;
      if (created == null) {
        earlierItems.add(notification);
        continue;
      }
      final day = DateTime(created.year, created.month, created.day);
      if (day == today) {
        todayItems.add(notification);
      } else if (day == yesterday) {
        yesterdayItems.add(notification);
      } else {
        earlierItems.add(notification);
      }
    }

    return [
      _NotificationGroup('Today', todayItems),
      _NotificationGroup('Yesterday', yesterdayItems),
      _NotificationGroup('Earlier', earlierItems),
    ];
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space32,
      ),
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: AppSkeleton.listItem(),
        ),
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

  Widget _buildSummaryCard() {
    final unread = _unreadCount;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space20),
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        boxShadow: AppShadows.shadowMid,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unread new notification${unread == 1 ? '' : 's'}',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stay up to date with your clinic updates',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space4,
        top: AppSpacing.space4,
        bottom: AppSpacing.space8,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    final Widget? trailing;
    if (_markingAllRead) {
      trailing = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    } else if (_unreadCount > 0) {
      trailing = GestureDetector(
        onTap: _markAllRead,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.done_all_rounded,
              size: 16,
              color: AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              'Mark all read',
              style: AppTextStyles.label.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      trailing = null;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Notifications',
        trailing: trailing,
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

    final children = <Widget>[];
    if (_unreadCount > 0) children.add(_buildSummaryCard());

    for (final group in _grouped()) {
      if (group.notifications.isEmpty) continue;
      children.add(_buildSectionLabel(group.label));
      for (final notif in group.notifications) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: NotificationItem(
            id: notif.id,
            title: notif.title,
            body: notif.body,
            createdAt: notif.createdAt,
            isRead: notif.isRead,
            type: notif.type,
            deepLink: notif.deepLink,
            imageUrl: notif.imageUrl,
            onTap: () => _handleTap(notif),
            onDismiss: () => _markRead(notif),
          ),
        ));
      }
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space12,
          AppSpacing.space16,
          AppSpacing.space32,
        ),
        children: children,
      ),
    );
  }
}

class _NotificationGroup {
  const _NotificationGroup(this.label, this.notifications);

  final String label;
  final List<InboxNotification> notifications;
}
