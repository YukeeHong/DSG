import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/course.dart';
import 'package:nus_orbital_chronos/services/grade_points.dart';

class GradePointSettings extends StatefulWidget {
  const GradePointSettings({super.key});

  @override
  State<GradePointSettings> createState() => _GradePointSettingsState();
}

class _GradePointSettingsState extends State<GradePointSettings> {
  late Box<Course> courseBox;
  late Box<GradePoints> gradesBox;

  final _aPlus = TextEditingController();
  final _a = TextEditingController();
  final _aMinus = TextEditingController();
  final _bPlus = TextEditingController();
  final _b = TextEditingController();
  final _bMinus = TextEditingController();
  final _cPlus = TextEditingController();
  final _c = TextEditingController();
  final _dPlus = TextEditingController();
  final _d = TextEditingController();

  @override
  void initState() {
    super.initState();
    gradesBox = Hive.box<GradePoints>('GradePoints');

    _aPlus.text = (gradesBox.get('A+')?.points ?? 5.0).toString();
    _a.text = (gradesBox.get('A')?.points ?? 5.0).toString();
    _aMinus.text = (gradesBox.get('A-')?.points ?? 4.5).toString();
    _bPlus.text = (gradesBox.get('B+')?.points ?? 4.0).toString();
    _b.text = (gradesBox.get('B')?.points ?? 3.5).toString();
    _bMinus.text = (gradesBox.get('B-')?.points ?? 3.0).toString();
    _cPlus.text = (gradesBox.get('C+')?.points ?? 2.5).toString();
    _c.text = (gradesBox.get('C')?.points ?? 2.0).toString();
    _dPlus.text = (gradesBox.get('D+')?.points ?? 1.5).toString();
    _d.text = (gradesBox.get('D')?.points ?? 1.0).toString();
  }

  void setPoints() {
    double aPlus = double.parse(_aPlus.text);
    double a = double.parse(_a.text);
    double aMinus = double.parse(_aMinus.text);
    double bPlus = double.parse(_bPlus.text);
    double b = double.parse(_b.text);
    double bMinus = double.parse(_bMinus.text);
    double cPlus = double.parse(_cPlus.text);
    double c = double.parse(_c.text);
    double dPlus = double.parse(_dPlus.text);
    double d = double.parse(_d.text);

    if (d > dPlus || dPlus > c || c > cPlus || cPlus > bMinus ||
    bMinus > b || b > bPlus || bPlus > aMinus || aMinus > a || a > aPlus) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grade points must be in descending order')),
      );
      return;
    }

    if (d < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only non-negative points can be assigned to each grade')),
      );
      return;
    }

    gradesBox.put('A+', GradePoints(points: aPlus));
    gradesBox.put('A', GradePoints(points: a));
    gradesBox.put('A-', GradePoints(points: aMinus));
    gradesBox.put('B+', GradePoints(points: bPlus));
    gradesBox.put('B', GradePoints(points: b));
    gradesBox.put('B-', GradePoints(points: bMinus));
    gradesBox.put('C+', GradePoints(points: cPlus));
    gradesBox.put('C', GradePoints(points: c));
    gradesBox.put('D+', GradePoints(points: dPlus));
    gradesBox.put('D', GradePoints(points: d));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo[200],
        appBar: AppBar(
          title: const Text('Grade Points Settings', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            onPressed: () { Navigator.pop(context); },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    GradePoints.setToDefault();
                    Navigator.pop(context);
                  },
                  child: Text('Set to default'),
                ),
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _aPlus,
                                decoration: InputDecoration(labelText: 'A+'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                            SizedBox(width: 50),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _a,
                                decoration: InputDecoration(labelText: 'A'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _aMinus,
                                decoration: InputDecoration(labelText: 'A-'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                            SizedBox(width: 50),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _bPlus,
                                decoration: InputDecoration(labelText: 'B+'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _b,
                                decoration: InputDecoration(labelText: 'B'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                            SizedBox(width: 50),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _bMinus,
                                decoration: InputDecoration(labelText: 'B-'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _cPlus,
                                decoration: InputDecoration(labelText: 'C+'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                            SizedBox(width: 50),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _c,
                                decoration: InputDecoration(labelText: 'C'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _dPlus,
                                decoration: InputDecoration(labelText: 'D+'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                            SizedBox(width: 50),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _d,
                                decoration: InputDecoration(labelText: 'D'),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setPoints();
                  },
                  child: Text('Save'),
                ),
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('F'),
                            SizedBox(width: 20),
                            Text('0.0', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black.withOpacity(0.6)),)
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('S/CS'),
                            SizedBox(width: 20),
                            Text('Pass (Not counted in GPA)', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black.withOpacity(0.6)),)
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('U/CU'),
                            SizedBox(width: 20),
                            Text('Fail (Not counted in GPA)', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black.withOpacity(0.6)),)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),
        )
    );
  }
}
