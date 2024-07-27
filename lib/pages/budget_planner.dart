import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/pages/budget_tracker_stats.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/pages/add_bill.dart';
import 'package:nus_orbital_chronos/services/format_time_of_day.dart';

class BudgetPlanner extends StatefulWidget {
  @override
  _BudgetPlannerState createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  late Box<Bill> billsBox;
  bool? goalIsEmpty;

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');
    goalIsEmpty = (billsBox.get('monthly_expense_holder') == null);
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
          final bills = billsBox.values.where((bill) => bill.id != -1).toList();
          bills.sort((b, a) => a.date.compareTo(b.date));
          final totalAmount = billsBox.values.fold<double>(
              0.0, (double sum, Bill bill) {
                if (bill.category.id != -2 && bill.id != -1
                    && bill.date.year == DateTime.now().year && bill.date.month == DateTime.now().month) {
                  return sum + bill.amount;
                } else {
                  return sum;
                }
              });
          final groupedBills = groupBillsByDate(bills);

          return Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetTrackerStats(expense: totalAmount),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Monthly Expenses:',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '\$${totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: !goalIsEmpty! && billsBox.get('monthly_expense_holder')!.amount < totalAmount
                                          ? Colors.red[600]
                                          : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Monthly Goal:',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      goalIsEmpty!
                                      ? 'N/A'
                                      : '\$${billsBox.get('monthly_expense_holder')!.amount.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Press for more',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                          ),
                        ],
                      ),
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
                                          '\$${billsOnDate[i].amount.toStringAsFixed(2)} - ${billsOnDate[i].category.title} - '
                                              '${FormatTimeOfDay.formatTimeOfDay(TimeOfDay(hour: billsOnDate[i].time.hour, minute: billsOnDate[i].time.minute))}',
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
