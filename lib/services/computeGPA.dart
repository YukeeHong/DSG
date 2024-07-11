import 'package:nus_orbital_chronos/services/course.dart';

class computeGPA {
  static double calculateGPA(List<Course> courses) {
    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var course in courses) {
      double gradePoint = gradeToPoint(course.grade);
      totalPoints += gradePoint * course.credits;
      totalCredits += course.credits;
    }

    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  static double gradeToPoint(String grade) {
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
        return 0.0;
      default:
        return 0.0;
    }
  }
}