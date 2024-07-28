import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quote.dart';

class QuoteService {
  static Future<Quote> fetchQuote() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)[0];
      return Quote(text: data['q'], date: DateTime.now(), author: data['a']);
    } else {
      throw Exception('Failed to load quote');
    }
  }
}
