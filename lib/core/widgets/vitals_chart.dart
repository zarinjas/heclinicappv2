import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'app_skeleton.dart';

class VitalChartPoint {
  final DateTime date;
  final double value;

  const VitalChartPoint({required this.date, required this.value});
}

class VitalsChart extends StatelessWidget {
  final String title;
  final String unit;
  final Color lineColor;
  final List<VitalChartPoint> dataPoints;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const VitalsChart({
    super.key,
    required this.title,
    required this.unit,
    required this.lineColor,
    required this.dataPoints,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (errorMessage != null) {
      return AppCard(
        child: AppErrorState(
          title: title,
          subtitle: errorMessage!,
          onRetry: onRetry,
        ),
      );
    }

    if (dataPoints.isEmpty) {
      return AppCard(
        child: const AppEmptyState(
          icon: Icons.show_chart,
          title: 'No vitals data yet',
          subtitle: 'Vital readings will appear here',
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          SizedBox(height: 190, child: _LineChart(dataPoints: dataPoints, lineColor: lineColor, unit: unit)),
          const SizedBox(height: AppSpacing.space8),
          if (dataPoints.isNotEmpty)
            Text(
              'Last: ${dataPoints.last.value.toStringAsFixed(1)} $unit — ${_formatDate(dataPoints.last.date)}',
              style: AppTextStyles.body2.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class VitalsChartSkeleton extends StatelessWidget {
  const VitalsChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.slider(),
          const SizedBox(height: AppSpacing.space8),
          AppSkeleton.listItem(),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<VitalChartPoint> dataPoints;
  final Color lineColor;
  final String unit;

  const _LineChart({required this.dataPoints, required this.lineColor, required this.unit});

  List<FlSpot> _spots() {
    return dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = _spots();
    if (spots.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: (isDark ? AppColors.dividerDark : AppColors.divider).withAlpha(80),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: spots.length <= 1 ? 1 : (spots.length - 1).toDouble(),
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= dataPoints.length) return const SizedBox.shrink();
                final d = dataPoints[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.space4),
                  child: Text(
                    '${d.day}/${d.month}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                return Text(
                  value == value.truncateToDouble() ? value.toInt().toString() : value.toStringAsFixed(1),
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 9,
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
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: spots.length <= 30,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3,
                color: lineColor,
                strokeWidth: 1.5,
                strokeColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withAlpha(25),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => isDark ? AppColors.surfaceDark : AppColors.surface,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final point = dataPoints[spot.spotIndex];
              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              return LineTooltipItem(
                '${point.value.toStringAsFixed(1)} $unit\n${point.date.day} ${months[point.date.month - 1]} ${point.date.year}',
                AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
