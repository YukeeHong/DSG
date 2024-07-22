// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 0;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      description: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      id: fields[3] as int,
      category: fields[4] as Category,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
