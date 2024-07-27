import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:nus_orbital_chronos/pages/category_picker.dart';

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
  bool? isAMStart;
  bool? isAMEnd;
  bool? modeAdd;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Box<Event> eventsBox;
  late Box<Category> evCatBox;
  int? repetition;

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
      isAMStart = (_selectedStartTime!.hour < 12);
      isAMEnd = (_selectedEndTime!.hour < 12);
      repetition = eventsBox.get(widget.id)!.repetition;
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
        pickedTime.hour < 12 ? isAMStart = true : isAMStart = false;
      } else {
        _selectedEndTime = pickedTime;
        pickedTime.hour < 12 ? isAMEnd = true : isAMEnd = false;
      }
      setState(() {});
    }
  }

  void _saveEvent() {
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

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty!')),
      );
      return;
    }

    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final event = Event(
      title,
      _selectedDate!,
      description,
      _selectedStartTime!,
      _selectedEndTime!,
      _selectedCategory!,
      0,
      firstEmpty,
    );

    eventsBox.put(firstEmpty, event);
    Navigator.pop(context);
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
                                  : (isAMStart!
                                  ? '${_selectedStartTime!.hour}:${_selectedStartTime!.minute.toString().padLeft(2, '0')} AM'
                                  : '${_selectedStartTime!.hour - 12}:${_selectedStartTime!.minute.toString().padLeft(2, '0')} PM'),
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
                                  : (isAMEnd!
                                  ? '${_selectedEndTime!.hour}:${_selectedEndTime!.minute.toString().padLeft(2, '0')} AM'
                                  : '${_selectedEndTime!.hour - 12}:${_selectedEndTime!.minute.toString().padLeft(2, '0')} PM'),
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
