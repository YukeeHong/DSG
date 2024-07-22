import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/pages/add_bill.dart';
import 'package:nus_orbital_chronos/services/category.dart';

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

  void _startAddNewBill(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AddBill(id);
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
          final bills = billsBox.values.toList();
          bills.sort((b, a) => a.date.compareTo(b.date));
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemBuilder: (ctx, i) {
                      return Column(
                        children: <Widget>[
                          //Text(DateFormat.yMMMd().format(bills[i].date)),
                          ListView.builder(
                              itemBuilder: (ctx, index) {
                              return Card(
                                color: bills[index].category.color.withOpacity(0.7),
                                child: ListTile(
                                  title: Text(
                                    bills[index].description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: bills[index].category.color == Colors.white ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '\$${bills[index].amount.toStringAsFixed(2)} - ${bills[index].category.title} - ${bills[index].date.toString()}',
                                    style: TextStyle(
                                      color: bills[index].category.color == Colors.white ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                        Icons.delete,
                                        color: bills[index].category.color == Colors.white
                                            ? kDefaultIconLightColor
                                            : Colors.white
                                    ),
                                    onPressed: () {
                                      billsBox.delete(bills[index].id);
                                    },
                                  ),
                                  onTap: () {
                                    _startAddNewBill(context, bills[index].id);
                                  },
                                ),
                              );
                            }
                          ),
                        ],
                      );
                    },
                  ),
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


