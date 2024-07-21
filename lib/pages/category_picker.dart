import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:nus_orbital_chronos/pages/modify_category.dart';

class CategoryPicker extends StatefulWidget {
  const CategoryPicker({super.key});

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late Box<Category> expCatBox;

  @override
  void initState() {
    super.initState();
    expCatBox = Hive.box<Category>('Expense Categories');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Planner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModifyCategory(mode: 0, id: ''),
                    ),
                  );
                },
                child: Text('New Category'),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: expCatBox.listenable(),
                  builder: (context, Box<Category> box, _) {
                    var cats = box.values.toList();
                    return ListView.builder(
                        itemCount: cats.length,
                        itemBuilder: (context, index) {
                          final cat = cats[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text(cat.title, style: TextStyle(fontWeight: FontWeight.bold),),
                                trailing: IconButton(
                                  icon: Icon(Icons.settings),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ModifyCategory(mode: 1, id: 'expense_${cat.title}'),
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  Navigator.pop(context, 'expense_${cat.title}');
                                },
                              ),
                            ),
                          );
                        }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
