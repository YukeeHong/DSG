import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/quote.dart';
import 'package:nus_orbital_chronos/services/quote_service.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyQuote extends StatefulWidget {
  @override
  _DailyQuoteState createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote> {
  final Box<Quote> quoteBox = Hive.box<Quote>('Quotes');
  bool _isLoading = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Quote? _selectedQuote;

  @override
  void initState() {
    super.initState();
    fetchAndSaveQuote();
  }

  Future<void> fetchAndSaveQuote() async {
    try {
      final today = DateTime.now();
      final savedQuote = quoteBox.values.firstWhere(
            (quote) => quote.date.year == today.year && quote.date.month == today.month && quote.date.day == today.day,
        orElse: () => Quote(text: '', date: DateTime.now()), // 返回一个默认的 Quote
      );

      if (savedQuote.text.isEmpty) { // 检查是否为默认 Quote
        final newQuote = await QuoteService.fetchQuote();
        quoteBox.add(newQuote);
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching or saving quote: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedQuote = quoteBox.values.firstWhere(
            (quote) => quote.date.year == selectedDay.year && quote.date.month == selectedDay.month && quote.date.day == selectedDay.day,
        orElse: () => Quote(text: 'No quote for this day', date: selectedDay),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Quote', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
          ),
          SizedBox(height: 20),
          _selectedQuote != null
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedQuote!.text,
                  style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Date: ${_selectedQuote!.date.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
