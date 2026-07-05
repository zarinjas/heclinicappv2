import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isRead;
  final String type;
  final String deepLink;
  final DocumentReference? reference;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationItem({
    super.key,
    required this.title,
    required this.body,
    this.createdAt,
    required this.isRead,
    this.type = '',
    this.deepLink = '',
    this.reference,
    this.onTap,
    this.onDismiss,
  });

  IconData _iconForType() {
    switch (type) {
      case 'appointment_confirmed':
      case 'appointment':
        return Icons.calendar_today;
      case 'new_document':
        return Icons.description;
      case 'reminder':
        return Icons.alarm;
      case 'general':
        return Icons.campaign;
      default:
        return Icons.notifications_none;
    }
  }

  String _formatTimestamp() {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final bodyColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final timestampColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final unreadBg = isRead
        ? Colors.transparent
        : (isDark
            ? AppColors.accent.withOpacity(0.10)
            : AppColors.accent.withOpacity(0.05));

    return Dismissible(
      key: Key('notification_${reference?.id ?? title.hashCode}'),
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.space16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDismiss?.call();
        return true;
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: unreadBg,
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  children: [
                    Icon(
                      _iconForType(),
                      size: 24,
                      color: isRead ? bodyColor : AppColors.accent,
                    ),
                    if (!isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(color: titleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        body,
                        style: AppTextStyles.body2.copyWith(color: bodyColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                _formatTimestamp(),
                style: AppTextStyles.caption.copyWith(color: timestampColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
