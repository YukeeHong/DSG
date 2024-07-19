import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';

class BudgetPlanner extends StatefulWidget {
  @override
  _BudgetPlannerState createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  late Box<Bill> billsBox;
  var _bills;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');
    _bills = billsBox.values.toList();
  }

  void addBill(String description, double amount, DateTime date, int id) {
    setState(() {
      billsBox.put(id, Bill(
        description: description,
        amount: amount,
        date: date,
        id: id,
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
    );

    _descriptionController.clear();
    _amountController.clear();
    _selectedDate = null;

    _bills = billsBox.values.toList();
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

  void _startAddNewBill(BuildContext context, int id) {
    if (id != -1) {
      Bill bill = billsBox.get(id)!;
      _descriptionController.text = bill.description;
      _amountController.text = bill.amount.toString();
      _selectedDate = bill.date;
    }

    showModalBottomSheet(
      context: context,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
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
                      Container(
                        height: 70,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'No Date Chosen!'
                                    : 'Picked Date: ${_selectedDate.toString()}',
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              child: Text(
                                'Choose Date',
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
                      ElevatedButton(
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                          Theme.of(context).primaryColor, // Button text color
                        ),
                        onPressed: () {
                          _submitData(id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          )
        );
      },
    );
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
      body: ValueListenableBuilder(
        valueListenable: billsBox.listenable(),
        builder: (context, Box<Bill> billsBox, _) {
          final totalAmount = billsBox.values.fold<double>(0.0, (double sum, Bill bill) => sum + bill.amount);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                color: Theme.of(context).primaryColor,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _bills.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      child: ListTile(
                        title: Text(_bills[index].description),
                        subtitle: Text(
                          '\$${_bills[index].amount.toStringAsFixed(2)} - ${_bills[index].date.toString()}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            billsBox.delete(_bills[index].id);
                          },
                        ),
                        onTap: () {
                          _startAddNewBill(context, _bills[index].id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewBill(context, -1),
        child: Icon(Icons.add),
      ),
    );
  }
}


