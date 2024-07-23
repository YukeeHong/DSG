import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/pages/category_picker.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/category.dart';

class AddBill extends StatefulWidget {
  final int id;

  AddBill(this.id);

  @override
  _AddBillState createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {
  late Box<Bill> billsBox;
  late Box<Category> expCatBox;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory;
  TimeOfDay? _selectedTime;
  bool? isAM;

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');
    expCatBox = Hive.box<Category>('Expense Categories');
    if (widget.id != -1) {
      Bill bill = billsBox.get(widget.id)!;
      _descriptionController.text = bill.description;
      _amountController.text = bill.amount.toString();
      _selectedDate = bill.date;
      _selectedCategory = bill.category;
      _selectedTime = bill.time;
      _selectedTime!.hour < 12 ? isAM = true : isAM = false;
    }
  }

  void addBill(String description, double amount, DateTime date, int id, Category category, TimeOfDay time) {
    setState(() {
      billsBox.put(id, Bill(
        description: description,
        amount: amount,
        date: date,
        id: id,
        category: category,
        time: time,
      ));
    });
  }

  void _submitData(int id) {
    if (_amountController.text.isEmpty) {
      return;
    }

    final enteredDescription = _descriptionController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredDescription.isEmpty ||
        enteredAmount <= 0 ||
        _selectedDate == null) {
      return;
    }

    if (id == -1) {
      int firstFree = 0;
      var bills = billsBox.values.toList();
      bills.sort((a, b) => a.id.compareTo(b.id));
      for (Bill bill in bills) {
        if (bill.id == firstFree) {
          firstFree++;
        } else {
          break;
        }
      }

      id = firstFree;
    }

    addBill(
      enteredDescription,
      enteredAmount,
      _selectedDate!,
      id,
      _selectedCategory!,
      _selectedTime!,
    );

    _descriptionController.clear();
    _amountController.clear();
    _selectedDate = null;

    Navigator.of(context).pop();
  }

  void _presentDatePicker(DateTime date) {
    showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime!,
    );

    if (pickedTime != null) {
      _selectedTime = pickedTime;
      _selectedTime!.hour < 12 ? isAM = true : isAM = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Container(
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Select Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      DateTime date = _selectedDate ?? DateTime.now();
                      _presentDatePicker(date);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedCategory == null
                          ? 'No Category Selected!'
                          : 'Selected Category: ${_selectedCategory!.title}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Select Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      int id = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryPicker(),
                        ),
                      );
                      _selectedCategory = expCatBox.get(id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No Time Chosen!'
                          : (isAM!
                          ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')} AM'
                          : '${_selectedTime!.hour - 12}:${_selectedTime!.minute.toString().padLeft(2, '0')} PM'),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Choose Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _pickTime,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                Theme.of(context).primaryColor, // Button text color
              ),
              onPressed: () {
                _submitData(widget.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}