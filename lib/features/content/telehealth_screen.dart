import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/telehealth_service.dart';
import '../../core/services/models/telehealth_config.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';

class TelehealthScreen extends StatefulWidget {
  const TelehealthScreen({super.key});

  @override
  State<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends State<TelehealthScreen> {
  TelehealthConfig _config = TelehealthConfig.fallback;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await TelehealthService.instance.init();
    if (mounted) setState(() { _config = TelehealthService.instance.config; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Telehealth', onBack: () {}),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF27F5A3), Color(0xFF3B8DFF)]),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(_config.title, style: AppTextStyles.heading2.copyWith(color: tc), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(_config.description, style: AppTextStyles.body1.copyWith(color: sc, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
              ),
              child: Column(
                children: _config.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: AppTextStyles.body1.copyWith(color: tc))),
                  ]),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
            AppButton.whatsApp(
              label: _config.buttonLabel, isFullWidth: true,
              onPressed: () async {
                final uri = Uri.parse('https://wa.me/${_config.whatsappNumber}?text=Hello%20He%20Clinic');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(height: 12),
            Text('Tap the button above to connect with our medical team via WhatsApp.',
              style: AppTextStyles.body2.copyWith(color: sc), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
