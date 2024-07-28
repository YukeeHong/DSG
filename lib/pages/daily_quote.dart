import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/quote.dart';
import 'package:nus_orbital_chronos/services/quote_service.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyQuotesScreen extends StatefulWidget {
  @override
  _DailyQuotesScreenState createState() => _DailyQuotesScreenState();
}

class _DailyQuotesScreenState extends State<DailyQuotesScreen> {
  late Box<Quote> quoteBox;
  late Quote _selectedQuote;
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    quoteBox = Hive.box<Quote>('Quotes');
    fetchAndSaveQuote();
  }

  Future<void> fetchAndSaveQuote() async {
    try {
      final today = DateTime.now();
      final savedQuote = quoteBox.values.firstWhere(
            (quote) =>
        quote.date.year == today.year &&
            quote.date.month == today.month &&
            quote.date.day == today.day,
        orElse: () => Quote(text: '', date: DateTime.now(), author: ''),
      );

      if (savedQuote.text.isEmpty) {
        final newQuote = await QuoteService.fetchQuote();
        print('New Quote: ${newQuote.text}');
        quoteBox.add(newQuote);
        setState(() {
          _isLoading = false;
          _selectedQuote = newQuote;
        });
      } else {
        print('Saved Quote: ${savedQuote.text}');
        setState(() {
          _isLoading = false;
          _selectedQuote = savedQuote;
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
      _selectedQuote = quoteBox.values.firstWhere(
            (quote) =>
        quote.date.year == selectedDay.year &&
            quote.date.month == selectedDay.month &&
            quote.date.day == selectedDay.day,
        orElse: () => Quote(text: 'No quote available for this day', date: selectedDay, author: ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
          ),
          Expanded(
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedQuote.text,
                      style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, fontFamily: 'PTSerif'),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    Text(
                      '- ${_selectedQuote.author}',
                      style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, fontFamily: 'PTSerif'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
