import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/assignment.dart';

class ModifyAssignment extends StatefulWidget {
  final String? prefix;
  const ModifyAssignment({super.key, this.prefix});

  @override
  State<ModifyAssignment> createState() => _ModifyAssignmentState();
}

class _ModifyAssignmentState extends State<ModifyAssignment> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool? isAM;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Box<Assignment> assignmentsBox;

  @override
  void initState() {
    super.initState();
    assignmentsBox = Hive.box<Assignment>('Assignments');
  }

  void _pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime!,
    );

    if (pickedTime != null) {
      _selectedTime = pickedTime;
      _selectedTime!.hour < 12 ? isAM = true : isAM = false;
      setState(() {});
    }
  }

  void _saveAssignment() {
    var assignments = assignmentsBox.values.toList();
    assignments.sort((a, b) => a.id.compareTo(b.id));
    int firstEmpty = 1;
    for (Assignment assignment in assignments) {
      if (assignment.id == firstEmpty) {
        firstEmpty++;
      } else {
        break;
      }
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty!')),
      );
      return;
    }

    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final DateTime deadline = _selectedDate!.add(Duration(hours: _selectedTime!.hour, minutes: _selectedTime!.minute));
    final assignment = Assignment(title: title, description: description, due: deadline, id: firstEmpty);

    assignmentsBox.put(firstEmpty, assignment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('${widget.prefix} Assignment', style: TextStyle(color: Colors.white)),
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(22.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title *'),
                      maxLength: 30,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                    SizedBox(height: 50),
                    Text('Deadline', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No Date Chosen!'
                                  : DateFormat.yMMMd().format(_selectedDate!),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'Choose Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _pickDate,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedTime == null
                                  ? 'No Time Chosen!'
                                  : (isAM!
                                  ? '${_selectedTime!.toString().substring(10, 15)} AM'
                                  : '${_selectedTime!.hour - 12}:${_selectedTime!.minute} PM'),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'Choose Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _pickTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAssignment,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
