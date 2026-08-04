// GENERATED CODE - DO NOT MODIFY BY HAND
// This file mirrors exactly what `flutter pub run build_runner build`
// would generate from the @HiveType/@HiveField annotations in goal.dart.
// It is checked in so the project builds without running build_runner.
// If you add/remove @HiveField entries later, regenerate with:
//   flutter pub run build_runner build --delete-conflicting-outputs

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 0;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      emoji: fields[2] as String,
      streak: fields[3] as int,
      longestStreak: fields[4] as int,
      dailyMinutes: fields[5] as int,
      lastCompleted: fields[6] as DateTime?,
      notes: (fields[7] as List).cast<LearningNote>(),
      xp: fields[8] as int,
      level: fields[9] as int,
      createdAt: fields[10] as DateTime,
      unlockedBadgeIds: (fields[11] as List).cast<String>(),
      // Nullable cast: goals saved before this field existed simply won't
      // have byte 12 in their stored map, so this reads as null and the
      // Goal constructor's `themeId ?? 'purple'` default takes over —
      // existing goals quietly become "purple" (the original-only color)
      // instead of failing to load.
      themeId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.streak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.dailyMinutes)
      ..writeByte(6)
      ..write(obj.lastCompleted)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.xp)
      ..writeByte(9)
      ..write(obj.level)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.unlockedBadgeIds)
      ..writeByte(12)
      ..write(obj.themeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
