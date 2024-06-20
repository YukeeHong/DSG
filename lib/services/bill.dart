import 'package:hive/hive.dart';

part 'bill.g.dart';

@HiveType(typeId: 0)
class Bill {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  Bill({
    required this.description,
    required this.amount,
    required this.date,
  });
}