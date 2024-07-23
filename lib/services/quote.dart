import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 9)
class Quote {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  Quote({required this.text, required this.date});
}
