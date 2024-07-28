import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:nus_orbital_chronos/services/focus_mode_time.dart';

class Pomodoro extends StatefulWidget {
  final TimerData data;
  const Pomodoro({super.key, required this.data});

  @override
  State<Pomodoro> createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> {
  late DateTime endTime;
  late Duration remainingTime;
  bool isPaused = false;
  bool sessionEnded = false;
  bool isBreak = false;
  late Box<FocusModeTime> timesBox;

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().add(Duration(minutes: widget.data.dur));
    timesBox = Hive.box<FocusModeTime>('Focus');
  }

  void endSession() {
    widget.data.task = 'Session ended, well done!';
    endTime = DateTime.now();
    widget.data.num = 0;
    sessionEnded = true;
    remainingTime = Duration.zero;
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
      remainingTime = endTime.difference(DateTime.now());
    });
  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
      endTime = DateTime.now().add(remainingTime);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isBreak ? Colors.green[100] : Colors.red[100],
      appBar: AppBar(
        title: const Text('Focus Mode', style: TextStyle(color: Colors.white)),
        backgroundColor: isBreak ? Colors.green[700] : Colors.red[700],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40),
              child: Container(
                  height: 375,
                  child: Image(
                      image: AssetImage('assets/${isBreak ? 'leaf' : 'tomato'}.png')
                  ),
              ),
            ),
            if (!isPaused && !sessionEnded)
              TimerCountdown(
                endTime: endTime,
                onEnd: () {
                  setState(() {
                    if (isBreak) {
                      endTime = DateTime.now().add(Duration(minutes: widget.data.dur));
                    } else {
                      int past = widget.data.dur * 60;
                      timesBox.add(FocusModeTime(
                        hour: (past / 3600).toInt(),
                        minute: ((past % 3600) / 60).toInt(),
                        second: (past % 60).toInt(),
                        date: DateUtils.dateOnly(DateTime.now()),
                      ));

                      endTime = DateTime.now().add(Duration(minutes: widget.data.breakDur));
                      widget.data.num -= 1;
                    }
                    if (widget.data.num > 0) isBreak = !isBreak;
                    if (widget.data.num <= 0) endSession();
                  });
                },
                format: CountDownTimerFormat.minutesSeconds,
                enableDescriptions: false,
                timeTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                colonsTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            if (isPaused || sessionEnded) Text(
                "${remainingTime.inMinutes.toString().padLeft(2, '0')} : ${((remainingTime.inSeconds % 60).toString().padLeft(2, '0')).toString()}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
            if (!isBreak)
            Text(widget.data.task, style: TextStyle(fontSize: 20),),
            if (!isBreak)
            Text('Intervals remaining: ${widget.data.num}', style: TextStyle(fontSize: 20),),
            if (isBreak) Text('Take a break...', style: TextStyle(fontSize: 20),),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (!sessionEnded)
            FloatingActionButton(
              backgroundColor: isBreak ? Colors.green[700] : Colors.red[700],
              onPressed: () {
                setState(() {
                  if (isPaused) {
                    resumeTimer();
                  } else {
                    pauseTimer();
                  }
                });
              },
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
            ),
          SizedBox(width: 10),
          if (!sessionEnded)
            FloatingActionButton(
              backgroundColor: isBreak ? Colors.green[700] : Colors.red[700],
              onPressed: () {
                setState(() {
                  if (!isBreak) {
                    remainingTime = endTime.difference(DateTime.now());
                    int past = widget.data.dur * 60 - remainingTime.inSeconds;
                    timesBox.add(FocusModeTime(
                        hour: (past / 3600).toInt(),
                        minute: ((past % 3600) / 60).toInt(),
                        second: (past % 60).toInt(),
                        date: DateUtils.dateOnly(DateTime.now()),
                    ));
                  }

                  if (isBreak) {
                    endTime = DateTime.now().add(Duration(minutes: widget.data.dur));
                  } else {
                    endTime = DateTime.now().add(Duration(minutes: widget.data.breakDur));
                    widget.data.num -= 1;
                  }

                  if (widget.data.num > 0) isBreak = !isBreak;
                  isPaused = false;
                  if (widget.data.num <= 0) endSession();
                });
              },
              child: const Icon(Icons.skip_next, color: Colors.white),
            ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: isBreak ? Colors.green[700] : Colors.red[700],
            onPressed: () {
              if (!isBreak) {
                remainingTime = endTime.difference(DateTime.now());
                int past = widget.data.dur * 60 - remainingTime.inSeconds;
                timesBox.add(FocusModeTime(
                  hour: (past / 3600).toInt(),
                  minute: ((past % 3600) / 60).toInt(),
                  second: (past % 60).toInt(),
                  date: DateUtils.dateOnly(DateTime.now()),
                ));
              }
              Navigator.popUntil(context, (route) => route.settings.name == "/timer_config");
            },
            child: const Icon(Icons.sensor_door_outlined, color: Colors.white),
          ),
        ],
      ) ,
    );
  }
}

