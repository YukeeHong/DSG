import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/category.dart';

class ModifyCategory extends StatefulWidget {
  final int mode; // 0: add, 1: edit
  final String id;
  const ModifyCategory({super.key, required this.mode, required this.id});

  @override
  State<ModifyCategory> createState() => _ModifyCategoryState();
}

class _ModifyCategoryState extends State<ModifyCategory> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
