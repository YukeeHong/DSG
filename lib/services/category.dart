import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 6)
class Category extends HiveObject {
  @HiveField(0)
  final String title;

  Category({
    required this.title,
  });
}