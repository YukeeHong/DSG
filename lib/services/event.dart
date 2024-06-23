import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event {
  @HiveField(0)
  final String title;

  Event(this.title);

  @override
  String toString() => title;
}