import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nus_orbital_chronos/services/course.dart';
import 'package:nus_orbital_chronos/services/semester.dart';
import 'package:nus_orbital_chronos/services/compute_gpa.dart';

class SemesterScreen extends StatefulWidget {
  final int sem;

  SemesterScreen({required this.sem});

  @override
  _SemesterScreenState createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  final _courseNameController = TextEditingController();
  final _creditsController = TextEditingController();
  String selectedGrade = 'A+';
  late Box<Semester> semesterBox;
  late Box<Course> courseBox;

  @override
  void initState() {
    super.initState();
    semesterBox = Hive.box<Semester>('Semesters');
    courseBox = Hive.box<Course>('Courses');
  }

  bool checkPassFail(String grade) {
    switch (grade) {
      case 'S/CS':
      case 'U/CU':
        return true;
      default:
        return false;
    }
  }

  void _addCourse() {
    final String courseName = _courseNameController.text;
    final String grade = selectedGrade;
    final int credits = int.parse(_creditsController.text);
    final int included = checkPassFail(grade) ? 0 : 1;
    final course = Course(name: courseName, grade: grade, credits: credits, isIncludedInGPA: included, sem: widget.sem);

    final courseKey = '${widget.sem}_$courseName';
    courseBox.put(courseKey, course);

    _courseNameController.clear();
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
        title: Text('Semester ${widget.sem}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  TextField(
                    controller: _creditsController,
                    decoration: InputDecoration(labelText: 'Credits'),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                  ),
                  SizedBox(width: 50),
                  DropdownButton(
                    value: selectedGrade,
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: Container(height: 2),
                    onChanged: (String? newGrade) {
                      setState(() {
                        selectedGrade = newGrade!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'A+',
                        child: Text('A+'),
                      ),
                      DropdownMenuItem(
                        value: 'A',
                        child: Text('A'),
                      ),
                      DropdownMenuItem(
                        value: 'A-',
                        child: Text('A-'),
                      ),
                      DropdownMenuItem(
                        value: 'B+',
                        child: Text('B+'),
                      ),
                      DropdownMenuItem(
                        value: 'B',
                        child: Text('B'),
                      ),
                      DropdownMenuItem(
                        value: 'B-',
                        child: Text('B-'),
                      ),
                      DropdownMenuItem(
                        value: 'C+',
                        child: Text('C+'),
                      ),
                      DropdownMenuItem(
                        value: 'C',
                        child: Text('C'),
                      ),
                      DropdownMenuItem(
                        value: 'D+',
                        child: Text('D+'),
                      ),
                      DropdownMenuItem(
                        value: 'D',
                        child: Text('D'),
                      ),
                      DropdownMenuItem(
                        value: 'F',
                        child: Text('F'),
                      ),
                      DropdownMenuItem(
                        value: 'S/CS',
                        child: Text('S/CS'),
                      ),
                      DropdownMenuItem(
                        value: 'U/CU',
                        child: Text('U/CU'),
                      ),
                    ],
                  ),
                ],
              ),
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
                    tileColor: Colors.indigoAccent[100],
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
