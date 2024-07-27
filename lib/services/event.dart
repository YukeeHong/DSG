import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/category.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TimeOfDay startTime;

  @HiveField(4)
  final TimeOfDay endTime;
  
  @HiveField(5)
  final Category category;

  /** 0: No repetition
   *  1: Repeat every _ days
   *  2: Repeat on certain day(s) of the week
   */
  @HiveField(6)
  final int repetition;

  @HiveField(7)
  final int id;

  Event(
      this.title,
      this.date,
      this.description,
      this.startTime,
      this.endTime,
      this.category,
      this.repetition,
      this.id,
      );
}