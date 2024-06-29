// Import Flutter material
import 'package:flutter/material.dart';
// Import Hive
import 'package:hive_flutter/hive_flutter.dart';
// Import Provider
import 'package:provider/provider.dart';

// Import pages
import 'package:nus_orbital_chronos/pages/home.dart';
import 'package:nus_orbital_chronos/pages/pomodoro.dart';
import 'package:nus_orbital_chronos/pages/timer_config.dart';
import 'package:nus_orbital_chronos/pages/break_time.dart';
import 'package:nus_orbital_chronos/pages/budget_planner.dart';
import 'package:nus_orbital_chronos/pages/schedule.dart';

// Import services
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/event_provider.dart';
import 'package:nus_orbital_chronos/services/event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Register Hive Adapters
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(EventAdapter());
  // Open Hive boxes
  await Hive.openBox<Bill>('Bills'); // TypeId: 0
  await Hive.openBox<Event>('Events'); // TypeId: 1

  runApp(ChangeNotifierProvider(
    create: (context) => EventProvider(),
    child: MaterialApp(
        initialRoute: '/home',

        routes: {
          //    '/': (context) => Loading(),
          '/home': (context) => Home(),
          '/timer_config': (context) => TimerConfig(),
          '/budget_planner': (context) => BudgetPlanner(),
          '/schedule': (context) => CalendarPage(),
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
    ),
  ));
}
