import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final typeId = 7;

  @override
  Color read(BinaryReader reader) {
    int value = reader.readUint32();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeUint32(obj.value);
  }
}
