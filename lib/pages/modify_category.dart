import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ModifyCategory extends StatefulWidget {
  final bool modeAdd; // true: add, false: edit
  final int id;
  final int boxId; // 0: Bill, 1: Event
  const ModifyCategory({super.key, required this.modeAdd, required this.id, required this.boxId});

  @override
  State<ModifyCategory> createState() => _ModifyCategoryState();
}

class _ModifyCategoryState extends State<ModifyCategory> {
  late Box<Category> box;
  final _titleController = TextEditingController();
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    box = Hive.box<Category>(widget.boxId == 0 ? 'Expense Categories' : 'Event Categories');

    if (!widget.modeAdd) {
      _titleController.text = box.get(widget.id)!.title;
      _selectedColor = box.get(widget.id)!.color;
    }
  }

  void _saveCategory() {
    int id = widget.id;
    if (id == -1) {
      int firstFree = 0;
      var cats = box.values.toList();
      cats.sort((a, b) => a.id.compareTo(b.id));
      for (Category cat in cats) {
        if (cat.id == firstFree) {
          firstFree++;
        } else {
          break;
        }
      }

      id = firstFree;
    }

    box.put(id, Category(
      title: _titleController.text,
      color: _selectedColor!,
      id: id,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('${widget.modeAdd ? 'Add' : 'Edit'} Category', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(22.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                      maxLength: 15,
                    ),
                    Container(

                      child: ColorPicker(
                        color: _selectedColor ?? Color(0xFF0000),
                        onColorChanged: (Color color) =>
                            setState(() => _selectedColor = color),
                        width: 40,
                        height: 40,
                        borderRadius: 4,
                        spacing: 5,
                        runSpacing: 5,
                        wheelDiameter: 155,
                        heading: Text(
                          'Select color',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subheading: Text(
                          'Select color shade',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        wheelSubheading: Text(
                          'Selected color and its shades',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        showMaterialName: true,
                        showColorName: false,
                        showColorCode: false,
                        materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
                        colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                        colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
                        colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
                        selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.both: false,
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: true,
                          ColorPickerType.bw: false,
                          ColorPickerType.custom: true,
                          ColorPickerType.wheel: true,
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text('Save'),
                ),
                if(widget.id != -1)
                  SizedBox(width: 30),
                if(widget.id != -1)
                  ElevatedButton(
                    onPressed: () {
                      box.delete(widget.id);
                      Navigator.pop(context);
                    },
                    child: Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
