import 'package:hive/hive.dart';
import 'package:nus_orbital_chronos/services/grade_points.dart';

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
    late Box<GradePoints> gradesBox = Hive.box<GradePoints>('GradePoints');

    switch (grade) {
      case 'A+':
        return gradesBox.get('A+')?.points ?? 5.0;
      case 'A':
        return gradesBox.get('A')?.points ?? 5.0;
      case 'A-':
        return gradesBox.get('A-')?.points ?? 4.5;
      case 'B+':
        return gradesBox.get('B+')?.points ?? 4.0;
      case 'B':
        return gradesBox.get('B')?.points ?? 3.5;
      case 'B-':
        return gradesBox.get('B-')?.points ?? 3.0;
      case 'C+':
        return gradesBox.get('C+')?.points ?? 2.5;
      case 'C':
        return gradesBox.get('C')?.points ?? 2.0;
      case 'D+':
        return gradesBox.get('D+')?.points ?? 1.5;
      case 'D':
        return gradesBox.get('D')?.points ?? 1.0;
      case 'F':
      default:
        return 0.0;
    }
  }
}