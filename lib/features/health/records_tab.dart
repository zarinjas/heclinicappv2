import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/services/seen_store.dart';
import '../../core/utils/api_url.dart';
import '../../core/utils/html_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/health_record_card.dart';
import '../../env_config.dart';
import 'health_cache.dart';
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
  bool _fromCache = false;
  List<HealthRecord> _all = const [];
  Set<String> _seen = const {};
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  static const _seenCategory = 'records';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    final patientId = FFAppState().idplato;

    if (patientId.isEmpty) {
      setState(() {
        _all = const [];
        _isLoading = false;
        _hasError = false;
        _fromCache = false;
      });
      return;
    }

    // Show cached records immediately so the list survives offline, rate
    // limits and transient API failures.
    final cached = await HealthCache.readRecords(patientId);
    if (!mounted) return;
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _all = cached;
        _isLoading = false;
        _fromCache = true;
      });

      if (await HealthCache.recordsAreFresh(patientId)) {
        final seen = await SeenStore.ensureInitialized(
          _seenCategory,
          cached.map(_recordKey),
        );
        if (mounted) {
          setState(() {
            _seen = seen;
            _fromCache = false;
          });
        }
        return;
      }
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    // Refresh from Plato in the background.
    try {
      final records = await _loadHealthRecords(patientId);
      if (!mounted) return;

      if (records != null) {
        records.sort((a, b) => _sortKey(b).compareTo(_sortKey(a)));
        setState(() {
          _all = records;
          _isLoading = false;
          _hasError = false;
          _fromCache = false;
        });
        final seen = await SeenStore.ensureInitialized(
          _seenCategory,
          records.map(_recordKey),
        );
        if (mounted) setState(() => _seen = seen);
        await HealthCache.writeRecords(patientId, records);
      } else {
        _handleFetchFailure();
      }
    } catch (_) {
      _handleFetchFailure();
    }
  }

  void _handleFetchFailure() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (_all.isEmpty) {
        _hasError = true;
      } else {
        _fromCache = true;
      }
    });
  }

  /// Returns the letters, or null when the API call fails (so the caller can
  /// keep previously-cached records instead of blanking the list).
  Future<List<HealthRecord>?> _loadHealthRecords(String patientId) async {
    final response = await PatientHealthRecordsCall.call(patientId: patientId);
    if (!response.succeeded) return null;

    final rows = PatientHealthRecordsCall.records(response.jsonBody);
    if (rows == null) return const [];

    return rows.whereType<Map>().map((raw) {
      final row = Map<String, dynamic>.from(raw);
      final rawType = (row['type'] ?? 'letter').toString();
      final type = HealthRecordType.values.firstWhere(
        (value) => value.name == rawType,
        orElse: () => HealthRecordType.letter,
      );
      final rawDetail = row['detail_data'] ?? row['detailData'];
      final detail = rawDetail is String && !rawDetail.contains('<')
          ? resolveBackendUrl(rawDetail, baseUrl: EnvConfig.platomBaseUrl)
          : rawDetail?.toString();

      return HealthRecord(
        type: type,
        title:
            stripHtmlToSingleLine((row['title'] ?? 'Health record').toString()),
        date: (row['date'] ?? '').toString(),
        author: stripHtmlToSingleLine((row['author'] ?? '').toString()),
        detailData: detail,
      );
    }).toList();
  }

  /// Stable identity for the "seen" store.
  String _recordKey(HealthRecord record) => '${record.title}|${record.date}';

  List<HealthRecord> get _visibleRecords {
    final q = _query.trim().toLowerCase();
    final records = List<HealthRecord>.of(_all);
    if (q.isEmpty) return records;
    return records.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.author.toLowerCase().contains(q) ||
          r.date.toLowerCase().contains(q) ||
          r.typeLabel.toLowerCase().contains(q);
    }).toList();
  }

  /// Sort by real date where possible, falling back to the raw string.
  DateTime _sortKey(HealthRecord record) {
    final parsed = DateTime.tryParse(record.date);
    if (parsed != null) return parsed;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _yearOf(HealthRecord record) {
    final parsed = DateTime.tryParse(record.date);
    if (parsed != null) return parsed.year.toString();
    final match = RegExp(r'(19|20)\d{2}').firstMatch(record.date);
    return match?.group(0) ?? 'Earlier';
  }

  String _formatDate(HealthRecord record) {
    final parsed = DateTime.tryParse(record.date);
    if (parsed == null) return record.date;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  Future<void> _openDetail(HealthRecord record) async {
    await SeenStore.markSeen(_seenCategory, _recordKey(record));
    if (mounted) {
      setState(() => _seen = {..._seen, _recordKey(record)});
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
    );
  }

  /// Records grouped by year, newest group first.
  Map<String, List<HealthRecord>> _grouped(List<HealthRecord> records) {
    final groups = <String, List<HealthRecord>>{};
    for (final record in records) {
      groups.putIfAbsent(_yearOf(record), () => []).add(record);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        if (_fromCache) _buildStaleBanner(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildStaleBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final text = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 16, color: AppColors.warning),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              'Records are saved on this device. Pull down to check for updates.',
              style: AppTextStyles.body2.copyWith(color: text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search records',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: fill,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space12,
            horizontal: AppSpacing.space12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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

    final visible = _visibleRecords;

    if (visible.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRecords,
        color: AppColors.accent,
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.space48),
            AppEmptyState(
              icon: Icons.assignment_outlined,
              title:
                  _query.isEmpty ? 'No records found' : 'No matching records',
              subtitle: _query.isEmpty
                  ? 'Your letters and medical certificates will appear here'
                  : 'Try a different search term',
            ),
          ],
        ),
      );
    }

    final groups = _grouped(visible);

    return RefreshIndicator(
      onRefresh: _loadRecords,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        children: [
          for (final entry in groups.entries) ...[
            _buildYearLabel(entry.key),
            for (final record in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                child: HealthRecordCard(
                  recordType: record.type,
                  title: record.title,
                  doctorName: record.author.isNotEmpty
                      ? record.author
                      : 'Health record',
                  date: _formatDate(record),
                  isNew: !_seen.contains(_recordKey(record)),
                  onTap: () => _openDetail(record),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildYearLabel(String year) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space4,
        top: AppSpacing.space4,
        bottom: AppSpacing.space8,
      ),
      child: Text(
        year,
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
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
}
