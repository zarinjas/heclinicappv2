import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/legal_service.dart';
import '../../core/services/models/legal_page.dart';
import '../../core/widgets/app_app_bar.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  LegalPage _page = LegalPage.privacyFallback;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await LegalService.instance.init();
    if (mounted) setState(() { _page = LegalService.instance.privacy; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: _page.title, onBack: () {}),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_page.title, style: AppTextStyles.heading2.copyWith(color: tc)),
          const SizedBox(height: 8),
          Text('Last updated: ${_page.lastUpdated}', style: AppTextStyles.body2.copyWith(color: sc)),
          const SizedBox(height: 16),
          ..._page.sections.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.heading, style: AppTextStyles.heading3.copyWith(color: tc)),
              const SizedBox(height: 4),
              Text(s.body, style: AppTextStyles.body1.copyWith(color: tc, height: 1.6)),
            ]),
          )),
        ]),
      ),
    );
  }
}
