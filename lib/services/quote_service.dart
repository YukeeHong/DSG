import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String _apiUrl = 'https://api.quotable.io/random';

  Future<String> fetchQuote() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      throw Exception('Failed to load quote');
    }
  }
}