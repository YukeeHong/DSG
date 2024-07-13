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
    var courses = courseBox.values.toList();
    int count = 0;

    for (Course course in courses) {
      if (course.sem == widget.sem) {
        count++;
      }
    }

    if (count >= 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 12 courses per semester')),
      );
      return;
    }

    if (_courseNameController.text.isEmpty || _creditsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    } else if (_creditsController.text.contains('.') ||
        _creditsController.text.contains(',') ||
        _creditsController.text.contains('-') ||
        _creditsController.text.contains(' ') ||
        int.parse(_creditsController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a positive integer in the "credits" field')),
      );
      return;
    }

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
      backgroundColor: Colors.indigo[200],
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
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _courseNameController,
                      decoration: InputDecoration(labelText: 'Course Name'),
                    ),
                    Container(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _creditsController,
                              decoration: InputDecoration(labelText: 'Credits'),
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Text('Grade', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 64,
                                child: DropdownButton(
                                  value: selectedGrade,
                                  icon: const Icon(Icons.arrow_drop_down),
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
                  ],

                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Semester GPA: ${computeGPA.calculateGPA(courses).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
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
                      ),
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
