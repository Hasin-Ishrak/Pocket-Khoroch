import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

enum ReminderType { billDue, semesterFee, dailySavings, custom }
enum ReminderRepeat { none, daily, weekly, monthly, yearly }

@HiveType(typeId: 3)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime dateTime;

  @HiveField(5)
  final String type; // stored as string, maps to ReminderType

  @HiveField(6)
  final String repeat; // stored as string, maps to ReminderRepeat

  @HiveField(7)
  final bool isEnabled;

  @HiveField(8)
  final int notificationId; // used by flutter_local_notifications

  @HiveField(9)
  bool isSynced;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    this.note,
    required this.dateTime,
    required this.type,
    this.repeat = 'none',
    this.isEnabled = true,
    required this.notificationId,
    this.isSynced = false,
  });

  ReminderType get typeEnum => ReminderType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ReminderType.custom,
      );

  ReminderRepeat get repeatEnum => ReminderRepeat.values.firstWhere(
        (e) => e.name == repeat,
        orElse: () => ReminderRepeat.none,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'note': note,
        'dateTime': dateTime.toIso8601String(),
        'type': type,
        'repeat': repeat,
        'isEnabled': isEnabled,
        'notificationId': notificationId,
      };

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
      type: map['type'] as String,
      repeat: map['repeat'] as String? ?? 'none',
      isEnabled: map['isEnabled'] as bool? ?? true,
      notificationId: map['notificationId'] as int,
      isSynced: true,
    );
  }

  ReminderModel copyWith({
    String? title,
    String? note,
    DateTime? dateTime,
    String? type,
    String? repeat,
    bool? isEnabled,
    bool? isSynced,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      repeat: repeat ?? this.repeat,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationId: notificationId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}