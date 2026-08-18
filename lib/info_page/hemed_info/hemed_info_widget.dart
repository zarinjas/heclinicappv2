import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '/core/services/clinic_info_service.dart';
import '/core/services/models/clinic_info.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/app_app_bar.dart';
import '/core/widgets/app_empty_state.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';

class HemedInfoWidget extends StatefulWidget {
  const HemedInfoWidget({super.key});

  static String routeName = 'hemedInfo';
  static String routePath = '/hemedInfo';

  @override
  State<HemedInfoWidget> createState() => _HemedInfoWidgetState();
}

class _HemedInfoWidgetState extends State<HemedInfoWidget> {
  List<ClinicInfo> _items = ClinicInfo.fallbackList;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await ClinicInfoService.instance.init();
      if (mounted) setState(() {
        _items = ClinicInfoService.instance.items;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() { _loaded = true; _failed = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'He Clinic Info'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ClinicInfoService.instance.refresh();
            if (mounted) setState(() {
              _items = ClinicInfoService.instance.items;
              _failed = _items.isEmpty;
            });
          },
          child: _buildBody(isDark),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_failed || _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          AppEmptyState(
            icon: Icons.info_outline_rounded,
            title: 'Nothing here yet',
            subtitle:
                'Clinic info images will appear here once published.',
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.space16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.space12,
        mainAxisSpacing: AppSpacing.space12,
        childAspectRatio: 0.8,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _InfoTile(imageUrl: item.imageUrl, isDark: isDark);
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final placeholderBg = isDark ? AppColors.surfaceDark : AppColors.surface;

    return GestureDetector(
      onTap: imageUrl.isEmpty
          ? null
          : () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: FlutterFlowExpandedImageView(
                    image: Image.network(imageUrl, fit: BoxFit.contain),
                    allowRotation: false,
                    tag: imageUrl,
                    useHeroAnimation: true,
                  ),
                ),
              ),
      child: Hero(
        tag: imageUrl.isEmpty ? UniqueKey().toString() : imageUrl,
        transitionOnUserGestures: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          child: Container(
            color: placeholderBg,
            child: imageUrl.isEmpty
                ? const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.textSecondary),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
