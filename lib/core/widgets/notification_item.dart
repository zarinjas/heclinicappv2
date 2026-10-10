import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/html_text.dart';

class NotificationItem extends StatelessWidget {
  final int? id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isRead;
  final String type;
  final String deepLink;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationItem({
    super.key,
    this.id,
    required this.title,
    required this.body,
    this.createdAt,
    required this.isRead,
    this.type = '',
    this.deepLink = '',
    this.imageUrl,
    this.onTap,
    this.onDismiss,
  });

  IconData _iconForType() {
    switch (type) {
      case 'appointment_confirmed':
      case 'appointment':
        return Icons.event_available_rounded;
      case 'new_document':
        return Icons.description_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'general':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType() {
    switch (type) {
      case 'appointment_confirmed':
      case 'appointment':
        return AppColors.accent;
      case 'new_document':
        return const Color(0xFF10B981);
      case 'reminder':
        return AppColors.warning;
      case 'general':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.accent;
    }
  }

  String _formatTimestamp() {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';

    final createdDay =
        DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (createdDay == today) return '${diff.inHours}h ago';
    if (createdDay == yesterday) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(createdAt!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Titles/bodies are authored in the CMS and may contain HTML fragments.
    final safeTitle = stripHtmlToSingleLine(title);
    final safeBody = stripHtmlToSingleLine(body);
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final bodyColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final divider = isDark ? AppColors.dividerDark : AppColors.divider;
    final accent = _colorForType();

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        child: Ink(
          decoration: BoxDecoration(
            color: isRead
                ? surface
                : accent.withOpacity(isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            border: Border.all(
              color: isRead ? divider : accent.withOpacity(0.35),
            ),
            boxShadow: AppShadows.shadowLow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconBadge(context, accent, isRead, surface),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    safeTitle,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: titleColor,
                                      fontWeight:
                                          isRead ? FontWeight.w600 : FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space8),
                                Text(
                                  _formatTimestamp(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: isRead
                                        ? bodyColor
                                        : accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (safeBody.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                safeBody,
                                style:
                                    AppTextStyles.body1.copyWith(color: bodyColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.space12),
                              _buildImage(divider),
                            ],
                            if (deepLink.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.space12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View details',
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: AppSpacing.space4,
                      color: accent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key('dismiss_notification_${id ?? title.hashCode}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.space20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDismiss?.call();
        return false;
      },
      child: card,
    );
  }

  Widget _buildIconBadge(
    BuildContext context,
    Color accent,
    bool isRead,
    Color surface,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withOpacity(isRead ? 0.10 : 0.16),
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
          ),
          child: Icon(
            _iconForType(),
            size: 22,
            color: accent,
          ),
        ),
        if (!isRead)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(Color placeholder) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radiusMD),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 160),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(color: placeholder);
            },
          ),
        ),
      ),
    );
  }
}
