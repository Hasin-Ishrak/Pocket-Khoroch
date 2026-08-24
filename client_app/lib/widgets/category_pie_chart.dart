import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/analytics_helper.dart';
import '../utils/currency_formatter.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategorySpend> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No expense data yet')),
      );
    }

    final total = widget.data.fold(0.0, (sum, c) => sum + c.total);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(widget.data.length, (index) {
                final item = widget.data[index];
                final isTouched = index == _touchedIndex;
                final percent = total > 0 ? (item.total / total * 100) : 0;
                return PieChartSectionData(
                  color: item.category.color,
                  value: item.total,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: isTouched ? 64 : 56,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: item.category.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.category.name} · ${CurrencyFormatter.formatCompact(item.total)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}