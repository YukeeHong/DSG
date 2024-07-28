import 'package:hive/hive.dart';

part 'focus_mode_time.g.dart';

@HiveType(typeId: 10)
class FocusModeTime {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  @HiveField(2)
  final int second;

  @HiveField(3)
  final DateTime date;

  FocusModeTime({
    required this.hour,
    required this.minute,
    required this.second,
    required this.date,
  });
}