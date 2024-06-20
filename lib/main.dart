// Import Flutter material
import 'package:flutter/material.dart';
// Import Hive
import 'package:hive_flutter/hive_flutter.dart';

// Import pages
import 'package:nus_orbital_chronos/pages/home.dart';
import 'package:nus_orbital_chronos/pages/loading.dart';
import 'package:nus_orbital_chronos/pages/pomodoro.dart';
import 'package:nus_orbital_chronos/pages/timer_config.dart';
import 'package:nus_orbital_chronos/pages/break_time.dart';
import 'package:nus_orbital_chronos/pages/budget_planner.dart';

// Import services
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:nus_orbital_chronos/services/bill.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BillAdapter());
  await Hive.openBox<Bill>('Bills');

  runApp(MaterialApp(
      initialRoute: '/home',

      routes: {
        //    '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/timer_config': (context) => TimerConfig(),
        '/budget_planner': (context) => BudgetPlanner(),
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
}
