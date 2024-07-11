import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nus_orbital_chronos/services/course.dart';
import 'package:nus_orbital_chronos/services/semester.dart';
import 'package:nus_orbital_chronos/services/computeGPA.dart';

class SemesterScreen extends StatefulWidget {
  final int sem;

  SemesterScreen({required this.sem});

  @override
  _SemesterScreenState createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  final _courseNameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _creditsController = TextEditingController();
  late Box<Semester> semesterBox;
  late Box<Course> courseBox;

  @override
  void initState() {
    super.initState();
    semesterBox = Hive.box<Semester>('Semesters');
    courseBox = Hive.box<Course>('Courses');
  }

  void _addCourse() {
    final String courseName = _courseNameController.text;
    final String grade = _gradeController.text;
    final int credits = int.parse(_creditsController.text);
    final course = Course(name: courseName, grade: grade, credits: credits, isIncludedInGPA: 1, sem: widget.sem);

    final courseKey = '${widget.sem}_$courseName';
    courseBox.put(courseKey, course);

    _courseNameController.clear();
    _gradeController.clear();
    _creditsController.clear();
    setState(() {});
  }

  void _deleteCourse(int index, String courseName) {
    final courseKey = '${widget.sem}_$courseName';
    courseBox.delete(courseKey);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Course> courses = [];
    for (Course course in courseBox.values.toList()) {
      if (course.sem == widget.sem) {
        courses.add(course);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Semester ${widget.sem}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            TextField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grade'),
            ),
            TextField(
              controller: _creditsController,
              decoration: InputDecoration(labelText: 'Credits'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCourse,
              child: Text('Add Course'),
            ),
            SizedBox(height: 20),
            Text(
              'Current GPA: ${computeGPA.calculateGPA(courses).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return ListTile(
                    title: Text(course.name),
                    subtitle: Text('Grade: ${course.grade}, Credits: ${course.credits}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _deleteCourse(index, course.name);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
