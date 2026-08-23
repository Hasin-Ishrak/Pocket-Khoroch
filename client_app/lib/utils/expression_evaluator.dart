import 'package:math_expressions/math_expressions.dart';

class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Tries to evaluate a math expression like "150+200" or "50*3-10".
  /// Returns null if the input isn't a valid expression.
  static double? tryEvaluate(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return null;

    try {
      final parser = Parser();
      final expression = parser.parse(cleaned);
      final result = expression.evaluate(EvaluationType.REAL, ContextModel());
      if (result.isNaN || result.isInfinite) return null;
      return result.toDouble();
    } catch (_) {
      return null;
    }
  }

  /// True if input contains operators, meaning it's an expression, not a plain number.
  static bool looksLikeExpression(String input) {
    return RegExp(r'[+\-*/]').hasMatch(input);
  }
}