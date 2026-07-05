import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/components/skeleton_loaders.dart';
import '/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'reports_model.dart';
export 'reports_model.dart';

class ReportsWidget extends StatefulWidget {
  const ReportsWidget({
    super.key,
    required this.id,
  });

  final String? id;

  static String routeName = 'Reports';
  static String routePath = '/reports';

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget>
    with TickerProviderStateMixin {
  late ReportsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportsModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Text(
          'My Health',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TabBar(
              isScrollable: false,
              labelColor: AppColors.textInverse,
              unselectedLabelColor: AppColors.textInverse.withValues(alpha: 0.6),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: AppColors.accent,
              indicatorWeight: 3.0,
              controller: _model.tabBarController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.article_outlined, size: 22.0),
                  text: 'Records',
                ),
                Tab(
                  icon: Icon(Icons.monitor_heart_outlined, size: 22.0),
                  text: 'Vitals',
                ),
                Tab(
                  icon: Icon(Icons.folder_outlined, size: 22.0),
                  text: 'Documents',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _model.tabBarController,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(3, (_) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SkeletonListTile(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
