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
              TimerCountdown(
                endTime: DateTime.now().add(
                  Duration(
                    minutes: int.parse(widget.data.breakDur),
                  ),
                ),
                onEnd: () {
                  Navigator.pop(context);
                },
                format: CountDownTimerFormat.minutesSeconds,
                enableDescriptions: false,
                timeTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                colonsTextStyle: TextStyle(fontSize: 40),
              ),
              Text('Take a break...', style: TextStyle(fontSize: 20),),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.skip_next, color: Colors.white),
      ),
    );
  }
}

