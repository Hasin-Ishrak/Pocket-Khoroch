import 'package:hive/hive.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 1)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double targetAmount;

  @HiveField(4)
  final double savedAmount;

  @HiveField(5)
  final DateTime targetDate;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  bool isSynced;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.targetDate,
    required this.createdAt,
    this.isSynced = false,
  });

  double get remainingAmount => (targetAmount - savedAmount).clamp(0, double.infinity);

  int get daysRemaining {
    final now = DateTime.now();
    final diff = targetDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get progressPercent =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);

  double get dailyTargetNeeded {
    final days = daysRemaining;
    if (days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  double get weeklyTargetNeeded => dailyTargetNeeded * 7;

  double get monthlyTargetNeeded => dailyTargetNeeded * 30;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      targetDate: DateTime.parse(map['targetDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSynced: true,
    );
  }

  SavingsGoalModel copyWith({
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    bool? isSynced,
  }) {
    return SavingsGoalModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}