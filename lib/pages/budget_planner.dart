import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/pages/add_bill.dart';

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
            },
          ),
        );
      },
    );
  }

  Map<DateTime, List<Bill>> groupBillsByDate(List<Bill> bills) {
    final Map<DateTime, List<Bill>> groupedBills = {};
    for (var bill in bills) {
      final date = DateTime(bill.date.year, bill.date.month, bill.date.day);
      if (groupedBills.containsKey(date)) {
        groupedBills[date]!.add(bill);
      } else {
        groupedBills[date] = [bill];
      }
    }
    return groupedBills;
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: billsBox.listenable(),
        builder: (context, Box<Bill> billsBox, _) {
          final bills = billsBox.values.toList();
          bills.sort((b, a) => a.date.compareTo(b.date));
          final totalAmount = billsBox.values.fold<double>(
              0.0, (double sum, Bill bill) => sum + bill.amount);
          final groupedBills = groupBillsByDate(bills);

          return Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              width: 130,
                              child: Text(
                                'This Month:',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}     ',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              SizedBox(height: 70),
                              Text(
                                'Press for more',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 130,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Monthly Goal:',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                '\$${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    ...groupedBills.entries.map((entry) {
                      final date = entry.key;
                      final billsOnDate = entry.value;
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (i == 0) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        DateFormat.yMMMd().format(date),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Card(
                                      color: billsOnDate[i].category.color.withOpacity(0.7),
                                      child: ListTile(
                                        title: Text(
                                          billsOnDate[i].description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: billsOnDate[i].category.color == Colors.white
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '\$${billsOnDate[i].amount.toStringAsFixed(2)} - ${billsOnDate[i].category.title} - ${
                                              billsOnDate[i].time.hour > 12
                                              ? billsOnDate[i].time.hour - 12
                                              : billsOnDate[i].time.hour
                                          }:${billsOnDate[i].time.minute} ${
                                              billsOnDate[i].time.hour > 12
                                              ? 'PM'
                                              : 'AM'
                                          }',
                                          style: TextStyle(
                                            color: billsOnDate[i].category.color == Colors.white
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: billsOnDate[i].category.color == Colors.white
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          onPressed: () {
                                            billsBox.delete(billsOnDate[i].id);
                                          },
                                        ),
                                        onTap: () {
                                          _startAddNewBill(context, billsOnDate[i].id);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: billsOnDate.length,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewBill(context, -1),
        child: Icon(Icons.add),
      ),
    );
  }
}
