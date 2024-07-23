import 'package:flutter/material.dart';
import 'dart:core';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/category.dart';

class BudgetTrackerStats extends StatefulWidget {
  final double expense;

  const BudgetTrackerStats({super.key, required this.expense});

  @override
  State<BudgetTrackerStats> createState() => _BudgetTrackerStatsState();
}

class _BudgetTrackerStatsState extends State<BudgetTrackerStats> {
  final _goalController = TextEditingController();
  late Box<Bill> billsBox;
  double income = 0;
  double? net;

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');

    for (Bill bill in billsBox.values.toList()) {
      if (bill.category.id == -2) {
        income += bill.amount;
      }
    }

    net = income - widget.expense;

    if (billsBox.get('monthly_expense_holder') != null) {
      _goalController.text = billsBox.get('monthly_expense_holder')!.amount.toString();
    }
  }

  void _saveGoal() {
    billsBox.put('monthly_expense_holder',
      Bill(
        description: 'goal',
        amount: double.parse(_goalController.text),
        date: DateTime.now(),
        id: -1,
        category: Category(title: '', color: Colors.transparent, id: -1),
        time: TimeOfDay(hour: 0, minute: 0),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        decoration: InputDecoration(labelText: 'Monthly Goal (Expense)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveGoal,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text('Monthly total expense: \$${widget.expense.toStringAsFixed(2)}'),
                      Text('Monthly total income: \$${income.toStringAsFixed(2)}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Net change: '),
                          Text('${net! > 0 ? '+' : '-'} \$${net!.abs().toStringAsFixed(2)}',
                            style: TextStyle(color: net! > 0 ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
