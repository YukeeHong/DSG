import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';
import 'package:nus_orbital_chronos/services/category.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetTrackerStats extends StatefulWidget {
  final double expense;

  const BudgetTrackerStats({super.key, required this.expense});

  @override
  State<BudgetTrackerStats> createState() => _BudgetTrackerStatsState();
}

class _BudgetTrackerStatsState extends State<BudgetTrackerStats> {
  final _goalController = TextEditingController();
  late Box<Bill> billsBox;
  late Box<Category> expCatBox;
  double income = 0;
  double? net;
  final List<PieChartSectionData> _monthlyByCategory = [];
  final List<int> highestCategories = [-1, -1, -1, -1, -1];
  final List<double> highestSums = [0, 0, 0, 0, 0];
  final List<double> dailySums = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    billsBox = Hive.box<Bill>('Bills');
    expCatBox = Hive.box<Category>('Expense Categories');

    for (Bill bill in billsBox.values.toList()) {
      if (bill.category.id == -2) {
        income += bill.amount;
      }
    }

    net = income - widget.expense;

    if (billsBox.get('monthly_expense_holder') != null) {
      _goalController.text = billsBox.get('monthly_expense_holder')!.amount.toString();
    }

    _generatePieChartData();
    _generateWeeklyGraph();
    print(dailySums.reduce(max));
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

  void _generatePieChartData() {
    final bills = billsBox.values.where((bill) => (
        bill.id != -1
        && bill.category.id != -2
        && bill.date.year == DateTime.now().year
        && bill.date.month == DateTime.now().month
    )).toList();

    final sums = List<double>.filled(bills.length, 0);

    for (Bill bill in bills) {
      sums[bill.category.id] += bill.amount;
    }


    for (int i = 0; i < bills.length; i++) {
      if (sums[i] != 0) {
        _monthlyByCategory.add(PieChartSectionData(
          color: expCatBox.get(i)!.color,
          value: sums[i] / widget.expense * 100,
          radius: 50,
          title: '${(sums[i] / widget.expense * 100).toStringAsFixed(2)}%',
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ));

        if (sums[i] > highestSums[0]) {
          highestSums[4] = highestSums[3];
          highestSums[3] = highestSums[2];
          highestSums[2] = highestSums[1];
          highestSums[1] = highestSums[0];
          highestSums[0] = sums[i];

          highestCategories[4] = highestCategories[3];
          highestCategories[3] = highestCategories[2];
          highestCategories[2] = highestCategories[1];
          highestCategories[1] = highestCategories[0];
          highestCategories[0] = i;
        } else if (sums[i] > highestSums[1]) {
          highestSums[4] = highestSums[3];
          highestSums[3] = highestSums[2];
          highestSums[2] = highestSums[1];
          highestSums[1] = sums[i];

          highestCategories[4] = highestCategories[3];
          highestCategories[3] = highestCategories[2];
          highestCategories[2] = highestCategories[1];
          highestCategories[1] = i;
        } else if (sums[i] > highestSums[2]) {
          highestSums[4] = highestSums[3];
          highestSums[3] = highestSums[2];
          highestSums[2] = sums[i];

          highestCategories[4] = highestCategories[3];
          highestCategories[3] = highestCategories[2];
          highestCategories[2] = i;
        } else if (sums[i] > highestSums[3]) {
          highestSums[4] = highestSums[3];
          highestSums[3] = sums[i];

          highestCategories[4] = highestCategories[3];
          highestCategories[3] = i;
        } else if (sums[i] > highestSums[4]) {
          highestSums[4] = sums[i];
          highestCategories[4] = i;
        }
      }
    }
  }

  void _generateWeeklyGraph() {
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);

    for (Bill bill in billsBox.values.toList().where((bill) => (
        bill.id != -1
        && bill.category.id != -2))) {
      DateTime thisDate = DateTime(bill.date.year, bill.date.month, bill.date.day);
      Duration difference = date.difference(thisDate);
      if (difference.inDays < 7) {
        switch (difference.inDays) {
          case 0:
            dailySums[6] += bill.amount;
            continue;
          case 1:
            dailySums[5] += bill.amount;
            continue;
          case 2:
            dailySums[4] += bill.amount;
            continue;
          case 3:
            dailySums[3] += bill.amount;
            continue;
          case 4:
            dailySums[2] += bill.amount;
            continue;
          case 5:
            dailySums[1] += bill.amount;
            continue;
          case 6:
            dailySums[0] += bill.amount;
            continue;
        }
      }
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = DateFormat.Md().format(date.subtract(Duration(days: 6)));
        break;
      case 1:
        text = DateFormat.Md().format(date.subtract(Duration(days: 5)));
        break;
      case 2:
        text = DateFormat.Md().format(date.subtract(Duration(days: 4)));
        break;
      case 3:
        text = DateFormat.Md().format(date.subtract(Duration(days: 3)));
        break;
      case 4:
        text = DateFormat.Md().format(date.subtract(Duration(days: 2)));
        break;
      case 5:
        text = DateFormat.Md().format(date.subtract(Duration(days: 1)));
        break;
      case 6:
        text = DateFormat.Md().format(date);
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        highestSums[0] >= 1000 ? '\$${(value/1000).toStringAsFixed(1)}K' : '\$${value.toStringAsFixed(0)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
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
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Expenses this Month by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 20),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Card(
                                color: Colors.orange[100],
                                shape: CircleBorder(),
                                child: PieChart(
                                  PieChartData(
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                    sections: _monthlyByCategory,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.amber[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: 5,
                                        itemBuilder: (context, index) {
                                          final cat = highestCategories[index] == -1
                                            ? null
                                            : expCatBox.get(highestCategories[index])!;
                                          return Row(
                                            children: <Widget>[
                                              Text(cat == null ? '-----' : cat.title,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: cat == null ? Colors.white : cat.color,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(highestSums[index].toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                    ),
                                  ),
                                ),
                              ),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Expenses in the Last 7 Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, dailySums[0]),
                                  FlSpot(1, dailySums[1]),
                                  FlSpot(2, dailySums[2]),
                                  FlSpot(3, dailySums[3]),
                                  FlSpot(4, dailySums[4]),
                                  FlSpot(5, dailySums[5]),
                                  FlSpot(6, dailySums[6]),
                                ],
                                isCurved: false,
                                color: Colors.redAccent,
                              ),
                            ],
                            borderData: FlBorderData(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitleWidgets,
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: leftTitleWidgets,
                                  interval: dailySums.reduce(max) == 0 ? 1 : dailySums.reduce(max) / 5,
                                  reservedSize: 48,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              checkToShowVerticalLine: (double value) {
                                return value.toInt() == value;
                              },
                              horizontalInterval: dailySums.reduce(max) == 0 ? 1 : dailySums.reduce(max) / 5,
                              drawHorizontalLine: true,
                              checkToShowHorizontalLine: showAllGrids,
                            ),
                          ),
                        ),
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