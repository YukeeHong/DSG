import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:nus_orbital_chronos/pages/category_picker.dart';
import 'package:nus_orbital_chronos/services/format_time_of_day.dart';

class ModifyEvent extends StatefulWidget {
  final bool mode; // true: Add, false: Edit
  final int id;
  final DateTime date;
  const ModifyEvent({super.key, required this.mode, required this.id, required this.date});

  @override
  State<ModifyEvent> createState() => _ModifyEventState();
}

class _ModifyEventState extends State<ModifyEvent> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Category? _selectedCategory;
  bool? modeAdd;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nController = TextEditingController();
  late Box<Event> eventsBox;
  late Box<Category> evCatBox;
  // [0] = mode 0: none 1: every n days 2: day of week
  List<int> repetition = [0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    eventsBox = Hive.box<Event>('Events');
    evCatBox = Hive.box<Category>('Event Categories');
    modeAdd = widget.mode;

    if (!modeAdd!) {
      _titleController.text = eventsBox.get(widget.id)!.title.toString();
      _descriptionController.text = eventsBox.get(widget.id)!.description.toString();
      _selectedStartTime = eventsBox.get(widget.id)!.startTime;
      _selectedEndTime = eventsBox.get(widget.id)!.endTime;
      _selectedDate = eventsBox.get(widget.id)!.date;
      _selectedCategory = eventsBox.get(widget.id)!.category;
      repetition = eventsBox.get(widget.id)!.repetition;
      _nController.text = repetition[8].toString();
    } else {
      _selectedDate = widget.date;
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

  Future<void> _pickTime(bool isStart) async {
    TimeOfDay? time = isStart ? _selectedStartTime : _selectedEndTime;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      if (isStart) {
        _selectedStartTime = pickedTime;
      } else {
        _selectedEndTime = pickedTime;
      }
      setState(() {});
    }
  }

  int compareTime(TimeOfDay a, TimeOfDay b) {
    if (a.hour == b.hour) {
      if (a.minute > b.minute) return 1;
      if (a.minute < b.minute) return -1;
      return 0;
    }
    if (a.hour > b.hour) return 1;
    return -1;
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    if (_selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select start and end time')),
      );
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select category')),
      );
    }

    if (compareTime(_selectedStartTime!, _selectedEndTime!) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start time must come before end time')),
      );
      return;
    }

    if (repetition[0] == 1 && (int.parse(_nController.text) < 1 || int.parse(_nController.text) > 30)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a value from 1-30 for N')),
      );
      return;
    }

    int firstEmpty;
    if (modeAdd!) {
      var events = eventsBox.values.toList();
      events.sort((a, b) => a.id.compareTo(b.id));
      firstEmpty = 1;
      for (Event event in events) {
        if (event.id == firstEmpty) {
          firstEmpty++;
        } else {
          break;
        }
      }
    } else { firstEmpty = widget.id; }

    final String title = _titleController.text;
    final String description = _descriptionController.text;

    if (repetition[0] == 1) repetition = [1, 0, 0, 0, 0, 0, 0, 0, int.parse(_nController.text)];
    else if (repetition[0] == 2) repetition[8] = 0;
    else repetition = [0, 0, 0, 0, 0, 0, 0, 0, 0];

    final event = Event(
      title,
      _selectedDate!,
      description,
      _selectedStartTime!,
      _selectedEndTime!,
      _selectedCategory!,
      repetition,
      firstEmpty,
    );

    eventsBox.put(firstEmpty, event);
    Navigator.pop(context);
  }

  void _toggleOnDay(int day) {
    // 1 - 7: Sun - Sat
    repetition[day] = 1 - repetition[day];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('${modeAdd! ? 'Add' : 'Edit'} Event', style: TextStyle(color: Colors.white)),
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
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Text('Start', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                          TextButton(
                            child: Text(DateFormat.yMMMd().format(_selectedDate!)),
                            onPressed: _pickDate,
                          ),
                          TextButton(
                            child: Text(
                              _selectedStartTime == null
                                  ? 'No Time Chosen!'
                                  : '${FormatTimeOfDay.formatTimeOfDay(_selectedStartTime!)}',
                            ),
                            onPressed: () {
                              _pickTime(true);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Text('End', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                          TextButton(
                            child: Text(DateFormat.yMMMd().format(_selectedDate!)),
                            onPressed: _pickDate,
                          ),
                          TextButton(
                            child: Text(
                              _selectedEndTime == null
                                  ? 'No Time Chosen!'
                                  : '${FormatTimeOfDay.formatTimeOfDay(_selectedEndTime!)}',
                            ),
                            onPressed: () {
                              _pickTime(false);
                            },
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
                              _selectedCategory == null
                                  ? 'No Category Selected!'
                                  : 'Selected Category: ${_selectedCategory!.title}',
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'Select Category',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              int id = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryPicker(boxId: 1),
                                ),
                              );
                              _selectedCategory = evCatBox.get(id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Repeat', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6))),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 200,
                            child: DropdownButton(
                              value: repetition[0],
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (int? newOption) {
                                setState(() {
                                  repetition[0] = newOption!;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('None'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Every N days'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('Select days of week'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (repetition[0] == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextField(
                              controller: _nController,
                              decoration: InputDecoration(labelText: 'N *'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    if (repetition[0] == 2)
                      Container(
                        height: 55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(1),
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: repetition[1] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(2),
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: repetition[2] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(3),
                                child: Text(
                                  'T',
                                  style: TextStyle(
                                    color: repetition[3] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(4),
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    color: repetition[4] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(5),
                                child: Text(
                                  'T',
                                  style: TextStyle(
                                    color: repetition[5] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(6),
                                child: Text(
                                  'F',
                                  style: TextStyle(
                                    color: repetition[6] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: TextButton(
                                onPressed: () => _toggleOnDay(7),
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: repetition[7] == 0 ? Colors.black : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
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
              onPressed: _saveEvent,
              child: Text(modeAdd! ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
