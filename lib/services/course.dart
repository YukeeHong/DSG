import 'package:hive/hive.dart';

part 'course.g.dart';

@HiveType(typeId: 3)
class Course extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String grade;

  @HiveField(2)
  final int credits;

  @HiveField(3)
  final int isIncludedInGPA;

  @HiveField(4)
  final int sem;

  Course({
    required this.name,
    required this.grade,
    required this.credits,
    required this.isIncludedInGPA,
    required this.sem,
  });

  double get gradePoint {
    switch (grade) {
      case 'A+':
      case 'A':
        return 5.0;
      case 'A-':
        return 4.5;
      case 'B+':
        return 4.0;
      case 'B':
        return 3.5;
      case 'B-':
        return 3.0;
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.5;
      case 'D+':
        return 1.0;
      case 'D':
        return 0.5;
      case 'F':
      default:
        return 0.0;
    }
  }
}