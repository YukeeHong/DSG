import 'package:flutter/material.dart';
import 'event.dart';

class EventProvider extends ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};

  List<Event> getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void addEvent(DateTime day, Event event) {
    if (_events[day] == null) {
      _events[day] = [];
    }
    _events[day]!.add(event);
    notifyListeners();
  }

  void deleteEvent(DateTime day, Event event) {
    _events[day]?.remove(event);
    if (_events[day]?.isEmpty ?? false) {
      _events.remove(day);
    }
    notifyListeners();
  }
}