import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/focus_mode_time.dart';

class FocusModeStats extends StatefulWidget {
  const FocusModeStats({super.key});

  @override
  State<FocusModeStats> createState() => _FocusModeStatsState();
}

class _FocusModeStatsState extends State<FocusModeStats> {
  late Box<FocusModeTime> timesBox;
  DateTime today = DateTime(0);
  DateTime week = DateTime(0);
  DateTime month = DateTime(0);
  DateTime allTime = DateTime(0);

  @override
  void initState() {
    super.initState();
    timesBox = Hive.box<FocusModeTime>('Focus');
    DateTime current = DateUtils.dateOnly(DateTime.now());

    for (FocusModeTime time in timesBox.values.toList()) {
      allTime.add(Duration(hours: time.hour, minutes: time.minute, seconds: time.second));
      if (current.compareTo(time.date.add(Duration(days: 30))) < 0) {
        month.add(Duration(hours: time.hour, minutes: time.minute, seconds: time.second));
        if (current.compareTo(time.date.add(Duration(days: 7))) < 0) {
          week.add(Duration(hours: time.hour, minutes: time.minute, seconds: time.second));
          if (current.compareTo(time.date) == 0) {
            today.add(Duration(hours: time.hour, minutes: time.minute, seconds: time.second));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'You\'ve used Focus Mode for',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${today.hour.toString().padLeft(2, '0')}h '
                              '${today.minute.toString().padLeft(2, '0')}m '
                              '${today.second.toString().padLeft(2, '0')}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' today',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${week.hour.toString().padLeft(2, '0')}h '
                              '${week.minute.toString().padLeft(2, '0')}m '
                              '${week.second.toString().padLeft(2, '0')}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' this week',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${month.hour.toString().padLeft(2, '0')}h '
                              '${month.minute.toString().padLeft(2, '0')}m '
                              '${month.second.toString().padLeft(2, '0')}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' this month',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${allTime.hour.toString().padLeft(2, '0')}h '
                              '${allTime.minute.toString().padLeft(2, '0')}m '
                              '${allTime.second.toString().padLeft(2, '0')}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' all-time',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
