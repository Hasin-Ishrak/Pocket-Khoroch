import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_BD',
    symbol: '৳ ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount.abs() >= 100000) {
      return '৳ ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '৳ ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}