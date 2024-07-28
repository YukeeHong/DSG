import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 9)
class Quote {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String author;

  Quote({required this.text, required this.date, required this.author});
}
