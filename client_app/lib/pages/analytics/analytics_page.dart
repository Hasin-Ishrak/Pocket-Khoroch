import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/analytics_helper.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/trend_bar_chart.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pro_gate.dart';
import '../../theme/app_colors.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  TimeRange _range = TimeRange.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionProvider = context.watch<TransactionProvider>();
    final allTransactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: allTransactions.isEmpty
          ? const EmptyState(
              icon: Icons.insights_outlined,
              title: 'No data to analyze yet',
              subtitle: 'Add some transactions first to see your spending insights',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ProGate(
                featureName: 'Analytics',
                child: _buildContent(context, theme, allTransactions),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, allTransactions) {
    final filtered = AnalyticsHelper.filterByRange(allTransactions, _range);
    final categoryBreakdown = AnalyticsHelper.expenseByCategory(filtered);
    final trend = AnalyticsHelper.dailyTotals(allTransactions, _range);
    final insight = AnalyticsHelper.topCategoryInsight(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TimeRange>(
          segments: const [
            ButtonSegment(value: TimeRange.week, label: Text('Week')),
            ButtonSegment(value: TimeRange.month, label: Text('Month')),
            ButtonSegment(value: TimeRange.year, label: Text('Year')),
          ],
          selected: {_range},
          onSelectionChanged: (selection) => setState(() => _range = selection.first),
        ),
        const SizedBox(height: 20),

        if (insight != null)
          Card(
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded, color: AppColors.accentOnLight),
                  const SizedBox(width: 10),
                  Expanded(child: Text(insight, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),

        Text('Income vs Expense', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TrendBarChart(data: trend),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.income, label: 'Income'),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.expense, label: 'Expense'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Spending by Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryPieChart(data: categoryBreakdown),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}