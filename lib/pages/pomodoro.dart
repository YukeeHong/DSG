/*
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      appBar: AppBar(
        title: const Text('Focus Mode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        automaticallyImplyLeading: false,
      ),
      body: Expanded(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40),
                child: Image(image: AssetImage('assets/tomato.png')),
              ),
              TimerCountdown(
                endTime: DateTime.now().add(
                  Duration(
                    minutes: int.parse(widget.data.dur),
                  ),
                ),
                onEnd: () {
                  Navigator.pushNamed(context, '/break_time', arguments: widget.data);
                },
                format: CountDownTimerFormat.minutesSeconds,
                enableDescriptions: false,
                timeTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                colonsTextStyle: TextStyle(fontSize: 40),
              ),
              Text(widget.data.task, style: TextStyle(fontSize: 20),),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.sensor_door_outlined, color: Colors.white),
      ),
    );
  }
}
*/

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

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().add(Duration(minutes: widget.data.dur));
  }

  void endSession() {
    widget.data.task = 'Session ended, well done!';
    endTime = DateTime.now();
    widget.data.num = 0;
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
              child: Image(image: AssetImage('assets/tomato.png')),
            ),
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
              colonsTextStyle: TextStyle(fontSize: 40),
            ),
            Text(widget.data.task, style: TextStyle(fontSize: 20),),
            Text('Intervals remaining: ${widget.data.num}', style: TextStyle(fontSize: 20),),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
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
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.red[700],
            onPressed: () {
              Navigator.popUntil(context, (route) => route.settings.name == "/timer_config");
            },
            child: const Icon(Icons.sensor_door_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

