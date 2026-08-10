import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/vitals_chart.dart';

/// One measured vital (weight, blood pressure, ...) and its history.
class _VitalSeries {
  final String name;
  final String unit;
  final List<VitalChartPoint> points;

  const _VitalSeries({required this.name, required this.unit, required this.points});
}

class VitalsTab extends StatefulWidget {
  const VitalsTab({super.key});

  @override
  State<VitalsTab> createState() => _VitalsTabState();
}

class _VitalsTabState extends State<VitalsTab> {
  bool _isLoading = true;
  bool _hasError = false;
  List<_VitalSeries> _vitals = const [];

  /// Chart colours, cycled so each vital is visually distinct.
  static const _lineColors = [
    AppColors.accent,
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.redAccent,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVitals());
  }

  Future<void> _loadVitals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final patientId = FFAppState().idplato;

    if (patientId.isEmpty) {
      setState(() {
        _vitals = const [];
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await GetVitalsGraphingCall.call(
        patientId: patientId,
        forceRefresh: true,
      );

      if (!mounted) return;

      if (!response.succeeded) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      setState(() {
        _vitals = _parse(response.jsonBody);
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

  /// The API returns a map of vital name to a list of readings.
  List<_VitalSeries> _parse(dynamic body) {
    if (body is! Map || body.isEmpty) return const [];

    final series = <_VitalSeries>[];

    for (final entry in body.entries) {
      final raw = entry.value;
      if (raw is! List) continue;

      final points = <VitalChartPoint>[];

      for (final item in raw) {
        if (item is! Map) continue;

        // Readings use one of several timestamp field names.
        final rawDate = item['timestamp'] ?? item['time'] ?? item['date'];
        final date = DateTime.tryParse(rawDate?.toString() ?? '');
        final value = double.tryParse(item['value']?.toString() ?? '');

        if (date != null && value != null) {
          points.add(VitalChartPoint(date: date, value: value));
        }
      }

      if (points.isEmpty) continue;

      points.sort((a, b) => a.date.compareTo(b.date));
      final name = entry.key.toString();
      series.add(_VitalSeries(name: name, unit: _inferUnit(name), points: points));
    }

    return series;
  }

  /// The API does not send units, so derive them from the vital's name.
  static String _inferUnit(String vitalName) {
    final lower = vitalName.toLowerCase();
    if (lower.contains('weight') || lower.contains('berat')) return 'kg';
    if (lower.contains('pressure') || lower.contains('blood')) return 'mmHg';
    if (lower.contains('glucose') || lower.contains('gula')) return 'mmol/L';
    if (lower.contains('heart') || lower.contains('pulse')) return 'bpm';
    if (lower.contains('temperature') || lower.contains('suhu')) return '\u00B0C';
    if (lower.contains('spo2') || lower.contains('oxygen') || lower.contains('saturation')) return '%';
    if (lower.contains('height') || lower.contains('tinggi')) return 'cm';
    if (lower.contains('bmi')) return 'kg/m\u00B2';
    if (lower.contains('cholesterol')) return 'mmol/L';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();

    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load vitals',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadVitals,
      );
    }

    if (_vitals.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadVitals,
        color: AppColors.accent,
        child: ListView(
          children: const [
            SizedBox(height: AppSpacing.space48),
            AppEmptyState(
              icon: Icons.favorite_outline,
              title: 'No vitals recorded yet',
              subtitle: 'Your health trends will appear here',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVitals,
      color: AppColors.accent,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _vitals.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space16),
        itemBuilder: (_, i) {
          final vital = _vitals[i];
          return VitalsChart(
            title: vital.name,
            unit: vital.unit,
            lineColor: _lineColors[i % _lineColors.length],
            dataPoints: vital.points,
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space16),
      itemBuilder: (_, i) => AppSkeleton.card(),
    );
  }
}
