import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/pages/home.dart';
import 'package:nus_orbital_chronos/pages/loading.dart';
import 'package:nus_orbital_chronos/pages/pomodoro.dart';
import 'package:nus_orbital_chronos/pages/timer_config.dart';

void main() =>runApp(MaterialApp(
  initialRoute: '/home',

  routes: {
//    '/': (context) => Loading(),
    '/home': (context) => Home(),
    '/timer_config': (context) => TimerConfig(),
    '/pomodoro': (context) => Pomodoro(),
  },
));
