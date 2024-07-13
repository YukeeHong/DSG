import 'package:hive/hive.dart';

part 'grade_points.g.dart';

@HiveType(typeId: 4)
class GradePoints extends HiveObject {
  @HiveField(0)
  final double points;

  GradePoints({
    required this.points
  });

  static void setToDefault() {
    late Box<GradePoints> gradesBox = Hive.box<GradePoints>('GradePoints');

    gradesBox.put('A+', GradePoints(points: 5.0));
    gradesBox.put('A', GradePoints(points: 5.0));
    gradesBox.put('A-', GradePoints(points: 4.5));
    gradesBox.put('B+', GradePoints(points: 4.0));
    gradesBox.put('B', GradePoints(points: 3.5));
    gradesBox.put('B-', GradePoints(points: 3.0));
    gradesBox.put('C+', GradePoints(points: 2.5));
    gradesBox.put('C', GradePoints(points: 2.0));
    gradesBox.put('D+', GradePoints(points: 1.5));
    gradesBox.put('D', GradePoints(points: 1.0));
  }
}