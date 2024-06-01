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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Focus Mode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
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
                  print('Timer finished');
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
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.sensor_door_outlined),
      ),
    );
  }
}

