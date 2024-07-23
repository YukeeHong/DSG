import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nus_orbital_chronos/services/quote.dart';

class QuoteService {
  static const String apiUrl = 'https://api.quotable.io/random';

  static Future<Quote> fetchQuote() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final quote = Quote(
        text: data['content'],
        date: DateTime.now(),
      );
      return quote;
    } else {
      throw Exception('Failed to load quote');
    }
  }
}
