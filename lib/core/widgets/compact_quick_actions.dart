import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class CompactQuickAction {
  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback? onTap;

  const CompactQuickAction({
    required this.icon,
    required this.label,
    required this.tint,
    this.onTap,
  });
}

class CompactQuickActions extends StatelessWidget {
  const CompactQuickActions({
    super.key,
    required this.actions,
    this.horizontalPadding = AppSpacing.space20,
    this.tileGap = AppSpacing.space12,
  });

  final List<CompactQuickAction> actions;
  final double horizontalPadding;
  final double tileGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            Expanded(child: _CompactTile(action: actions[i])),
            if (i < actions.length - 1) SizedBox(width: tileGap),
          ]
        ],
      ),
    );
  }
}

class _CompactTile extends StatefulWidget {
  const _CompactTile({required this.action});
  final CompactQuickAction action;

  @override
  State<_CompactTile> createState() => _CompactTileState();
}

class _CompactTileState extends State<_CompactTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.action.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space12,
            horizontal: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.action.tint.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.action.icon,
                  color: widget.action.tint,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
