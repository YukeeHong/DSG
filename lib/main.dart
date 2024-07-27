// Import Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:nus_orbital_chronos/pages/assignment_tracker.dart';
import 'package:nus_orbital_chronos/pages/daily_quote.dart';
import 'package:nus_orbital_chronos/pages/timetable.dart';

// Import services
import 'package:nus_orbital_chronos/services/timer_data.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/event_provider.dart';
import 'package:nus_orbital_chronos/services/event.dart';
import 'package:nus_orbital_chronos/services/semester.dart';
import 'package:nus_orbital_chronos/services/course.dart';
import 'package:nus_orbital_chronos/services/grade_points.dart';
import 'package:nus_orbital_chronos/services/assignment.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:nus_orbital_chronos/services/color_adapter.dart';
import 'package:nus_orbital_chronos/services/time_of_day_adapter.dart';
import 'package:nus_orbital_chronos/services/quote.dart';

void main() async {
  // Ensure that Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(BillAdapter()); // TypeId: 0
  Hive.registerAdapter(EventAdapter()); // TypeId: 1
  Hive.registerAdapter(SemesterAdapter()); // TypeId: 2
  Hive.registerAdapter(CourseAdapter()); // TypeId: 3
  Hive.registerAdapter(GradePointsAdapter()); // TypeId: 4
  Hive.registerAdapter(AssignmentAdapter()); // TypeId: 5
  Hive.registerAdapter(CategoryAdapter()); // TypeId: 6
  Hive.registerAdapter(ColorAdapter()); // TypeId: 7
  Hive.registerAdapter(TimeOfDayAdapter()); // TypeId: 8
  Hive.registerAdapter(QuoteAdapter()); // TypeId: 9

  // Open Hive boxes
  await Hive.openBox<Bill>('Bills');
  await Hive.openBox<Event>('Events');
  await Hive.openBox<Semester>('Semesters');
  await Hive.openBox<Course>('Courses');
  await Hive.openBox<GradePoints>('GradePoints');
  await Hive.openBox<Assignment>('Assignments');
  await Hive.openBox<Category>('Expense Categories');
  await Hive.openBox<Quote>('Quotes');
  await Hive.openBox<Category>('Event Categories');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
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
            '/daily_quote': (context) => DailyQuotesScreen(),
            '/assignment_tracker': (context) => AssignmentTracker(),
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
            return null;
          }
      ),
    ));
  });
}
