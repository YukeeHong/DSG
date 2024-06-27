import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class EventProvider extends ChangeNotifier {
  final Box<Event> _eventsBox = Hive.box<Event>('Events');

  List<Event> getEventsForDay(DateTime day) {
    return _eventsBox.values.where((event) => isSameDay(event.date, day)).toList();
  }

  void addEvent(DateTime day, Event event) {
    _eventsBox.add(event);
    notifyListeners();
  }

  void deleteEvent(DateTime day, Event event) {
    event.delete();
    notifyListeners();
  }
}