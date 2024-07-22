import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/category.dart';

part 'bill.g.dart';

@HiveType(typeId: 0)
class Bill {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int id;

  @HiveField(4)
  final Category category;

  @HiveField(5)
  final TimeOfDay time;

  Bill({
    required this.description,
    required this.amount,
    required this.date,
    required this.id,
    required this.category,
    required this.time,
  });
}