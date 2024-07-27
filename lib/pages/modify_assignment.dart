import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/assignment.dart';
import 'package:nus_orbital_chronos/services/format_time_of_day.dart';

class ModifyAssignment extends StatefulWidget {
  final String mode;
  final int id;
  const ModifyAssignment({super.key, required this.mode, required this.id});

  @override
  State<ModifyAssignment> createState() => _ModifyAssignmentState();
}

class _ModifyAssignmentState extends State<ModifyAssignment> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? mode;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Box<Assignment> assignmentsBox;

  @override
  void initState() {
    super.initState();
    assignmentsBox = Hive.box<Assignment>('Assignments');
    mode = widget.mode;

    if (mode == 'View') {
      _titleController.text = assignmentsBox.get(widget.id)!.title.toString();
      _descriptionController.text = assignmentsBox.get(widget.id)!.description.toString();
      int hours = assignmentsBox.get(widget.id)!.due.hour;
      int minutes = assignmentsBox.get(widget.id)!.due.minute;
      _selectedDate = assignmentsBox.get(widget.id)!.due.subtract(Duration(hours: hours, minutes: minutes));
      _selectedTime = TimeOfDay(hour: hours, minute: minutes);
    }
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
      setState(() {});
    }
  }

  void _saveAssignment() {
    int firstEmpty;
    if (mode == 'Add') {
      var assignments = assignmentsBox.values.toList();
      assignments.sort((a, b) => a.id.compareTo(b.id));
      firstEmpty = 1;
      for (Assignment assignment in assignments) {
        if (assignment.id == firstEmpty) {
          firstEmpty++;
        } else {
          break;
        }
      }
    } else { firstEmpty = widget.id; }

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
        title: Text('${mode} Assignment', style: TextStyle(color: Colors.white)),
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
                      enabled: (mode != 'View'),
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title *'),
                      maxLength: 30,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      enabled: (mode != 'View'),
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
                    if (mode != 'View')
                      Text('Deadline', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                    if (mode != 'View')
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
                    if (mode != 'View')
                      Container(
                        height: 50,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _selectedTime == null
                                    ? 'No Time Chosen!'
                                    : '${FormatTimeOfDay.formatTimeOfDay(_selectedTime!)}',
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
                    if (mode == 'View' && _selectedTime != null && _selectedDate != null)
                      Container(
                        height: 50,
                        child: Row(
                          children: <Widget>[
                            Text('Deadline', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                            SizedBox(width: 20),
                            Text(DateFormat.yMMMd().format(_selectedDate!)),
                            SizedBox(width: 10),
                            Text('${FormatTimeOfDay.formatTimeOfDay(_selectedTime!)}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (mode == 'View') {
                  setState(() { mode = 'Edit'; });
                } else { _saveAssignment(); }
              },
              child: Text(mode == 'View' ? 'Edit' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
