import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:nus_orbital_chronos/services/timer_data.dart';

class BreakTime extends StatefulWidget {
  final TimerData data;
  const BreakTime({super.key, required this.data});

  @override
  State<BreakTime> createState() => _BreakTimeState();
}

class _BreakTimeState extends State<BreakTime> {
  late DateTime endTime;
  late Duration remainingTime;
  bool isPaused = false;
  bool isRunning = true;

  void initState() {
    super.initState();
    endTime = DateTime.now().add(Duration(minutes: widget.data.breakDur));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Focus Mode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
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
              if (isRunning)
                TimerCountdown(
                  endTime: endTime,
                  onEnd: () {
                    Navigator.pushNamed(context, '/pomodoro', arguments: widget.data);
                  },
                  format: CountDownTimerFormat.minutesSeconds,
                  enableDescriptions: false,
                  timeTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  colonsTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              if (isPaused) Text(
                  "${remainingTime.inMinutes.toString().padLeft(2, '0')} : ${(remainingTime.inSeconds % 60).toString()}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              Text('Take a break...', style: TextStyle(fontSize: 20),),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.green[700],
            onPressed: () {
              setState(() {
                if (isPaused) {
                  resumeTimer();
                } else {
                  pauseTimer();
                }
                isRunning = !isRunning;
              });
            },
            child: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.green[700],
            onPressed: () {
              Navigator.pushNamed(context, '/pomodoro', arguments: widget.data);
            },
            child: const Icon(Icons.skip_next, color: Colors.white),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.green[700],
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

