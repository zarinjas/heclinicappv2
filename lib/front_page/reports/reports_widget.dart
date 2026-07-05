import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/index.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/component/alert_report/alert_report_widget.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadRecords();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    _model.isLoading = true;
    _model.errorMessage = null;
    safeSetState(() {});

    try {
      final patientId = FFAppState().idplato;
      final records = <HealthRecord>[];

      final needNotes =
          _model.selectedFilter == FilterType.all ||
          _model.selectedFilter == FilterType.notes;
      final needLetters =
          _model.selectedFilter == FilterType.all ||
          _model.selectedFilter == FilterType.letters;
      final needMc =
          _model.selectedFilter == FilterType.all ||
          _model.selectedFilter == FilterType.mc;

      if (needNotes) {
        final notesResponse = await GetReportCall.call(patientId: patientId);
        if (notesResponse.succeeded) {
          final body = notesResponse.jsonBody;
          final notes = GetReportCall.note(body);
          final times = GetReportCall.time(body);
          final kategoris = GetReportCall.kategori(body);
          final authors = GetReportCall.author(body);
          final diagnosisList = GetReportCall.diagnosis(body);
          if (notes != null) {
            for (var i = 0; i < notes.length; i++) {
              records.add(HealthRecord(
                type: RecordType.note,
                title: (notes[i].length > 80)
                    ? '${notes[i].substring(0, 80)}...'
                    : notes[i],
                date: i < (times?.length ?? 0) ? (times?[i] ?? '') : '',
                author: i < (authors?.length ?? 0) ? (authors?[i] ?? '') : '',
                detailData: notes[i],
                kategori: i < (kategoris?.length ?? 0) ? kategoris?[i] : null,
                diagnosis: i < (diagnosisList?.length ?? 0)
                    ? (diagnosisList?[i] is List ? List<String>.from(diagnosisList![i]) : null)
                    : null,
              ));
            }
          }
        }
      }

      if (needLetters) {
        final lettersResponse = await LetterCall.call(patientId: patientId);
        if (lettersResponse.succeeded) {
          final body = lettersResponse.jsonBody;
          final subjects = LetterCall.subject(body);
          final htmls = LetterCall.html(body);
          final tgLs = LetterCall.tgl(body);
          final authors = LetterCall.author(body);
          if (subjects != null) {
            for (var i = 0; i < subjects.length; i++) {
              records.add(HealthRecord(
                type: RecordType.letter,
                title: subjects[i],
                date: i < (tgLs?.length ?? 0) ? (tgLs?[i] ?? '') : '',
                author: i < (authors?.length ?? 0) ? (authors?[i] ?? '') : '',
                detailData: i < (htmls?.length ?? 0) ? htmls?[i] : null,
              ));
            }
          }
        }
      }

      if (needMc) {
        final mcResponse =
            await MedicalAppsApiGroup.getMedicalCertificateCall.call(
          auth: 'Bearer ${FFAppState().tokenauth}',
        );
        if (mcResponse.succeeded) {
          final mcData = MedicalAppsApiGroup.getMedicalCertificateCall;
          final pathStr = mcData.path(mcResponse.jsonBody);
          final tglStr = mcData.tgl(mcResponse.jsonBody);
          if (pathStr != null && pathStr.isNotEmpty) {
            records.add(HealthRecord(
              type: RecordType.mc,
              title: pathStr.split('/').last,
              date: tglStr ?? '',
              author: '',
              detailData: pathStr,
            ));
          }
        }
      }

      records.sort((a, b) => b.date.compareTo(a.date));

      _model.recordsList = records;
      _model.isLoading = false;
      safeSetState(() {});
    } catch (e) {
      _model.errorMessage = 'Failed to load records';
      _model.isLoading = false;
      safeSetState(() {});
    }
  }

  void _onFilterChanged(FilterType filter) {
    if (_model.selectedFilter == filter) return;
    _model.selectedFilter = filter;
    safeSetState(() {});
    _loadRecords();
  }

  void _onRecordTap(HealthRecord record) {
    switch (record.type) {
      case RecordType.note:
        if (record.detailData != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AlertReportWidget(
                    author: record.author,
                    time: record.date,
                    note: record.detailData!,
                    kategori: record.kategori,
                    diagnosis: record.diagnosis,
                  ),
                ),
              ),
            ),
          );
        }
        break;
      case RecordType.letter:
        if (record.detailData != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        record.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: FlutterFlowWebView(
                          content: record.detailData!,
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          verticalScroll: true,
                          horizontalScroll: false,
                          html: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        break;
      case RecordType.mc:
        if (record.detailData != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              height: MediaQuery.sizeOf(context).height * 0.9,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: WebViewXPlus(
                      initialContent: record.detailData!,
                      initialSourceType: SourceType.url,
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        break;
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: FilterType.values.map((filter) {
          final isSelected = _model.selectedFilter == filter;
          final label = switch (filter) {
            FilterType.all => 'All',
            FilterType.notes => 'Notes',
            FilterType.letters => 'Letters',
            FilterType.mc => 'MC',
          };
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(filter),
              selectedColor: AppColors.accent,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    final iconData = switch (record.type) {
      RecordType.note => Icons.description,
      RecordType.letter => Icons.mail_outline,
      RecordType.mc => Icons.assignment_outlined,
    };

    final dateFormatted = record.date.isNotEmpty
        ? record.date.length >= 10
            ? record.date.substring(0, 10)
            : record.date
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        color: AppColors.surface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        child: InkWell(
          onTap: () => _onRecordTap(record),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    iconData,
                    size: 20,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (dateFormatted.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          dateFormatted,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (record.author.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          record.author,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
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
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    if (_model.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        itemBuilder: (_, __) => const SkeletonListTile(),
      );
    }

    if (_model.errorMessage != null) {
      return Center(
        child: ErrorStateWidget(
          message: _model.errorMessage!,
          onRetry: _loadRecords,
        ),
      );
    }

    if (_model.recordsList.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'No records found',
        subtitle: 'Your clinical notes will appear here',
      );
    }

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _model.recordsList.length,
            itemBuilder: (_, index) =>
                _buildRecordCard(_model.recordsList[index]),
          ),
        ),
      ],
    );
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
                children: [
                  _buildRecordsTab(),
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SkeletonListTile(),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SkeletonListTile(),
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
