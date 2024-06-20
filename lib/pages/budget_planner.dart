import 'package:flutter/material.dart';
  import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/add_bill.dart';
import 'package:nus_orbital_chronos/services/bill_list.dart';
import 'package:nus_orbital_chronos/services/bill.dart';

class BudgetPlanner extends StatefulWidget {
  @override
  _BudgetPlannerState createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  late Box<Bill> billsBox;

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');
  }

  void _addBill(String description, double amount, DateTime date) {
    setState(() {
      billsBox.add(Bill(
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
      body: ValueListenableBuilder(
        valueListenable: billsBox.listenable(),
        builder: (context, Box<Bill> billsBox, _) {
          final _bills = billsBox.values.toList();
          final totalAmount = _bills.fold(0.0, (double sum, Bill bill) => sum + bill.amount);

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
                child: BillList(_bills),
              ),
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewBill(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
