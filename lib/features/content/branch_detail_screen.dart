import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/branch_service.dart';
import '../../core/services/models/branch.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_loader.dart';

class BranchDetailScreen extends StatefulWidget {
  final String? branchName;
  const BranchDetailScreen({super.key, this.branchName});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  Branch? _branch;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await BranchService.instance.init();
    if (!mounted) return;

    final branches = BranchService.instance.branches;
    if (widget.branchName != null) {
      _branch = branches.cast<Branch?>().firstWhere(
            (branch) => branch?.name == widget.branchName,
            orElse: () => null,
          );
    }
    _branch ??= branches.isNotEmpty ? branches.first : null;
    setState(() {});
  }

  Future<void> _openDirections() async {
    final branch = _branch!;
    final mapUrl = branch.googleMapsLink?.trim();
    final url = mapUrl != null && mapUrl.isNotEmpty
        ? mapUrl
        : 'https://maps.google.com/?q=${Uri.encodeComponent('${branch.name} ${branch.address}')}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp() async {
    final number = (_branch!.whatsappNumber ?? _branch!.phone ?? '60136254528')
        .replaceAll(RegExp(r'[^0-9]'), '');
    await launchUrl(
      Uri.parse('https://wa.me/$number'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppAppBar.sub(title: _branch?.name ?? 'Our Clinic'),
      body: _branch == null
          ? const Center(child: AppLoader())
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BranchHero(branch: _branch!),
                    const SizedBox(height: 24),
                    Text(
                      'Visit our clinic',
                      style: AppTextStyles.heading2.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Everything you need to find and contact ${_branch!.name}.',
                      style: AppTextStyles.body1.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Clinic address',
                      value: _branch!.address.isNotEmpty
                          ? _branch!.address
                          : 'Address will be updated soon.',
                    ),
                    if (_branch!.phone != null &&
                        _branch!.phone!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: _branch!.phone!,
                      ),
                    ],
                    if (_branch!.operatingHours != null &&
                        _branch!.operatingHours!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _HoursCard(hours: _branch!.operatingHours!),
                    ],
                    const SizedBox(height: 24),
                    _ActionButton(
                      icon: Icons.directions_outlined,
                      label: 'Get directions',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: _openDirections,
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Contact via WhatsApp',
                      backgroundColor: AppColors.whatsappGreen,
                      foregroundColor: Colors.white,
                      onPressed: _openWhatsApp,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BranchHero extends StatelessWidget {
  const _BranchHero({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final hasImage = branch.imageUrl != null && branch.imageUrl!.isNotEmpty;
    return Container(
      height: 228,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              branch.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _HeroFallback(branch: branch),
            )
          else
            _HeroFallback(branch: branch),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xC9131C3C)],
                stops: [0.36, 1],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Text(
              branch.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: branch.leadingGradient,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital_outlined,
        size: 64,
        color: Colors.white,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.hours});

  final Map<String, String> hours;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_outlined, color: AppColors.accent),
              const SizedBox(width: 10),
              Text('Operating hours',
                  style: AppTextStyles.heading3.copyWith(color: primary)),
            ],
          ),
          const SizedBox(height: 14),
          ...hours.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key,
                        style: AppTextStyles.body2.copyWith(color: secondary)),
                  ),
                  Text(
                    entry.value,
                    style: AppTextStyles.body2.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }
}
