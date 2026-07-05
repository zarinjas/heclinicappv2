import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/skeleton_loaders.dart';
import '/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_package_model.dart';
export 'service_package_model.dart';

class ServicePackageWidget extends StatefulWidget {
  const ServicePackageWidget({super.key});

  static String routeName = 'servicePackage';
  static String routePath = '/servicePackage';

  @override
  State<ServicePackageWidget> createState() => _ServicePackageWidgetState();
}

class _ServicePackageWidgetState extends State<ServicePackageWidget> {
  late ServicePackageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServicePackageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _model.loadPackages();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          title: Text(
            'Services & Packages',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: FlutterFlowTheme.of(context).alternate,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 3.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0.0),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return _buildSkeleton();
    }

    if (_model.hasError) {
      return _buildError();
    }

    if (_model.packages.isEmpty) {
      return _buildEmpty();
    }

    return _buildPackageList();
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCard(height: 200),
          const SizedBox(height: AppSpacing.md),
          const SkeletonTextBlock(lineCount: 2),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64.0,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _model.errorMessage,
              style: const TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _model.loadPackages(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64.0,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No packages available yet',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: _model.packages.map((package) {
          final name = package['name'] as String? ?? '';
          final description = package['description'] as String? ?? '';
          final image = package['image'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Card(
              elevation: 2.0,
              shadowColor: AppShadows.low.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 300),
                        fadeOutDuration: const Duration(milliseconds: 300),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 48.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
