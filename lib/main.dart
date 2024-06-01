import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/pages/home.dart';
import 'package:nus_orbital_chronos/pages/loading.dart';
import 'package:nus_orbital_chronos/pages/pomodoro.dart';
import 'package:nus_orbital_chronos/pages/timer_config.dart';
import 'package:nus_orbital_chronos/pages/break_time.dart';

import 'package:nus_orbital_chronos/services/timer_data.dart';

void main() =>runApp(MaterialApp(
  initialRoute: '/home',

  routes: {
//    '/': (context) => Loading(),
    '/home': (context) => Home(),
    '/timer_config': (context) => TimerConfig(),
  },

  onGenerateRoute: (settings) {
    if (settings.name == '/pomodoro') {
      final args = settings.arguments as TimerData;
      return MaterialPageRoute(
        builder: (context) {
          return Pomodoro(data: args);
        },
      );
    } else if (settings.name == '/break_time') {
      final args = settings.arguments as TimerData;
      return MaterialPageRoute(
        builder: (context) {
          return BreakTime(data: args);
        },
      );
    }
  }
));
