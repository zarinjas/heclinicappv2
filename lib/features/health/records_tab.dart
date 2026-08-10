import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/health_record_card.dart';
import 'health_record.dart';
import 'record_detail_screen.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  bool _isLoading = true;
  bool _hasError = false;
  String _activeFilter = 'All';
  List<HealthRecord> _records = const [];

  static const _filters = ['All', 'Notes', 'Letters', 'MC'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final patientId = FFAppState().idplato;

    if (patientId.isEmpty) {
      setState(() {
        _records = const [];
        _isLoading = false;
      });
      return;
    }

    try {
      final records = <HealthRecord>[];
      final wantAll = _activeFilter == 'All';

      // Only fetch what the active filter needs.
      if (wantAll || _activeFilter == 'Notes') {
        records.addAll(await _loadNotes(patientId));
      }
      if (wantAll || _activeFilter == 'Letters') {
        records.addAll(await _loadLetters(patientId));
      }
      if (wantAll || _activeFilter == 'MC') {
        records.addAll(await _loadMedicalCertificate());
      }

      // Newest first.
      records.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<List<HealthRecord>> _loadNotes(String patientId) async {
    final response = await GetReportCall.call(patientId: patientId, forceRefresh: true);
    if (!response.succeeded) return const [];

    final body = response.jsonBody;
    final notes = GetReportCall.note(body);
    if (notes == null) return const [];

    final times = GetReportCall.time(body);
    final categories = GetReportCall.kategori(body);
    final authors = GetReportCall.author(body);
    final diagnoses = GetReportCall.diagnosis(body);

    return [
      for (var i = 0; i < notes.length; i++)
        HealthRecord(
          type: HealthRecordType.note,
          // The card shows one line, so keep the title short.
          title: notes[i].length > 80 ? '${notes[i].substring(0, 80)}...' : notes[i],
          date: _at(times, i) ?? '',
          author: _at(authors, i) ?? '',
          detailData: notes[i],
          category: _at(categories, i),
          diagnosis: _diagnosisAt(diagnoses, i),
        ),
    ];
  }

  Future<List<HealthRecord>> _loadLetters(String patientId) async {
    final response = await LetterCall.call(patientId: patientId);
    if (!response.succeeded) return const [];

    final body = response.jsonBody;
    final subjects = LetterCall.subject(body);
    if (subjects == null) return const [];

    final htmls = LetterCall.html(body);
    final dates = LetterCall.tgl(body);
    final authors = LetterCall.author(body);

    return [
      for (var i = 0; i < subjects.length; i++)
        HealthRecord(
          type: HealthRecordType.letter,
          title: subjects[i],
          date: _at(dates, i) ?? '',
          author: _at(authors, i) ?? '',
          detailData: _at(htmls, i),
        ),
    ];
  }

  Future<List<HealthRecord>> _loadMedicalCertificate() async {
    final response = await MedicalAppsApiGroup.getMedicalCertificateCall.call(
      auth: 'Bearer ${FFAppState().tokenauth}',
    );
    if (!response.succeeded) return const [];

    final call = MedicalAppsApiGroup.getMedicalCertificateCall;
    final path = call.path(response.jsonBody);
    if (path == null || path.isEmpty) return const [];

    return [
      HealthRecord(
        type: HealthRecordType.mc,
        title: path.split('/').last,
        date: call.tgl(response.jsonBody) ?? '',
        author: '',
        detailData: path,
      ),
    ];
  }

  static T? _at<T>(List<T>? list, int i) =>
      list != null && i < list.length ? list[i] : null;

  static List<String>? _diagnosisAt(List<dynamic>? list, int i) {
    final value = _at(list, i);
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }

  void _openDetail(HealthRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterRow(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeleton();

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load records',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadRecords,
      );
    }

    if (_records.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRecords,
        color: AppColors.accent,
        child: ListView(
          children: const [
            SizedBox(height: AppSpacing.space48),
            AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No records found',
              subtitle: 'Your clinical notes will appear here',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      color: AppColors.accent,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _records.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, i) {
          final record = _records[i];
          return HealthRecordCard(
            recordType: record.type,
            title: record.title,
            doctorName: record.author.isNotEmpty ? record.author : record.typeLabel,
            date: record.date,
            onTap: () => _openDetail(record),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) => AppSkeleton.listItem(),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space8),
              child: AppChip(
                label: filter,
                type: AppChipType.filter,
                isSelected: _activeFilter == filter,
                onTap: () {
                  if (_activeFilter != filter) {
                    setState(() => _activeFilter = filter);
                    // Re-fetch so the filter actually changes the results.
                    _loadRecords();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
