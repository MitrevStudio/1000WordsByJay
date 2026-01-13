// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 3;

  @override
  UserProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgressModel()
      ..currentLevel = fields[0] as int
      ..totalCorrect = fields[1] as int
      ..level1WordsCompleted = fields[2] as int
      ..level2WordsLearned = fields[3] as int
      ..todayCorrect = fields[4] as int
      ..lastPracticeDate = fields[5] as String?
      ..dayStreak = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.currentLevel)
      ..writeByte(1)
      ..write(obj.totalCorrect)
      ..writeByte(2)
      ..write(obj.level1WordsCompleted)
      ..writeByte(3)
      ..write(obj.level2WordsLearned)
      ..writeByte(4)
      ..write(obj.todayCorrect)
      ..writeByte(5)
      ..write(obj.lastPracticeDate)
      ..writeByte(6)
      ..write(obj.dayStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
