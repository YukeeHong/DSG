import 'package:hive/hive.dart';

part 'assignment.g.dart';

@HiveType(typeId: 5)
class Assignment extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime due;

  @HiveField(3)
  final int id;

  Assignment({
    required this.title,
    required this.description,
    required this.due,
    required this.id,
  });
}