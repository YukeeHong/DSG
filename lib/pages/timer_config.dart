import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/focus_mode_time.dart';

class TimerConfig extends StatefulWidget {
  const TimerConfig({super.key});

  @override
  State<TimerConfig> createState() => _TimerConfigState();
}

class _TimerConfigState extends State<TimerConfig> {
  final goal = TextEditingController();
  final interval = TextEditingController();
  final numIntervals = TextEditingController();
  final breakDuration = TextEditingController();
  bool repeated = true;

  late Box<FocusModeTime> timesBox;
  Duration today = Duration.zero;
  Duration week = Duration.zero;
  Duration month = Duration.zero;
  Duration allTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    numIntervals.addListener(_toggleBreak);

    timesBox = Hive.box<FocusModeTime>('Focus');
    _calculateDurations();
    setState(() {});
  }

  void _toggleBreak() {
    setState(() {
      if (numIntervals.text.isEmpty || int.parse(numIntervals.text) != 1) {
        repeated = true;
      } else {
        repeated = false;
      }
    });
  }

  void _calculateDurations() {
    today = Duration.zero;
    week = Duration.zero;
    month = Duration.zero;
    allTime = Duration.zero;

    DateTime current = DateUtils.dateOnly(DateTime.now());

    for (FocusModeTime time in timesBox.values.toList()) {
      allTime += Duration(hours: time.hour, minutes: time.minute, seconds: time.second);
      if (current.compareTo(time.date.add(Duration(days: 30))) < 0) {
        month += Duration(hours: time.hour, minutes: time.minute, seconds: time.second);
        if (current.compareTo(time.date.add(Duration(days: 7))) < 0) {
          week += Duration(hours: time.hour, minutes: time.minute, seconds: time.second);
          if (current.compareTo(time.date) == 0) {
            today += Duration(hours: time.hour, minutes: time.minute, seconds: time.second);
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
        title: const Text('Focus Mode Settings', style: TextStyle(color: Colors.white)),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: TextField(
                        controller: goal,
                        keyboardType: TextInputType.text,
                        maxLength: 30,
                        decoration: InputDecoration(
                          icon: Icon(Icons.checklist),
                          hintText: 'What are you aiming for today?',
                          labelText: 'Goal',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: SizedBox(
                        width: 210,
                        child: TextField(
                          controller: interval,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: InputDecoration(
                            icon: Icon(Icons.alarm),
                            labelText: 'Interval Duration *',
                            hintText: 'Minutes',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: SizedBox(
                        width: 210,
                        child: TextField(
                          controller: numIntervals,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            icon: Icon(Icons.repeat),
                            labelText: 'Number of Intervals *',
                          ),
                        ),
                      ),
                    ),
                    if (repeated)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                        child: SizedBox(
                          width: 210,
                          child: TextField(
                            controller: breakDuration,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            decoration: InputDecoration(
                              icon: Icon(Icons.pause),
                              labelText: 'Break Duration *',
                              hintText: 'Minutes',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (interval.text.isEmpty || numIntervals.text.isEmpty || (repeated && breakDuration.text.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all the required fields')),
                    );
                  } else if (interval.text.contains('.') || (repeated && breakDuration.text.contains('.')) ||
                      interval.text.contains(',') || (repeated && breakDuration.text.contains(',')) ||
                      interval.text.contains('-') || (repeated && breakDuration.text.contains('-')) ||
                      interval.text.contains(' ') || (repeated && breakDuration.text.contains(' '))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter only numbers in the required fields')),
                    );
                  } else if (int.parse(interval.text) == 0 || int.parse(numIntervals.text) == 0 || (repeated && int.parse(breakDuration.text) == 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please use non-zero values in the required fields')),
                    );
                  } else {
                    TimerData data = TimerData(
                      task: goal.text.isEmpty ? " " : 'Goal: ${goal.text}',
                      dur: int.parse(interval.text),
                      num: int.parse(numIntervals.text),
                      breakDur: !repeated ? 0 : int.parse(breakDuration.text),
                    );
                    Navigator.pushNamed(context, '/pomodoro', arguments: data);
                  }
                },
                icon: Icon(Icons.play_arrow_rounded),
                label: Text('Start'),
              ),
            ),
            ValueListenableBuilder(
                valueListenable: timesBox.listenable(),
                builder: (context, a, _) {
                  _calculateDurations();
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Activity',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${today.inHours.toString().padLeft(2, '0')}h '
                                    '${(today.inMinutes % 60).toString().padLeft(2, '0')}m '
                                    '${(today.inSeconds % 60).toString().padLeft(2, '0')}s',
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
                                '${week.inHours.toString().padLeft(2, '0')}h '
                                    '${(week.inMinutes % 60).toString().padLeft(2, '0')}m '
                                    '${(week.inSeconds % 60).toString().padLeft(2, '0')}s',
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
                                '${month.inHours.toString().padLeft(2, '0')}h '
                                    '${(month.inMinutes % 60).toString().padLeft(2, '0')}m '
                                    '${(month.inSeconds % 60).toString().padLeft(2, '0')}s',
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
                                '${allTime.inHours.toString().padLeft(2, '0')}h '
                                    '${(allTime.inMinutes % 60).toString().padLeft(2, '0')}m '
                                    '${(allTime.inSeconds % 60).toString().padLeft(2, '0')}s',
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
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
