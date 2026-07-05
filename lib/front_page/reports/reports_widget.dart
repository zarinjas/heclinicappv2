import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/index.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';
import '/component/alert_report/alert_report_widget.dart';
import '/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
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
    )..addListener(() {
          safeSetState(() {});
          if (_model.tabBarCurrentIndex == 1 && _model.vitalsData.isEmpty && !_model.isLoadingVitals) {
            _loadVitals();
          }
          if (_model.tabBarCurrentIndex == 2 && _model.documentsList.isEmpty && !_model.isLoadingDocuments) {
            _loadDocuments();
          }
        });

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

  String _inferUnit(String vitalName) {
    final lower = vitalName.toLowerCase();
    if (lower.contains('weight') || lower.contains('berat')) return 'kg';
    if (lower.contains('pressure') || lower.contains('blood')) return 'mmHg';
    if (lower.contains('glucose') || lower.contains('gula')) return 'mmol/L';
    if (lower.contains('heart') || lower.contains('pulse')) return 'bpm';
    if (lower.contains('temperature') || lower.contains('suhu')) return '°C';
    if (lower.contains('spo2') || lower.contains('oxygen') || lower.contains('saturation')) return '%';
    if (lower.contains('height') || lower.contains('tinggi')) return 'cm';
    if (lower.contains('bmi')) return 'kg/m²';
    if (lower.contains('cholesterol')) return 'mmol/L';
    return '';
  }

  Future<void> _loadVitals() async {
    _model.isLoadingVitals = true;
    _model.vitalsError = null;
    safeSetState(() {});

    try {
      final patientId = FFAppState().idplato;
      final response = await GetVitalsGraphingCall.call(patientId: patientId);

      if (!response.succeeded) {
        _model.vitalsError = 'Failed to load vitals data';
        _model.isLoadingVitals = false;
        safeSetState(() {});
        return;
      }

      final body = response.jsonBody;
      if (body is! Map<String, dynamic> || body.isEmpty) {
        _model.vitalsData = [];
        _model.isLoadingVitals = false;
        safeSetState(() {});
        return;
      }

      final vitals = <VitalType>[];

      for (final entry in body.entries) {
        final name = entry.key.toString();
        final rawData = entry.value;

        if (rawData is! List) continue;

        final dataPoints = <VitalDataPoint>[];

        for (final item in rawData) {
          if (item is! Map<String, dynamic>) continue;

          DateTime? timestamp;
          if (item['timestamp'] != null) {
            timestamp = DateTime.tryParse(item['timestamp'].toString());
          } else if (item['time'] != null) {
            timestamp = DateTime.tryParse(item['time'].toString());
          } else if (item['date'] != null) {
            timestamp = DateTime.tryParse(item['date'].toString());
          }

          double? value;
          if (item['value'] != null) {
            value = double.tryParse(item['value'].toString());
          }

          if (timestamp != null && value != null) {
            dataPoints.add(VitalDataPoint(timestamp: timestamp, value: value));
          }
        }

        if (dataPoints.isNotEmpty) {
          dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          vitals.add(VitalType(
            name: name,
            unit: _inferUnit(name),
            dataPoints: dataPoints,
          ));
        }
      }

      _model.vitalsData = vitals;
      _model.isLoadingVitals = false;
      safeSetState(() {});
    } catch (e) {
      _model.vitalsError = 'Failed to load vitals data';
      _model.isLoadingVitals = false;
      safeSetState(() {});
    }
  }

  Future<void> _loadDocuments() async {
    _model.isLoadingDocuments = true;
    _model.documentsError = null;
    safeSetState(() {});

    try {
      final patientId = FFAppState().idplato;
      final response = await GetPatientDocumentsCall.call(patientId: patientId);

      if (!response.succeeded) {
        _model.documentsError = 'Failed to load documents';
        _model.isLoadingDocuments = false;
        safeSetState(() {});
        return;
      }

      final body = response.jsonBody;
      final names = GetPatientDocumentsCall.names(body);
      final urls = GetPatientDocumentsCall.urls(body);
      final uploadedAts = GetPatientDocumentsCall.uploadedAt(body);
      final adminNotes = GetPatientDocumentsCall.adminNotes(body);
      final sizeBytes = GetPatientDocumentsCall.sizeBytes(body);

      final docs = <PatientDocument>[];
      if (names != null) {
        for (var i = 0; i < names.length; i++) {
          docs.add(PatientDocument(
            name: names[i],
            url: i < (urls?.length ?? 0) ? (urls?[i] ?? '') : '',
            uploadedAt: i < (uploadedAts?.length ?? 0) ? (uploadedAts?[i] ?? '') : '',
            adminNote: i < (adminNotes?.length ?? 0) ? adminNotes?[i] : null,
            sizeBytes: i < (sizeBytes?.length ?? 0) ? (sizeBytes?[i] ?? 0) : 0,
          ));
        }
      }

      _model.documentsList = docs;
      _model.isLoadingDocuments = false;
      safeSetState(() {});
    } catch (e) {
      _model.documentsError = 'Failed to load documents';
      _model.isLoadingDocuments = false;
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

  Widget _buildVitalChartCard(VitalType vital) {
    if (vital.dataPoints.isEmpty) return const SizedBox.shrink();

    final spots = vital.dataPoints.map((p) {
      return FlSpot(
        p.timestamp.millisecondsSinceEpoch.toDouble(),
        p.value,
      );
    }).toList();

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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vital.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (vital.unit.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  vital.unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: null,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.divider,
                          strokeWidth: 0.5,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(vital.unit == 'mmHg' || vital.unit == 'bpm' ? 0 : 1),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.0,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: spots.length > 1
                              ? (spots.last.x - spots.first.x) /
                                  (spots.length > 6 ? 6 : spots.length)
                              : 1,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            return Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xs),
                              child: Text(
                                '${months[date.month - 1]} ${date.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppColors.accent,
                        barWidth: 2.0,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    minX: spots.isNotEmpty ? spots.first.x : 0,
                    maxX: spots.isNotEmpty ? spots.last.x : 0,
                    lineTouchData: const LineTouchData(enabled: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsTab() {
    if (_model.isLoadingVitals) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 2,
        itemBuilder: (_, __) => const SkeletonCard(height: 200),
      );
    }

    if (_model.vitalsError != null) {
      return Center(
        child: ErrorStateWidget(
          message: _model.vitalsError!,
          onRetry: _loadVitals,
        ),
      );
    }

    if (_model.vitalsData.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.monitor_heart_outlined,
        title: 'No vitals recorded',
        subtitle: 'Your health trends will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _model.vitalsData.length,
      itemBuilder: (_, index) =>
          _buildVitalChartCard(_model.vitalsData[index]),
    );
  }

  Widget _buildDocumentCard(PatientDocument doc) {
    final dateFormatted = doc.uploadedAt.length >= 10
        ? doc.uploadedAt.substring(0, 10)
        : doc.uploadedAt;

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
          onTap: () => _onDocumentTap(doc),
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
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
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
                        doc.name,
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
                          'Uploaded $dateFormatted',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (doc.adminNote != null && doc.adminNote!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          doc.adminNote!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  void _onDocumentTap(PatientDocument doc) {
    if (doc.url.isEmpty) return;
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
                  Expanded(
                    child: Text(
                      doc.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
                initialContent: doc.url,
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

  Widget _buildDocumentsTab() {
    if (_model.isLoadingDocuments) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        itemBuilder: (_, __) => const SkeletonListTile(),
      );
    }

    if (_model.documentsError != null) {
      return Center(
        child: ErrorStateWidget(
          message: _model.documentsError!,
          onRetry: _loadDocuments,
        ),
      );
    }

    if (_model.documentsList.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_outlined,
        title: 'No documents yet',
        subtitle: 'Your health records will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _model.documentsList.length,
      itemBuilder: (_, index) =>
          _buildDocumentCard(_model.documentsList[index]),
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
                  _buildVitalsTab(),
                  _buildDocumentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
