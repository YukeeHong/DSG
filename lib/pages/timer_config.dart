import 'package:flutter/material.dart';

class TimerConfig extends StatefulWidget {
  const TimerConfig({super.key});

  @override
  State<TimerConfig> createState() => _TimerConfigState();
}

class _TimerConfigState extends State<TimerConfig> {
  @override
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
            Row(
              children: <Widget>[
                const Text('Goal to Achieve', style: TextStyle(fontWeight: FontWeight.bold),),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      maxLength: 30,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter goal here',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Interval Duration'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: SizedBox(
                      width: 75,
                      child: TextField(
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                const Text('Number of Intervals'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: SizedBox(
                      width: 40,
                      child: TextField(
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Break Duration'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  child: SizedBox(
                    width: 75,
                    child: TextField(
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(50),
              child: TextButton.icon(
                  onPressed: () { Navigator.pushNamed(context, '/pomodoro'); },
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
