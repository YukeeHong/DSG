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
import 'package:nus_orbital_chronos/pages/gpa_calc.dart';

// Import services
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/event_provider.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:nus_orbital_chronos/services/semester.dart';
import 'package:nus_orbital_chronos/services/course.dart';


void main() async {
  // Ensure that Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(SemesterAdapter());
  Hive.registerAdapter(CourseAdapter());

  // Open Hive boxes
  await Hive.openBox<Bill>('Bills'); // TypeId: 0
  await Hive.openBox<Event>('Events'); // TypeId: 1
  await Hive.openBox<Semester>('Semesters'); // TypeId: 2
  await Hive.openBox<Course>('Courses'); // TypeId: 3

  runApp(ChangeNotifierProvider(
    create: (context) => EventProvider(),
    child: MaterialApp(
        initialRoute: '/home',

        routes: {
          '/home': (context) => Home(),
          '/timer_config': (context) => TimerConfig(),
          '/budget_planner': (context) => BudgetPlanner(),
          '/schedule': (context) => CalendarPage(),
          '/gpa_calc': (context) => GPACalc(),
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
