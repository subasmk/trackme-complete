// GENERATED CODE - DO NOT MODIFY BY HAND
// This file mirrors exactly what `flutter pub run build_runner build`
// would generate from the @HiveType/@HiveField annotations in learning_note.dart.
// It is checked in so the project builds without running build_runner.

part of 'learning_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningNoteAdapter extends TypeAdapter<LearningNote> {
  @override
  final int typeId = 1;

  @override
  LearningNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningNote(
      text: fields[0] as String,
      date: fields[1] as DateTime,
      id: fields[2] as String,
      // Both nullable casts: notes saved before this feature existed
      // simply won't have bytes 3/4, so these read as null (no attachment).
      imagePath: fields[3] as String?,
      linkUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LearningNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.linkUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
