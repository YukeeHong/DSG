import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/pages/modify_event.dart';
import 'package:nus_orbital_chronos/services/event_provider.dart';
import 'package:nus_orbital_chronos/services/event.dart';

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
    _selectedDay = _focusedDay;
    eventsBox = Hive.box<Event>('Events');
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return eventsBox.values.where((event) => isSameDay(event.date, day)).toList();
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
      ),
      body: ValueListenableBuilder(
          valueListenable: eventsBox.listenable(),
          builder: (context, box, _) {
            final events = eventsBox.values.toList().where((event) => event.date == _selectedDay).toList();
            events.sort((a, b) => compareTime(a.startTime, b.startTime));
            return Column(
              children: <Widget>[
                TableCalendar<Event>(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
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
                  builder: (context, events, _) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            color: event.category.color.withOpacity(0.7),
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
                                '${event.category.title} - ${event.startTime.hour > 12
                                    ? event.startTime.hour - 12
                                    : event.startTime.hour
                                }:${event.startTime.minute.toString().padLeft(2, '0')} ${
                                    event.startTime.minute > 12
                                        ? 'PM'
                                        : 'AM'
                                } - ${event.endTime.hour > 12
                                    ? event.endTime.hour - 12
                                    : event.endTime.hour
                                }:${event.endTime.minute.toString().padLeft(2, '0')} ${
                                    event.endTime.minute > 12
                                        ? 'PM'
                                        : 'AM'
                                }',
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