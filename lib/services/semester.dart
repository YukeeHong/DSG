import 'package:hive/hive.dart';
//import 'course.dart';

part 'semester.g.dart';

@HiveType(typeId: 2)
class Semester extends HiveObject {
  @HiveField(0)
  final int sem;

  Semester({
    required this.sem,
  });
/**
  double get gpa {
    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var course in courses) {
      if (course.isIncludedInGPA) {
        totalPoints += course.gradePoint * course.credits;
        totalCredits += course.credits;
      }
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }
    */
}
