import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../utils/analytics_helper.dart';

class TrendBarChart extends StatelessWidget {
  final List<DailyTotal> data;

  const TrendBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No transaction data yet')),
      );
    }

    final maxY = data.fold(0.0, (max, d) {
      final higher = d.income > d.expense ? d.income : d.expense;
      return higher > max ? higher : max;
    });

    // Show at most 10 bars to keep it readable — take most recent entries
    final displayData = data.length > 10 ? data.sublist(data.length - 10) : data;

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 100 : maxY * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= displayData.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('d/M').format(displayData[index].date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(displayData.length, (index) {
            final d = displayData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: d.income, color: AppColors.income, width: 7, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: d.expense, color: AppColors.expense, width: 7, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }),
        ),
      ),
    );
  }
}