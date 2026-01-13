// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordProgressModelAdapter extends TypeAdapter<WordProgressModel> {
  @override
  final int typeId = 1;

  @override
  WordProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordProgressModel()
      ..wordId = fields[0] as String
      ..level1Completed = fields[1] as int
      ..correctCount = fields[2] as int
      ..enToBgCount = fields[3] as int
      ..bgToEnCount = fields[4] as int
      ..lastAnswered = fields[5] as DateTime?
      ..skipCount = fields[6] as int
      ..easeFactor = fields[7] as double
      ..interval = fields[8] as int
      ..nextReviewDate = fields[9] as DateTime?
      ..consecutiveCorrect = fields[10] as int;
  }

  @override
  void write(BinaryWriter writer, WordProgressModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.wordId)
      ..writeByte(1)
      ..write(obj.level1Completed)
      ..writeByte(2)
      ..write(obj.correctCount)
      ..writeByte(3)
      ..write(obj.enToBgCount)
      ..writeByte(4)
      ..write(obj.bgToEnCount)
      ..writeByte(5)
      ..write(obj.lastAnswered)
      ..writeByte(6)
      ..write(obj.skipCount)
      ..writeByte(7)
      ..write(obj.easeFactor)
      ..writeByte(8)
      ..write(obj.interval)
      ..writeByte(9)
      ..write(obj.nextReviewDate)
      ..writeByte(10)
      ..write(obj.consecutiveCorrect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
