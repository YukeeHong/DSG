import 'package:nus_orbital_chronos/services/course.dart';

class computeGPA {
  static double calculateGPA(List<Course> courses) {
    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var course in courses) {
      if (course.isIncludedInGPA == 1) {
        double gradePoint = course.gradePoint;
        totalPoints += gradePoint * course.credits;
        totalCredits += course.credits;
      }
    }

    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }
}