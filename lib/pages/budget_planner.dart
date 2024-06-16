import 'package:flutter/material.dart';
import 'package:nus_orbital_chronos/services/add_bill.dart';
import 'package:nus_orbital_chronos/services/bill_list.dart';
import 'package:nus_orbital_chronos/services/bill.dart';

class BudgetPlanner extends StatefulWidget {
  @override
  _BudgetPlannerState createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  final List<Bill> _bills = [];

  void _addBill(String description, double amount, DateTime date) {
    setState(() {
      _bills.add(Bill(
        description: description,
        amount: amount,
        date: date,
      ));
    });
  }

  void _startAddNewBill(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: AddBill(_addBill),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Total Amount: \$${_bills.fold(0.0, (double sum, Bill bill) => sum + bill.amount).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: BillList(_bills),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewBill(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
