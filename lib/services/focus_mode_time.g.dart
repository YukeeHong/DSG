// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_mode_time.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusModeTimeAdapter extends TypeAdapter<FocusModeTime> {
  @override
  final int typeId = 10;

  @override
  FocusModeTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusModeTime(
      hour: fields[0] as int,
      minute: fields[1] as int,
      second: fields[2] as int,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FocusModeTime obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute)
      ..writeByte(2)
      ..write(obj.second)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusModeTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
