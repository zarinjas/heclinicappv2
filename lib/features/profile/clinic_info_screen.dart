import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';
import '../../core/services/branch_service.dart';
import '../../core/services/models/branch.dart';
import '../../core/widgets/app_app_bar.dart';

class ClinicInfoScreen extends StatefulWidget {
  const ClinicInfoScreen({super.key});

  @override
  State<ClinicInfoScreen> createState() => _ClinicInfoScreenState();
}

class _ClinicInfoScreenState extends State<ClinicInfoScreen> {
  List<Branch> _branches = Branch.fallbackList;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await BranchService.instance.init();
    if (mounted) setState(() => _branches = BranchService.instance.branches);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: '${BrandingService.instance.appShortName} Info'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About ${BrandingService.instance.appName}', style: AppTextStyles.heading2.copyWith(color: tc)),
                  const SizedBox(height: 8),
                  Text(
                    'Founded in 2015, ${BrandingService.instance.appName} has grown from a single practice in Taman Tun Dr Ismail into a trusted healthcare provider across the Klang Valley.',
                    style: AppTextStyles.body1.copyWith(color: tc)),
                  const SizedBox(height: 24),
                  Text('Our Branches', style: AppTextStyles.heading2.copyWith(color: tc)),
                  const SizedBox(height: 8),
                  ..._branches.map((b) => GestureDetector(
                    onTap: () => context.pushNamed('/branch-detail', queryParameters: {'branchName': b.name}),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
                        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
                        color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Container(width: 4, height: 72,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.accent, AppColors.accentBlue]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Clinic', style: AppTextStyles.caption.copyWith(color: sc)),
                            const SizedBox(height: 4),
                            Text(b.name, style: AppTextStyles.heading3.copyWith(color: tc)),
                            const SizedBox(height: 2),
                            Text(b.address, style: AppTextStyles.body2.copyWith(color: sc)),
                          ])),
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Text('Operating Hours', style: AppTextStyles.heading2.copyWith(color: tc)),
                  const SizedBox(height: 8),
                  _hourLine('Monday - Friday: 8:00 AM - 8:00 PM', tc),
                  _hourLine('Saturday: 8:00 AM - 4:00 PM', tc),
                  _hourLine('Sunday & Public Holidays: Closed', tc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hourLine(String text, Color tc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTextStyles.body1.copyWith(color: tc)),
    );
  }
}
