import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nus_orbital_chronos/services/quote_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SchedulerService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  SchedulerService() {
    final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification() async {
    final quote = await QuoteService.fetchQuote();

    await _saveQuote(quote.text);

    final time = Time(8, 0, 0); // 8:00 AM
    final androidDetails = AndroidNotificationDetails(
      'daily_quote',
      'Daily Quote',
      channelDescription: 'Daily quote notification',
    );
    final iOSDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Daily Quote',
      quote.text,
      _nextInstanceOfTime(time),
      notificationDetails,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _saveQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final date = '${now.year}-${now.month}-${now.day}';
    final quotes = prefs.getStringList('daily_quotes_$date') ?? [];
    quotes.add(quote);
    await prefs.setStringList('daily_quotes_$date', quotes);
  }

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate;
  }

  Future<void> setNotificationTime(Time time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
  }

  Future<Time> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 8;
    final minute = prefs.getInt('notification_minute') ?? 0;
    return Time(hour, minute, 0);
  }

  Future<List<String>> getQuotesByDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = '${date.year}-${date.month}-${date.day}';
    return prefs.getStringList('daily_quotes_$dateString') ?? [];
  }

  Future<List<DateTime>> getAllQuoteDates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('daily_quotes_')).toList();
    return keys.map((key) {
      final dateParts = key.replaceFirst('daily_quotes_', '').split('-');
      return DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
    }).toList();
  }
}
