import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/pages/modify_event.dart';
import 'package:nus_orbital_chronos/pages/timetable.dart';
import 'package:nus_orbital_chronos/services/event_provider.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:nus_orbital_chronos/services/format_time_of_day.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Box<Event> eventsBox;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    eventsBox = Hive.box<Event>('Events');
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  bool isEventOnDay(Event event, DateTime day) {
    if (event.repetition[0] == 0) {
      // Mode 0
      return isSameDay(event.date, day);
    } else if (event.repetition[0] == 1) {
      // Mode 1
      return isSameDay(event.date, day) || event.date.isBefore(day) && ((day.difference(event.date).inDays + 1) % event.repetition[8] == 0);
    } else if (event.repetition[0] == 2) {
      // Mode 2
      return isSameDay(event.date, day) || event.date.isBefore(day) && event.repetition[day.weekday % 7 + 1] == 1;
    }
    return false;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return eventsBox.values.where((event) => isEventOnDay(event, day)).toList();
  }

  void _deleteEvent(Event event) {
    context.read<EventProvider>().deleteEvent(_selectedDay!, event);
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_week),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomTimetableScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: eventsBox.listenable(),
          builder: (context, box, _) {
            return Column(
              children: <Widget>[
                TableCalendar<Event>(
                  firstDay: DateTime.now().subtract(Duration(days: 1000)),
                  lastDay: DateTime.now().add(Duration(days: 1000)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedEvents,
                  builder: (context, e, _) {
                    final events = _getEventsForDay(_selectedDay!);
                    events.sort((a, b) => compareTime(a.startTime, b.startTime));
                    return Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            color: event.category.color,
                            child: ListTile(
                              title: Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: event.category.color == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${event.category.title} - ${FormatTimeOfDay.formatTimeOfDay(event.startTime)} - ${FormatTimeOfDay.formatTimeOfDay(event.endTime)}',
                                style: TextStyle(
                                  color: event.category.color == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: event.category.color == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                onPressed: () => _deleteEvent(event),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModifyEvent(mode: false, id: event.id, date: _selectedDay!),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                ),
              ],
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModifyEvent(mode: true, id: -1, date: _selectedDay!),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}