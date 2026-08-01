import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branch_service.dart';
import '../../core/services/models/branch.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
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
    if (mounted) {
      final branches = BranchService.instance.branches;
      if (widget.branchName != null) {
        _branch = branches.cast<Branch?>().firstWhere(
          (b) => b?.name == widget.branchName, orElse: () => null,
        );
      }
      _branch ??= branches.isNotEmpty ? branches.first : null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final sec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: _branch?.name ?? 'Branch'),
      body: _branch == null
          ? const Center(child: AppLoader())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _branch!.leadingGradient,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _branch!.name,
                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address', style: AppTextStyles.label.copyWith(color: sec)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _branch!.address,
                                style: AppTextStyles.body1.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        if (_branch!.phone != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 20, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text(_branch!.phone!, style: AppTextStyles.body1),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        AppButton.secondary(
                          label: 'Get Directions',
                          onPressed: () async {
                            final url = 'https://maps.google.com/?q=${Uri.encodeComponent(_branch!.name + ' ' + _branch!.address)}';
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        AppButton.whatsApp(
                          label: 'Contact via WhatsApp',
                          onPressed: () async {
                            final wa = _branch!.phone ?? '60136254528';
                            final uri = Uri.parse('https://wa.me/$wa');
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
