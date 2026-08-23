// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsGoalModelAdapter extends TypeAdapter<SavingsGoalModel> {
  @override
  final int typeId = 1;

  @override
  SavingsGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoalModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      targetAmount: fields[3] as double,
      savedAmount: fields[4] as double,
      targetDate: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      isSynced: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.savedAmount)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
