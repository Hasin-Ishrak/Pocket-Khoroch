import '../models/transaction_model.dart';
import '../models/category_model.dart';

enum TimeRange { week, month, year }

class CategorySpend {
  final CategoryModel category;
  final double total;
  CategorySpend({required this.category, required this.total});
}

class DailyTotal {
  final DateTime date;
  final double income;
  final double expense;
  DailyTotal({required this.date, required this.income, required this.expense});
}

class AnalyticsHelper {
  AnalyticsHelper._();

  static List<TransactionModel> filterByRange(
    List<TransactionModel> transactions,
    TimeRange range,
  ) {
    final now = DateTime.now();
    late DateTime start;
    switch (range) {
      case TimeRange.week:
        start = now.subtract(const Duration(days: 7));
        break;
      case TimeRange.month:
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case TimeRange.year:
        start = DateTime(now.year - 1, now.month, now.day);
        break;
    }
    return transactions.where((t) => t.date.isAfter(start)).toList();
  }

  static List<CategorySpend> expenseByCategory(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final Map<String, double> totals = {};

    for (final t in expenses) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }

    final result = totals.entries.map((entry) {
      final category = AppCategories.findById(entry.key);
      return CategorySpend(
        category: category ?? AppCategories.expenseCategories.last,
        total: entry.value,
      );
    }).toList();

    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  static List<DailyTotal> dailyTotals(List<TransactionModel> transactions, TimeRange range) {
    final filtered = filterByRange(transactions, range);
    final Map<String, DailyTotal> grouped = {};

    for (final t in filtered) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = DailyTotal(
          date: DateTime(t.date.year, t.date.month, t.date.day),
          income: t.isIncome ? t.amount : 0,
          expense: t.isExpense ? t.amount : 0,
        );
      } else {
        grouped[key] = DailyTotal(
          date: existing.date,
          income: existing.income + (t.isIncome ? t.amount : 0),
          expense: existing.expense + (t.isExpense ? t.amount : 0),
        );
      }
    }

    final result = grouped.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  static String? topCategoryInsight(List<TransactionModel> transactions) {
    final breakdown = expenseByCategory(transactions);
    if (breakdown.isEmpty) return null;
    final top = breakdown.first;
    final total = breakdown.fold(0.0, (sum, c) => sum + c.total);
    final percent = total > 0 ? (top.total / total * 100).round() : 0;
    return '${top.category.name} is your top expense at $percent% of spending';
  }
}