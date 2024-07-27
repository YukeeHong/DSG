import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/event.dart';

class CustomTimetableScreen extends StatefulWidget {
  CustomTimetableScreen({Key? key}) : super(key: key);
  @override
  State<CustomTimetableScreen> createState() => _CustomTimetableScreenState();
}

class _CustomTimetableScreenState extends State<CustomTimetableScreen> {
  final List<TimetableItem<String>> items = [];
  final controller = TimetableController(
    start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7)),
    initialColumns: 3,
    cellHeight: 100.0,
    startHour: 0,
    endHour: 23,
  );
  late Box<Event> eventsBox;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.jumpTo(DateTime.now());
      });
    });
    eventsBox = Hive.box<Event>('Events');
    _makeTimetableData();
  }

  void _makeTimetableData() {
    for (Event event in eventsBox.values.toList()) {
      items.add(TimetableItem(
        event.date.add(Duration(hours: event.startTime.hour, minutes: event.startTime.minute)),
        event.date.add(Duration(hours: event.endTime.hour, minutes: event.endTime.minute)),
        data: '${event.category.color.value.toRadixString(16)}_${event.title}',
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.indigo,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: Colors.white,
        onPressed: () { Navigator.pop(context); },
      ),
      actions: [
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.calendar_view_day),
          color: Colors.white,
          onPressed: () => controller.setColumns(1),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_view_month_outlined),
          color: Colors.white,
          onPressed: () => controller.setColumns(3),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_view_week),
          color: Colors.white,
          onPressed: () => controller.setColumns(5),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          color: Colors.white,
          onPressed: () => controller.setCellHeight(controller.cellHeight + 10),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          color: Colors.white,
          onPressed: () => controller.setCellHeight(controller.cellHeight - 10),
        ),
      ],
    ),
    body: Timetable<String>(
      controller: controller,
      items: items,
      cellBuilder: (datetime) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, width: 0.2),
        ),
      ),
      cornerBuilder: (datetime) => Container(
        decoration: BoxDecoration(color: Colors.indigo[200], border: Border.all(width: 2)),
        child: Center(child: Text("${datetime.year}", style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      headerCellBuilder: (datetime) {
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 2), top: BorderSide(width: 2)),
          ),
          child: Center(
            child: Text(
              DateFormat("E\nMMM d").format(datetime),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      hourLabelBuilder: (time) {
        final hour = time.hour == 12 ? 12 : time.hour % 12;
        final period = time.hour < 12 ? "am" : "pm";
        final isCurrentHour = time.hour == DateTime.now().hour;
        return Text(
          "$hour $period",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isCurrentHour ? Colors.indigo : Colors.black,
          ),
        );
      },
      itemBuilder: (item) => Container(
        decoration: BoxDecoration(
          color: Color(int.parse('${item.data!.substring(0, 8)}', radix: 16)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.data!.substring(9),
                style: TextStyle(
                    fontSize: 16,
                    color: Color(int.parse('${item.data!.substring(0, 8)}', radix: 16)) == Colors.white
                        ? Colors.black
                        : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${item.start.hour > 12
                    ? item.start.hour - 12
                    : item.start.hour
                }:${item.start.minute.toString().padLeft(2, '0')} ${
                    item.start.minute > 12
                        ? 'PM'
                        : 'AM'
                } - ${item.end.hour > 12
                    ? item.end.hour - 12
                    : item.end.hour
                }:${item.end.minute.toString().padLeft(2, '0')} ${
                    item.end.minute > 12
                        ? 'PM'
                        : 'AM'
                }',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(int.parse('${item.data!.substring(0, 8)}', radix: 16)) == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      nowIndicatorColor: Colors.red,
      snapToDay: true,
    ),
  );
}
