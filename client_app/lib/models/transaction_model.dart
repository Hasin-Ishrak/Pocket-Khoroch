import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // 'income' or 'expense'

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  bool isSynced; // whether it's been pushed to Firestore

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
    this.isSynced = false,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSynced: true, 
    );
  }

  TransactionModel copyWith({
    double? amount,
    String? type,
    String? categoryId,
    DateTime? date,
    String? note,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}