import 'package:flutter/material.dart';

class Pomodoro extends StatefulWidget {
  const Pomodoro({super.key});

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
    );
  }
}
