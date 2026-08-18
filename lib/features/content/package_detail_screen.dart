import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/services/models/service_package.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../utils/whatsapp_helper.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key, required this.package});

  static const String routeName = '/packageDetail';

  final ServicePackage package;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  ServicePackage get package => widget.package;

  List<String> get _images => package.galleryImages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp({required String message}) async {
    final deepLink = WhatsAppHelper.buildDeepLink(
      phoneNumber: package.whatsapp,
      message: message,
    );
    await launchURL(deepLink);
  }

  Future<void> _askQuestion() async {
    await _openWhatsApp(
      message: 'Hi He Clinic!\n\n'
          'I\'m interested in the "${package.name}" package.\n'
          '${package.description.isEmpty ? '' : '\n${package.description}\n'}'
          '\nCould you share the price and more details? Thank you!',
    );
  }

  Future<void> _bookAppointment() async {
    await _openWhatsApp(
      message: 'Hi He Clinic!\n\n'
          'I would like to enquire about the "${package.name}" package.\n'
          '\nCould you share the price and availability, and how I can proceed? Thank you!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: 'Package Details'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGallery(isDark),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: AppTextStyles.heading2.copyWith(
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        if (package.description.isNotEmpty) ...[
                          Text(
                            package.description,
                            style: AppTextStyles.body1.copyWith(
                              color: titleColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space16),
                        ],
                        Text(
                          'Includes:',
                          style: AppTextStyles.label.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        if (package.items.isNotEmpty)
                          ..._buildItems()
                        else
                          Text(
                            'Contact us for more details about this package.',
                            style: AppTextStyles.body1.copyWith(
                              color: titleColor,
                              height: 1.5,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.space16),
                        Text(
                          'Price available on request. Contact us for pricing and availability.',
                          style: AppTextStyles.caption.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionBar(),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return [
      for (final item in package.items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyles.body1.copyWith(
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildGallery(bool isDark) {
    if (_images.isEmpty) {
      return Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: package.placeholderGradient,
          ),
        ),
        child: Center(
          child: Text(
            package.name,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) =>
                setState(() => _currentPage = index),
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: _images[index],
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 300),
              errorWidget: (context, url, error) => Container(
                color: isDark ? AppColors.surfaceDark : AppColors.divider,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              placeholder: (context, url) => Container(
                color: isDark ? AppColors.surfaceDark : AppColors.divider,
              ),
            ),
          ),
        ),
        if (_images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.accent
                        : (isDark
                            ? AppColors.dividerDark
                            : AppColors.divider),
                    borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.dividerDark
                : AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              label: 'Ask',
              icon: const Icon(Icons.chat_outlined, size: 20),
              onPressed: _askQuestion,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: AppButton.whatsApp(
              label: 'Book Appointment',
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              onPressed: _bookAppointment,
            ),
          ),
        ],
      ),
    );
  }
}
