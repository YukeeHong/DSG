import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/semester.dart';
import 'package:nus_orbital_chronos/services/course.dart';
import 'package:nus_orbital_chronos/pages/semester_screen.dart';
import 'package:nus_orbital_chronos/services/compute_gpa.dart';

class GPACalc extends StatefulWidget {
  @override
  _GPACalcState createState() => _GPACalcState();
}

class _GPACalcState extends State<GPACalc> {
  late Box<Semester> semesterBox;
  late Box<Course> courseBox;

  @override
  void initState() {
    super.initState();
    semesterBox = Hive.box<Semester>('Semesters');
    courseBox = Hive.box<Course>('Courses');
  }

  void _addSemester() {
    var semesters = semesterBox.values.toList();
    int lowestFreeSem = 1;
    for (int i = 0; i < semesters.length; i++) {
      if (lowestFreeSem != semesters[i].sem) {
        break;
      }
      lowestFreeSem += 1;
    }

    semesterBox.put('Semester ${lowestFreeSem}', Semester(sem: lowestFreeSem));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator', style: TextStyle(color: Colors.white)),
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
            ValueListenableBuilder(
                valueListenable: courseBox.listenable(),
                builder: (context, Box<Course> box, _) {
                  return Text(
                    'Current GPA: ${computeGPA.calculateGPA(courseBox.values.toList()).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24),
                  );
                }
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSemester,
              child: Text('Add Semester'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: semesterBox.listenable(),
                builder: (context, Box<Semester> box, _) {
                  var semesters = box.values.toList();
                  return ListView.builder(
                    itemCount: semesters.length,
                    itemBuilder: (context, index) {
                      final semester = semesters[index];
                      return ListTile(
                        title: Text('Semester ${semester.sem}'),
                        tileColor: Colors.indigoAccent[100],
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            box.delete(box.keyAt(index));
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SemesterScreen(sem: semester.sem),
                            ),
                          );
                        },
                      );
                    },
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
