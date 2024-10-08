import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:nus_orbital_chronos/pages/modify_category.dart';

class CategoryPicker extends StatefulWidget {
  final int boxId; // 0: Bill, 1: Event

  const CategoryPicker({super.key, required this.boxId});

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late Box<Category> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<Category>(widget.boxId == 0 ? 'Expense Categories' : 'Event Categories');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('Select Category', style: TextStyle(color: Colors.white)),
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
                      builder: (context) => ModifyCategory(modeAdd: true, id: -1, boxId: widget.boxId),
                    ),
                  );
                },
                child: Text('New Category'),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<Category> box, _) {
                    var cats = box.values.toList();
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: cats.length,
                            itemBuilder: (context, index) {
                              final cat = cats[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                                child: Card(
                                  color: cat.color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      cat.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cat.color == Colors.white ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.settings,
                                        color: cat.color == Colors.white ? Colors.black : Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ModifyCategory(modeAdd: false, id: cat.id, boxId: widget.boxId),
                                          ),
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, cat.id);
                                    },
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
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
