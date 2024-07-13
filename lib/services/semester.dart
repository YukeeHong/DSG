import 'package:hive/hive.dart';

part 'semester.g.dart';

@HiveType(typeId: 2)
class Semester extends HiveObject {
  @HiveField(0)
  final int sem;

  Semester({
    required this.sem,
  });
}
