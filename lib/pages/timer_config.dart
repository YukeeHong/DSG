import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/timer_data.dart';

class TimerConfig extends StatefulWidget {
  const TimerConfig({super.key});

  @override
  State<TimerConfig> createState() => _TimerConfigState();
}

class _TimerConfigState extends State<TimerConfig> {
  @override

  final goal = TextEditingController();
  final interval = TextEditingController();
  final numIntervals = TextEditingController();
  final breakDuration = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.all(15.0),
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
            Padding(
              padding: const EdgeInsets.all(50),
              child: TextButton.icon(
                  onPressed: () {
                    if (interval.text.isEmpty || numIntervals.text.isEmpty || breakDuration.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all the required fields')),
                      );
                    } else if (interval.text.contains('.') || breakDuration.text.contains('.') ||
                        interval.text.contains(',') || breakDuration.text.contains(',') ||
                        interval.text.contains('-') || breakDuration.text.contains('-') ||
                        interval.text.contains(' ') || breakDuration.text.contains(' ')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter only numbers in the required fields')),
                      );
                    } else if (int.parse(interval.text) == 0 || int.parse(breakDuration.text) == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please use non-zero values in the required fields')),
                      );
                    } else {
                      TimerData data = TimerData(
                        task: goal.text,
                        dur: interval.text,
                        num: numIntervals.text,
                        breakDur: breakDuration.text,
                      );
                      Navigator.pushNamed(context, '/pomodoro', arguments: data);
                    }
                  },
                  icon: Icon(Icons.play_arrow_rounded),
                  label: Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
