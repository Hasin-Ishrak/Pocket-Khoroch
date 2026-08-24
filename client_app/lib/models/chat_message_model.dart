import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 2)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String role; // 'user' or 'model'

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}