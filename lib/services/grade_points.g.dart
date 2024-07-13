// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_points.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradePointsAdapter extends TypeAdapter<GradePoints> {
  @override
  final int typeId = 4;

  @override
  GradePoints read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradePoints(
      points: fields[0] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GradePoints obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradePointsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
