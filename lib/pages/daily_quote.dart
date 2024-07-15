import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/quote_service.dart';
import 'package:nus_orbital_chronos/services/scheduler_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyQuote extends StatefulWidget {
  @override
  _DailyQuoteState createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote> {
  String _quote = 'Loading...';
  final _quoteService = QuoteService();
  final _schedulerService = SchedulerService();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadQuote();
    _schedulerService.scheduleDailyNotification();
  }

  Future<void> _loadQuote() async {
    final quote = await _quoteService.fetchQuote();
    setState(() {
      _quote = quote;
    });
  }

  void _navigateToPastQuotes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PastQuotesPage(schedulerService: _schedulerService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quote', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _quote,
                style: TextStyle(fontSize: 24.0, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToPastQuotes(context),
                child: Text('View Past Quotes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PastQuotesPage extends StatefulWidget {
  final SchedulerService schedulerService;

  PastQuotesPage({required this.schedulerService});

  @override
  _PastQuotesPageState createState() => _PastQuotesPageState();
}

class _PastQuotesPageState extends State<PastQuotesPage> {
  late Future<List<DateTime>> _quoteDatesFuture;

  @override
  void initState() {
    super.initState();
    _quoteDatesFuture = widget.schedulerService.getAllQuoteDates();
  }

  void _showQuotesForDate(DateTime date) async {
    final quotes = await widget.schedulerService.getQuotesByDate(date);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quotes for ${date.toLocal().toIso8601String().split('T')[0]}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: quotes.map((quote) => Text(quote)).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Quotes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: FutureBuilder<List<DateTime>>(
        future: _quoteDatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No past quotes available.'));
          } else {
            final dates = snapshot.data!;
            return ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                return ListTile(
                  title: Text(date.toLocal().toIso8601String().split('T')[0]),
                  onTap: () => _showQuotesForDate(date),
                );
              },
            );
          }
        },
      ),
    );
  }
}
