import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:nus_orbital_chronos/services/timer_data.dart';

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

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().add(Duration(minutes: widget.data.dur));
  }

  void endSession() {
    widget.data.task = 'Session ended, well done!';
    endTime = DateTime.now();
    widget.data.num = 0;
    sessionEnded = true;
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
      backgroundColor: Colors.red[100],
      appBar: AppBar(
        title: const Text('Focus Mode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40),
              child: Container(height: 375, child: Image(image: AssetImage('assets/tomato.png'))),
            ),
            if (!isPaused)
              TimerCountdown(
                endTime: endTime,
                onEnd: () {
                  setState(() {
                    widget.data.num -= 1;
                    if (widget.data.num > 0) {
                      Navigator.pushNamed(context, '/break_time', arguments: widget.data);
                    } else {
                      endSession();
                    }
                  });
                },
                format: CountDownTimerFormat.minutesSeconds,
                enableDescriptions: false,
                timeTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                colonsTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            if (isPaused) Text(
              "${remainingTime.inMinutes.toString().padLeft(2, '0')} : ${(remainingTime.inSeconds % 60).toString()}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
            Text(widget.data.task, style: TextStyle(fontSize: 20),),
            Text('Intervals remaining: ${widget.data.num}', style: TextStyle(fontSize: 20),),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (!sessionEnded)
            FloatingActionButton(
              backgroundColor: Colors.red[700],
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
              backgroundColor: Colors.red[700],
              onPressed: () {
                setState(() {
                  widget.data.num -= 1;
                  if (widget.data.num > 0) {
                    Navigator.pushNamed(context, '/break_time', arguments: widget.data);
                  } else {
                    endSession();
                  }
                });
              },
              child: const Icon(Icons.skip_next, color: Colors.white),
            ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.red[700],
            onPressed: () {
              Navigator.popUntil(context, (route) => route.settings.name == "/timer_config");
            },
            child: const Icon(Icons.sensor_door_outlined, color: Colors.white),
          ),
        ],
      ) ,
    );
  }
}

