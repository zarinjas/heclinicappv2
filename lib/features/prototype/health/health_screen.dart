import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/app_chip.dart';
import '/core/widgets/app_empty_state.dart';
import '/core/widgets/document_item.dart';
import '/core/widgets/health_record_card.dart';
import '/core/widgets/vitals_chart.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _mainFilter = 0;
  int _recordFilter = 0;

  static const _mainTabs = ['Records', 'Vitals', 'Documents'];
  static const _recordTabs = ['All', 'Notes', 'Letters', 'Lab Results', 'MC'];

  static const _allRecords = [
    _RecordData(
      type: HealthRecordType.note,
      title: 'Annual Checkup Notes',
      doctorName: 'Dr. Ahmad Rizal',
      date: '14 Jul 2025',
    ),
    _RecordData(
      type: HealthRecordType.letter,
      title: 'Referral Letter - Cardiology',
      doctorName: 'Dr. Sarah Lim',
      date: '10 Jul 2025',
    ),
    _RecordData(
      type: HealthRecordType.lab,
      title: 'Blood Test Results',
      doctorName: 'Dr. Tan Wei Ming',
      date: '05 Jul 2025',
    ),
    _RecordData(
      type: HealthRecordType.mc,
      title: 'Medical Certificate - 2 days',
      doctorName: 'Dr. Wong Mei Ling',
      date: '03 Jun 2025',
    ),
  ];

  List<_RecordData> get _filteredRecords {
    if (_recordFilter == 0) return _allRecords;
    final typeMap = <int, HealthRecordType>{
      1: HealthRecordType.note,
      2: HealthRecordType.letter,
      3: HealthRecordType.lab,
      4: HealthRecordType.mc,
    };
    final target = typeMap[_recordFilter]!;
    return _allRecords.where((r) => r.type == target).toList();
  }

  static final _weightPoints = [
    VitalChartPoint(date: DateTime(2025, 7, 1), value: 68),
    VitalChartPoint(date: DateTime(2025, 7, 7), value: 67.5),
    VitalChartPoint(date: DateTime(2025, 7, 14), value: 68.2),
  ];

  static final _bpPoints = [
    VitalChartPoint(date: DateTime(2025, 7, 1), value: 120),
    VitalChartPoint(date: DateTime(2025, 7, 7), value: 118),
    VitalChartPoint(date: DateTime(2025, 7, 14), value: 122),
  ];

  static final _glucosePoints = [
    VitalChartPoint(date: DateTime(2025, 7, 1), value: 5.6),
    VitalChartPoint(date: DateTime(2025, 7, 7), value: 5.4),
    VitalChartPoint(date: DateTime(2025, 7, 14), value: 5.8),
  ];

  static final _documents = [
    const _DocumentData(
      fileType: DocumentFileType.pdf,
      name: 'Blood Test Report Jul 2025',
      typeLabel: 'PDF',
      uploadedAt: '14 Jul 2025',
      sizeBytes: 245000,
    ),
    const _DocumentData(
      fileType: DocumentFileType.pdf,
      name: 'X-Ray Report - Chest',
      typeLabel: 'PDF',
      uploadedAt: '10 Jul 2025',
      sizeBytes: 1200000,
    ),
    const _DocumentData(
      fileType: DocumentFileType.pdf,
      name: 'Vaccination Record',
      typeLabel: 'PDF',
      uploadedAt: '01 Jun 2025',
      sizeBytes: 340000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Health'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            child: Row(
              children: List.generate(_mainTabs.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _mainTabs.length - 1 ? AppSpacing.space8 : 0,
                  ),
                  child: AppChip(
                    label: _mainTabs[i],
                    type: AppChipType.filter,
                    isSelected: _mainFilter == i,
                    onTap: () => setState(() => _mainFilter = i),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: IndexedStack(
              index: _mainFilter,
              children: [
                _buildRecordsPanel(),
                _buildVitalsPanel(),
                _buildDocumentsPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_recordTabs.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _recordTabs.length - 1 ? AppSpacing.space8 : 0,
                  ),
                  child: AppChip(
                    label: _recordTabs[i],
                    type: AppChipType.filter,
                    isSelected: _recordFilter == i,
                    onTap: () => setState(() => _recordFilter = i),
                  ),
                );
              }),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: _filteredRecords.isEmpty
              ? AppEmptyState.noRecords
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final r = _filteredRecords[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _filteredRecords.length - 1
                            ? AppSpacing.space12
                            : 0,
                      ),
                      child: HealthRecordCard(
                        recordType: r.type,
                        title: r.title,
                        doctorName: r.doctorName,
                        date: r.date,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVitalsPanel() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        VitalsChart(
          title: 'Weight',
          unit: 'kg',
          lineColor: const Color(0xFF3B8DFF),
          dataPoints: _weightPoints,
        ),
        const SizedBox(height: AppSpacing.space12),
        VitalsChart(
          title: 'Blood Pressure',
          unit: 'mmHg',
          lineColor: const Color(0xFFF5A623),
          dataPoints: _bpPoints,
        ),
        const SizedBox(height: AppSpacing.space12),
        VitalsChart(
          title: 'Blood Glucose',
          unit: 'mmol/L',
          lineColor: const Color(0xFF2868F5),
          dataPoints: _glucosePoints,
        ),
      ],
    );
  }

  Widget _buildDocumentsPanel() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final d = _documents[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _documents.length - 1
                ? AppSpacing.space12
                : 0,
          ),
          child: DocumentItem(
            fileType: d.fileType,
            name: d.name,
            typeLabel: d.typeLabel,
            uploadedAt: d.uploadedAt,
            sizeBytes: d.sizeBytes,
          ),
        );
      },
    );
  }
}

class _RecordData {
  final HealthRecordType type;
  final String title;
  final String doctorName;
  final String date;

  const _RecordData({
    required this.type,
    required this.title,
    required this.doctorName,
    required this.date,
  });
}

class _DocumentData {
  final DocumentFileType fileType;
  final String name;
  final String typeLabel;
  final String uploadedAt;
  final int sizeBytes;

  const _DocumentData({
    required this.fileType,
    required this.name,
    required this.typeLabel,
    required this.uploadedAt,
    required this.sizeBytes,
  });
}
