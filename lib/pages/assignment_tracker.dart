import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/pages/modify_assignment.dart';
import 'package:nus_orbital_chronos/services/assignment.dart';

class AssignmentTracker extends StatefulWidget {
  const AssignmentTracker({super.key});

  @override
  State<AssignmentTracker> createState() => _AssignmentTrackerState();
}

class _AssignmentTrackerState extends State<AssignmentTracker> {
  late Box<Assignment> assignmentsBox;

  @override
  void initState() {
    super.initState();
    assignmentsBox = Hive.box<Assignment>('Assignments');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: const Text('Assignment Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModifyAssignment(mode: 'Add', id: -1),
                    ),
                  );
                },
                child: Text('Add Assignment'),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: assignmentsBox.listenable(),
                  builder: (context, Box<Assignment> box, _) {
                    var assignments = box.values.toList();
                    assignments.sort((a, b) => a.due.compareTo(b.due));
                    return ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text(assignment.title, style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text('Deadline: ${DateFormat.yMMMd().format(assignment.due)}  ${assignment.due.hour < 12
                                  ? '${assignment.due.hour}:${assignment.due.minute.toString().padLeft(2, '0')} AM'
                                  : '${assignment.due.hour - 12}:${assignment.due.minute.toString().padLeft(2, '0')} PM'}',
                              style: TextStyle(color: assignment.due.subtract(Duration(days: 3)).isBefore(DateTime.now())
                                  ? Colors.red : Colors.black),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  assignmentsBox.delete(assignment.id);
                                  setState(() {});
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModifyAssignment(mode: 'View', id: assignment.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}