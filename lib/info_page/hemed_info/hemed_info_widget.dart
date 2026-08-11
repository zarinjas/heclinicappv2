import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '/backend/backend.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'He Clinic Info'),
      body: SafeArea(
        child: StreamBuilder<List<InfoRecord>>(
          stream: queryInfoRecord(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data!;
            if (records.isEmpty) {
              return const AppEmptyState(
                icon: Icons.info_outline_rounded,
                title: 'Nothing here yet',
                subtitle:
                    'Clinic information will appear here once published.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.space16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.space12,
                mainAxisSpacing: AppSpacing.space12,
                childAspectRatio: 0.8,
              ),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _InfoTile(imageUrl: record.img, isDark: isDark);
              },
            );
          },
        ),
      ),
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
                ? Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.textSecondary),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: Text(
                          '',
                          style: AppTextStyles.caption,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
