import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category.g.dart';

@HiveType(typeId: 6)
class Category extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final Color color;

  /** Type Bill:
   *  -1: Monthly goal
   *  -2: Income
   */
  @HiveField(2)
  final int id;

  Category({
    required this.title,
    required this.color,
    required this.id,
  });
}